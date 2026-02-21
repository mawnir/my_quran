// scripts/update_whats_new.dart

// ignore_for_file: avoid_print ()

import 'dart:io';

void main() {
  final projectRoot = _findProjectRoot();
  if (projectRoot == null) {
    stderr.writeln('❌ Could not find project root (no pubspec.yaml found)');
    exit(1);
  }

  final version = _readVersion(projectRoot);
  if (version == null) {
    stderr.writeln('❌ Could not read version from pubspec.yaml');
    exit(1);
  }

  final buildNumber = _readBuildNumber(projectRoot);
  print('📦 Version: $version (build $buildNumber)');

  final versionMap = _readVersionMap(projectRoot);

  // Ensure current version is in the map
  if (buildNumber != null && !versionMap.containsKey(buildNumber)) {
    print('⚠️  Build $buildNumber not in version_map.txt, adding it.');
    versionMap[buildNumber] = version;
    _writeVersionMap(projectRoot, versionMap);
  }

  final allVersions = _readAllChangelogs(projectRoot, versionMap, buildNumber);
  if (allVersions.isEmpty) {
    stderr.writeln('❌ No changelog files found');
    exit(1);
  }

  print('📝 Found ${allVersions.length} version(s):');
  for (final v in allVersions) {
    final tag = v.isCurrent ? ' ← current' : '';
    print(
      '   v${v.version} (build ${v.buildNumber}, '
      '${v.entries.length} entries)$tag',
    );
  }

  final success = _updateDialogFile(projectRoot, version, allVersions);
  if (success) {
    print('✅ Updated whats_new_dialog.dart');
  } else {
    stderr.writeln('❌ Failed to update whats_new_dialog.dart');
    exit(1);
  }
}

// ─────────────────────────────────────────────────────────
// Project helpers
// ─────────────────────────────────────────────────────────

String? _findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) return dir.path;
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}

String? _readVersion(String root) {
  final file = File('$root/pubspec.yaml');
  if (!file.existsSync()) return null;
  for (final line in file.readAsLinesSync()) {
    final match = RegExp(r'^version:\s*(\S+)').firstMatch(line);
    if (match != null) return match.group(1)!.split('+').first;
  }
  return null;
}

int? _readBuildNumber(String root) {
  final file = File('$root/pubspec.yaml');
  if (!file.existsSync()) return null;
  for (final line in file.readAsLinesSync()) {
    final match = RegExp(r'^version:\s*\S+\+(\d+)').firstMatch(line);
    if (match != null) return int.tryParse(match.group(1)!);
  }
  return null;
}

// ─────────────────────────────────────────────────────────
// Version map
// ─────────────────────────────────────────────────────────

Map<int, String> _readVersionMap(String root) {
  final file = File('$root/fastlane/version_map.txt');
  if (!file.existsSync()) {
    print('📄 No version_map.txt found, creating one.');
    return {};
  }

  final map = <int, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final parts = trimmed.split('=');
    if (parts.length == 2) {
      final num = int.tryParse(parts[0].trim());
      if (num != null) map[num] = parts[1].trim();
    }
  }
  return map;
}

void _writeVersionMap(String root, Map<int, String> map) {
  final file = File('$root/fastlane/version_map.txt');
  final sorted = map.keys.toList()..sort();
  final lines = <String>[
    '# build_number=version',
    for (final key in sorted) '$key=${map[key]}',
  ];
  file.writeAsStringSync('${lines.join('\n')}\n');
  print('📄 Updated version_map.txt');
}

// ─────────────────────────────────────────────────────────
// Changelog reading
// ─────────────────────────────────────────────────────────

