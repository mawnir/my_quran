// GENERATED — DO NOT EDIT BY HAND
// Run: dart run scripts/update_whats_new.dart
// Version: 1.5.0 | Generated: 2026-02-21T15:42:12.670393

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: lines_longer_than_80_chars ()

class WhatsNewDialog extends StatelessWidget {
  const WhatsNewDialog({super.key});

  static const String _currentVersion = '1.5.0';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      style: Theme.of(context).textTheme.headlineSmall
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
                      _VersionSection(
                        version: '1.5.0',
                        isCurrent: true,
                        entries: [
                          _ChangeEntry(
                            text:
                                'نظام علامات مرجعية جديد مع تصنيفات وألوان قابلة للتخصيص',
                            icon: Icons.bookmarks,
                            color: Colors.green,
                          ),
                          _ChangeEntry(
                            text:
                                'أرقام الآيات المحفوظة تظهر الآن بلون التصنيف مع تمييز الملاحظات',
                            icon: Icons.edit_note,
                            color: Colors.teal,
                          ),
                          _ChangeEntry(
                            text: 'شاشة مخصصة لعرض وتصفية العلامات حسب التصنيف',
                            icon: Icons.category,
                            color: Colors.green,
                          ),
                          _ChangeEntry(
                            text: 'إعادة تصميم قائمة الآية لتجربة أسرع وأبسط',
                            icon: Icons.menu,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.4.4',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'رواية ورش عن نافع: دعم كامل لرواية ورش بالرسم العثماني المخصص، مع ضبط فواصل الآيات والترقيم الخاص بالرواية.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'إمكانية التبديل بين روايتي "حفص" و "ورش" بسهولة من الإعدادات.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.4.3',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'إصلاح: الانتقال إلى آية أو سورة أو صفحة معينة في وضع الكتاب.',
                            icon: Icons.bug_report,
                            color: Colors.red,
                          ),
                          _ChangeEntry(
                            text:
                                'إصلاح: استعادة آخر موضع قراءة الآن بشكل صحيح عند فتح التطبيق في وضع الكتاب.',
                            icon: Icons.bug_report,
                            color: Colors.red,
                          ),
                          _ChangeEntry(
                            text:
                                'ميزة: الحفاظ على موضع القراءة عند التبديل بين وضع الكتاب والوضع العادي.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.4.2',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text: 'إضافة وضع الكتاب للتنقل بين الصفحات بالسحب.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'إضافة خيار اللون الأسود الحقيقي لشاشات OLED.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'إصلاح: خطأ إملائي في الآية 46 من سورة الأعراف.',
                            icon: Icons.text_fields,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '113',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text: 'إضافة وضع الكتاب للتنقل بين الصفحات بالسحب.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'إضافة خيار اللون الأسود الحقيقي لشاشات OLED.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'إصلاح: خطأ إملائي في الآية 46 من سورة الأعراف.',
                            icon: Icons.text_fields,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.3.0',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'أصبح التطبيق متاحًا الآن كتطبيق ويب تقدمي (PWA)!',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text: 'إصلاح مشكلة عدم تطبيق إعدادات سماكة الخط.',
                            icon: Icons.text_fields,
                            color: Colors.red,
                          ),
                          _ChangeEntry(
                            text: 'إصلاح مشكلة الخط في النصوص المنسوخة.',
                            icon: Icons.text_fields,
                            color: Colors.red,
                          ),
                          _ChangeEntry(
                            text:
                                'إضافة زر "انتقال" لتسهيل التنقل عند استخدام نوافذ الانتقال.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text: 'تصميم جديد ومحسّن لنافذة خيارات الآية.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text: 'تحسينات عامة على أداء التطبيق وسرعته.',
                            icon: Icons.speed,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.2.5',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'إضافة نص القرآن الكريم بخط حفص بالرسم العثماني(على رواية حفص).',
                            icon: Icons.text_fields,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'إصلاح مشكلة ظهور فجوات بين الكلمات عند تكبير الخط.',
                            icon: Icons.text_fields,
                            color: Colors.red,
                          ),
                          _ChangeEntry(
                            text:
                                'يمكنك الآن النقر مباشرة على العناصر في عجلات التنقل لتحديدها.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'النقر على السورة أو الجزء أو الصفحة في الترويسة المثبتة سيفتح مربع حوار إدخال للتنقل السريع إلى السورة/الجزء/الصفحة.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.2.4',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'ميزة: إضافة خيار إظهار نتائج البحث المطابقة فقط',
                            icon: Icons.search,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'إصلاح: قص بداية الآيات الطويلة تلقائياً لضمان ظهور الكلمة المبحوث عنها في المعاينة',
                            icon: Icons.bug_report,
                            color: Colors.red,
                          ),
                          _ChangeEntry(
                            text:
                                'بالإضافة إلى تحسينات طفيفة في أداء التطبيق بشكل عام.',
                            icon: Icons.speed,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.2.3',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'FIX: reproducible build is failing due to Flutter SDK mismatch',
                            icon: Icons.bug_report,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.2.2',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text: 'إصلاح عدد الآيات في ترويسة السورة',
                            icon: Icons.bug_report,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.2.1',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'build: update the release workflow to support reproducible builds on F-Droid',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.2.0',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'تقليل حجم الفهرس  عن طريق استبعاد الرموز القرآنية، علامات الترقيم، والأرقام من الفهرس',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text: 'تحسين دقة نتائج البحث',
                            icon: Icons.search,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'إصلاح مشكلة عدم ظهور نتائج عند البحث عن بعض الكلمات مثل لفظ الجلالة (الله)',
                            icon: Icons.search,
                            color: Colors.red,
                          ),
                          _ChangeEntry(
                            text: 'تحسينات أخرى:',
                            icon: Icons.trending_up,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text: 'استخدام تأثير الزجاج للزر العائم',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text: 'زيادة حجم فواصل الآيات',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.1.0',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'يقدم هذا الإصدار إعادة تصميم للصفحة الرئيسية.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text: 'التغييرات الرئيسية تشمل:',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'تم استبدال شريط التنقل السفلي بزر عائم للوصول',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text: 'السريع إلى التنقل السريع.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'يتميز شريط التطبيق الآن بأيقونات مخصصة للبحث والإشارات المرجعية،',
                            icon: Icons.bookmarks,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'مما يحسن إمكانية الوصول إلى هذه الميزات الأساسية.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                          _ChangeEntry(
                            text:
                                'تم إعادة تصميم واجهة التنقل السريع لتجربة مستخدم أكثر سهولة.',
                            icon: Icons.auto_awesome,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      _VersionSection(
                        version: '1.0.1',
                        isCurrent: false,
                        entries: [
                          _ChangeEntry(
                            text:
                                'إعطاء الألف الخنجرية مساحة أكبر في نص القرآن لتحسين القراءة.',
                            icon: Icons.trending_up,
                            color: Colors.blue,
                          ),
                        ],
                      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Text(
              'v$version',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (isCurrent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: entry.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(entry.icon, size: 18, color: entry.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.text,
                      style: Theme.of(context).textTheme.bodyMedium,
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