List<_VersionChangelog> _readAllChangelogs(
  String root,
  Map<int, String> versionMap,
  int? currentBuild,
) {
  final dirs = [
    '$root/fastlane/metadata/android/ar/changelogs',
    '$root/fastlane/metadata/android/ar-SA/changelogs',
    '$root/fastlane/metadata/android/en-US/changelogs',
  ];

  Directory? changelogDir;
  for (final path in dirs) {
    final dir = Directory(path);
    if (dir.existsSync()) {
      changelogDir = dir;
      print('📄 Reading from: $path');
      break;
    }
  }
  if (changelogDir == null) return [];

  final files =
      changelogDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.txt'))
          .toList()
        ..sort((a, b) {
          final aNum = _extractBuildNumber(a.path) ?? 0;
          final bNum = _extractBuildNumber(b.path) ?? 0;
          return bNum.compareTo(aNum);
        });

  final versions = <_VersionChangelog>[];

  for (final file in files) {
    final buildNum = _extractBuildNumber(file.path);
    if (buildNum == null) continue;

    final content = file.readAsStringSync().trim();
    if (content.isEmpty) continue;

    final entries = _parseChangelog(content);
    if (entries.isEmpty) continue;

    final isCurrent = buildNum == currentBuild;
    final version = versionMap[buildNum] ?? buildNum.toString();

    versions.add(
      _VersionChangelog(
        version: version,
        buildNumber: buildNum,
        isCurrent: isCurrent,
        entries: entries,
      ),
    );
  }

  // Safety: if nothing matched as current, mark first
  if (versions.isNotEmpty && !versions.any((v) => v.isCurrent)) {
    print(
      '⚠️  No build matched current ($currentBuild). '
      'Marking newest as current.',
    );
    final first = versions.first;
    versions[0] = _VersionChangelog(
      version: versionMap[first.buildNumber] ?? first.version,
      buildNumber: first.buildNumber,
      isCurrent: true,
      entries: first.entries,
    );
  }

  return versions;
}

int? _extractBuildNumber(String path) {
  final fileName = path.split(Platform.pathSeparator).last;
  final match = RegExp(r'^(\d+)\.txt$').firstMatch(fileName);
  return match != null ? int.tryParse(match.group(1)!) : null;
}

List<_ChangelogEntry> _parseChangelog(String content) {
  final entries = <_ChangelogEntry>[];

  for (var line in content.split('\n')) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    final bulletMatch = RegExp(r'^[-*•]\s+(.+)$').firstMatch(line);
    final text = bulletMatch?.group(1)?.trim() ?? line;

    entries.add(
      _ChangelogEntry(
        text: text,
        icon: _guessIcon(text),
        color: _guessColor(text),
      ),
    );
  }

  return entries;
}

// ─────────────────────────────────────────────────────────
// Icon / color detection
// ─────────────────────────────────────────────────────────

String _guessIcon(String text) {
  final lower = text.toLowerCase();
  for (final entry in _iconMap.entries) {
    if (entry.key.any(lower.contains)) return entry.value;
  }
  return 'Icons.auto_awesome';
}

String _guessColor(String text) {
  final lower = text.toLowerCase();
  for (final entry in _colorMap.entries) {
    if (entry.key.any(lower.contains)) return entry.value;
  }
  return 'Colors.blue';
}

const _iconMap = <List<String>, String>{
  ['bookmark', 'علامة', 'مرجعية']: 'Icons.bookmarks',
  ['note', 'ملاحظ']: 'Icons.edit_note',
  ['search', 'بحث']: 'Icons.search',
  ['font', 'خط']: 'Icons.text_fields',
  ['theme', 'dark', 'مظهر', 'سمة']: 'Icons.palette',
  ['performance', 'speed', 'أداء', 'سرعة']: 'Icons.speed',
  ['fix', 'bug', 'إصلاح']: 'Icons.bug_report',
  ['indicator', 'visual', 'مؤشر', 'بصري']: 'Icons.visibility',
  ['categor', 'تصنيف']: 'Icons.category',
  ['improve', 'تحسين']: 'Icons.trending_up',
  ['screen', 'شاشة']: 'Icons.phone_android',
  ['menu', 'قائمة']: 'Icons.menu',
};

const _colorMap = <List<String>, String>{
  ['fix', 'bug', 'إصلاح']: 'Colors.red',
  ['improve', 'performance', 'تحسين', 'أداء']: 'Colors.blue',
  ['note', 'ملاحظ']: 'Colors.teal',
  ['bookmark', 'علامة']: 'Colors.orange',
  ['indicator', 'visual', 'مؤشر']: 'Colors.purple',
  ['categor', 'تصنيف']: 'Colors.green',
  ['screen', 'شاشة']: 'Colors.indigo',
};

// ─────────────────────────────────────────────────────────
// Code generation
// ─────────────────────────────────────────────────────────

bool _updateDialogFile(
  String root,
  String currentVersion,
  List<_VersionChangelog> allVersions,
) {
  final filePath = '$root/lib/app/widgets/whats_new_dialog.dart';
  final content = _generateDialogCode(currentVersion, allVersions);
  File(filePath).writeAsStringSync(content);
  return true;
}

String _generateDialogCode(
  String currentVersion,
  List<_VersionChangelog> allVersions,
) {
  final versionWidgets = StringBuffer();

  for (final ver in allVersions) {
    versionWidgets.writeln('                      _VersionSection(');
    versionWidgets.writeln(
      "                        version: '${_esc(ver.version)}',",
    );
    versionWidgets.writeln(
      '                        isCurrent: ${ver.isCurrent},',
    );
    versionWidgets.writeln('                        entries: [');
    for (final entry in ver.entries) {
      versionWidgets.writeln('                          _ChangeEntry(');
      versionWidgets.writeln(
        "                            text: '${_esc(entry.text)}',",
      );
      versionWidgets.writeln(
        '                            icon: ${entry.icon},',
      );
      versionWidgets.writeln(
        '                            color: ${entry.color},',
      );
      versionWidgets.writeln('                          ),');
    }
    versionWidgets.writeln('                        ],');
    versionWidgets.writeln('                      ),');
  }

  return '''
// GENERATED — DO NOT EDIT BY HAND
// Run: dart run scripts/update_whats_new.dart
// Version: $currentVersion | Generated: ${DateTime.now().toIso8601String()}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: lines_longer_than_80_chars ()

class WhatsNewDialog extends StatelessWidget {
  const WhatsNewDialog({super.key});

  static const String _currentVersion = '$currentVersion';
  static const String _seenKey = 'whats_new_seen_version';

  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seenVersion = prefs.getString(_seenKey);
    if (seenVersion == _currentVersion) return;
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WhatsNewDialog(),
    );

    await prefs.setString(_seenKey, _currentVersion);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 28,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ما الجديد؟',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
$versionWidgets
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('فهمت، شكراً'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionSection extends StatelessWidget {
  const _VersionSection({
    required this.version,
    required this.isCurrent,
    required this.entries,
  });

  final String version;
  final bool isCurrent;
  final List<_ChangeEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ExpansionTile(
        key: isCurrent ? const Key('current_version') : null,
        initiallyExpanded: isCurrent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Text(
              'v\$version',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (isCurrent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'الحالي',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ],
        ),
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: entry.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(entry.icon, size: 18, color: entry.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        entry.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChangeEntry {
  const _ChangeEntry({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;
}
''';
}

String _esc(String s) {
  return s
      .replaceAll('\\', '\\\\')
      .replaceAll("'", "\\'")
      .replaceAll('\n', '\\n')
      .replaceAll('\$', '\\\$');
}

// ─────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────

class _ChangelogEntry {
  const _ChangelogEntry({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final String icon;
  final String color;
}

class _VersionChangelog {
  const _VersionChangelog({
    required this.version,
    required this.buildNumber,
    required this.isCurrent,
    required this.entries,
  });

  final String version;
  final int buildNumber;
  final bool isCurrent;
  final List<_ChangelogEntry> entries;
}
