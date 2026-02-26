import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_quran/app/widgets/edit_note_dialog.dart';
import 'package:my_quran/quran/quran.dart';
import 'package:my_quran/app/models.dart';
import 'package:my_quran/app/services/bookmark_service.dart';
import 'package:my_quran/app/utils.dart';

class VerseMenuDialog extends StatefulWidget {
  const VerseMenuDialog({required this.surah, required this.verse, super.key});
  final int surah;
  final Verse verse;

  @override
  State<VerseMenuDialog> createState() => _VerseMenuDialogState();
}

enum _ActiveView { verse, tafseer, words, meaning }

class _VerseMenuDialogState extends State<VerseMenuDialog> {
  late final bookmarkService = BookmarkService();
  late bool isBookmarked = bookmarkService.isBookmarked(widget.surah, widget.verse.number);
  late VerseBookmark? bookmark = bookmarkService.getBookmarkFor(
    widget.surah,
    widget.verse.number,
  );
  late final List<BookmarkCategory> categories = bookmarkService.getCategoriesSync();

  BookmarkCategory? currentCategory;

  // ── Active View state ──
  _ActiveView _activeView = _ActiveView.verse;

  // ── Tafseer state ──
  bool _tafseerLoading = false;
  String? _tafseerText;
  String? _tafseerError;

  // ── Words state ──
  bool _wordsLoading = false;
  List<dynamic>? _words;
  String? _wordsError;

  // ── Meaning state ──
  bool _meaningLoading = false;
  String? _meaningText;
  String? _meaningError;

  @override
  void initState() {
    super.initState();
    _syncCategory();
  }

  void _syncCategory() {
    if (isBookmarked && bookmark?.categoryId != null) {
      try {
        currentCategory = categories.firstWhere((c) => c.id == bookmark!.categoryId);
      } catch (_) {
        currentCategory = null;
      }
    } else {
      currentCategory = null;
    }
  }

  String? get _defaultCategoryId => categories.firstOrNull?.id;

  // ── Toggle tafseer / verse ──
  Future<void> _toggleTafseer() async {
    if (_activeView == _ActiveView.tafseer) {
      setState(() => _activeView = _ActiveView.verse);
      return;
    }

    // Already fetched — just show it.
    if (_tafseerText != null) {
      setState(() => _activeView = _ActiveView.tafseer);
      return;
    }

    // Fetch for the first time.
    setState(() {
      _activeView = _ActiveView.tafseer;
      _tafseerLoading = true;
      _tafseerError = null;
    });

    try {
      final url = Uri.parse(
        'https://api.alquran.cloud/v1/ayah/'
        '${widget.surah}:${widget.verse.number}/ar.muyassar',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = (data['data'] as Map<String, dynamic>?)?['text'] as String? ?? '';
        setState(() {
          _tafseerText = text;
          _tafseerLoading = false;
        });
      } else {
        setState(() {
          _tafseerError = 'خطأ في الاتصال (${response.statusCode})';
          _tafseerLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _tafseerError = 'تعذّر تحميل التفسير. يرجى التحقق من الاتصال بالإنترنت.';
        _tafseerLoading = false;
      });
    }
  }

  Future<void> _retryTafseer() async {
    setState(() {
      _tafseerText = null;
      _tafseerError = null;
    });
    await _toggleTafseer();
  }

  // ── Toggle words / verse ──
  Future<void> _toggleWords() async {
    if (_activeView == _ActiveView.words) {
      setState(() => _activeView = _ActiveView.verse);
      return;
    }

    if (_words != null) {
      setState(() => _activeView = _ActiveView.words);
      return;
    }

    setState(() {
      _activeView = _ActiveView.words;
      _wordsLoading = true;
      _wordsError = null;
    });

    try {
      final url = Uri.parse(
        'https://api.quran.com/api/v4/verses/by_key/'
        '${widget.surah}:${widget.verse.number}?words=true&word_fields=text_uthmani,transliteration&word_translation_language=en',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final wordsList =
            (data['verse'] as Map<String, dynamic>?)?['words'] as List<dynamic>? ?? [];
        setState(() {
          _words = wordsList;
          _wordsLoading = false;
        });
      } else {
        setState(() {
          _wordsError = 'خطأ في الاتصال (${response.statusCode})';
          _wordsLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _wordsError = 'تعذّر تحميل ترجمة الكلمات.';
        _wordsLoading = false;
      });
    }
  }

  Future<void> _retryWords() async {
    setState(() {
      _words = null;
      _wordsError = null;
    });
    await _toggleWords();
  }

  // ── Toggle meaning / verse ──
  Future<void> _toggleMeaning() async {
    if (_activeView == _ActiveView.meaning) {
      setState(() => _activeView = _ActiveView.verse);
      return;
    }

    if (_meaningText != null) {
      setState(() => _activeView = _ActiveView.meaning);
      return;
    }

    setState(() {
      _activeView = _ActiveView.meaning;
      _meaningLoading = true;
      _meaningError = null;
    });

    try {
      final url = Uri.parse(
        'https://quranenc.com/api/v1/translation/aya/arabic_seraj/'
        '${widget.surah}/${widget.verse.number}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text =
            (data['result'] as Map<String, dynamic>?)?['translation'] as String? ?? '';
        setState(() {
          _meaningText = text;
          _meaningLoading = false;
        });
      } else {
        setState(() {
          _meaningError = 'خطأ في الاتصال (${response.statusCode})';
          _meaningLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _meaningError = 'تعذّر تحميل معاني الكلمات.';
        _meaningLoading = false;
      });
    }
  }

  Future<void> _retryMeaning() async {
    setState(() {
      _meaningText = null;
      _meaningError = null;
    });
    await _toggleMeaning();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 340,
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Scaffold(
                backgroundColor: colorScheme.surface,
                // ── Fixed bottom actions ──
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      // ── Tafseer toggle button ──
                      _ActionButton(
                        icon: _activeView == _ActiveView.tafseer
                            ? Icons.menu_book_outlined
                            : Icons.auto_stories_outlined,
                        label: _activeView == _ActiveView.tafseer ? 'الآية' : 'تفسير',
                        isSelected: _activeView == _ActiveView.tafseer,
                        onTap: _toggleTafseer,
                      ),
                      _ActionButton(
                        icon: Icons.library_books_outlined,
                        label: _activeView == _ActiveView.meaning ? 'الآية' : 'معاني ك',
                        isSelected: _activeView == _ActiveView.meaning,
                        onTap: _toggleMeaning,
                      ),
                      _ActionButton(
                        icon: Icons.translate_outlined,
                        label: _activeView == _ActiveView.words ? 'الآية' : 'ترجمة',
                        isSelected: _activeView == _ActiveView.words,
                        onTap: _toggleWords,
                      ),
                      _BookmarkActionButton(
                        isBookmarked: isBookmarked,
                        currentCategory: currentCategory,
                        categories: categories,
                        onCategorySelected: (cat) => _onCategorySelected(context, cat),
                        onRemove: () => _onRemoveBookmark(context),
                      ),
                    ],
                  ),
                ),
                // ── Body ──
                body: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: switch (_activeView) {
                          _ActiveView.verse => _buildVerseBody(context, colorScheme),
                          _ActiveView.tafseer => _buildTafseerBody(context, colorScheme),
                          _ActiveView.words => _buildWordsBody(context, colorScheme),
                          _ActiveView.meaning => _buildMeaningBody(context, colorScheme),
                        },
                      ),
                    ),
                    // ── Note preview (only when showing verse) ──
                    if (_activeView == _ActiveView.verse &&
                        (bookmark?.note?.isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer.applyOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              right: BorderSide(
                                color: colorScheme.tertiary.applyOpacity(0.5),
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.sticky_note_2_outlined,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  bookmark!.note!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Verse body (default view) ──
  Widget _buildVerseBody(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      key: const ValueKey('verse'),
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          widget.verse.text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, height: 2, color: colorScheme.onSurface),
        ),
      ),
    );
  }

  // ── Tafseer body ──
  Widget _buildTafseerBody(BuildContext context, ColorScheme colorScheme) {
    if (_tafseerLoading) {
      return const SizedBox(
        key: ValueKey('tafseer-loading'),
        width: double.infinity,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_tafseerError != null) {
      return SizedBox(
        key: const ValueKey('tafseer-error'),
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: colorScheme.onSurfaceVariant.applyOpacity(0.4),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _tafseerError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _retryTafseer,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Tafseer text ──
    return SizedBox(
      key: const ValueKey('tafseer-text'),
      width: double.infinity,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'من كتاب التفسير الميسر',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                _tafseerText ?? '',
                style: TextStyle(fontSize: 14, height: 1.9, color: colorScheme.onSurface),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Words body ──
  Widget _buildWordsBody(BuildContext context, ColorScheme colorScheme) {
    if (_wordsLoading) {
      return const SizedBox(
        key: ValueKey('words-loading'),
        width: double.infinity,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_wordsError != null) {
      return SizedBox(
        key: const ValueKey('words-error'),
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: colorScheme.onSurfaceVariant.applyOpacity(0.4),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _wordsError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(onPressed: _retryWords, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    final words = _words?.where((w) => w['char_type_name'] != 'end').toList() ?? [];

    return SizedBox(
      key: const ValueKey('words-text'),
      width: double.infinity,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: words.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: colorScheme.outlineVariant.applyOpacity(0.5)),
        itemBuilder: (context, index) {
          final word = words[index];
          final arabic = word['text_uthmani'] as String? ?? '';
          final translation = word['translation']?['text'] as String? ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    arabic,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Text(
                    translation,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Meaning body ──
  Widget _buildMeaningBody(BuildContext context, ColorScheme colorScheme) {
    if (_meaningLoading) {
      return const SizedBox(
        key: ValueKey('meaning-loading'),
        width: double.infinity,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_meaningError != null) {
      return SizedBox(
        key: const ValueKey('meaning-error'),
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: colorScheme.onSurfaceVariant.applyOpacity(0.4),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _meaningError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _retryMeaning,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      key: const ValueKey('meaning-text'),
      width: double.infinity,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'من "موسوعة القرآن الكريم"',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                (_meaningText != null && _meaningText!.trim().isNotEmpty)
                    ? _meaningText!
                    : 'لايوجد أي تفسير للكلمات',
                style: TextStyle(fontSize: 16, height: 1.8, color: colorScheme.onSurface),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.menu_book,
              size: 18,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: FontFamily.rustam.name,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              child: Row(
                children: [
                  Text(Quran.instance.getSurahNameArabic(widget.surah)),
                  const Text(' - '),
                  const Text('الآية '),
                  Text(
                    getArabicNumber(widget.verse.number),
                    style: TextStyle(fontFamily: FontFamily.arabicNumbersFontFamily.name),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () => _copyVerse(context),
            tooltip: 'نسخ',
          ),
          IconButton(
            icon: Icon(
              (bookmark?.note?.isNotEmpty ?? false)
                  ? Icons.edit_note
                  : Icons.note_add_outlined,
              size: 22,
              color: (bookmark?.note?.isNotEmpty ?? false)
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () => _onNoteTap(context),
            tooltip: 'ملاحظة',
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────

  Future<void> _onCategorySelected(BuildContext context, BookmarkCategory cat) async {
    if (isBookmarked) {
      final updated = bookmark!.copyWith(categoryId: () => cat.id);
      await bookmarkService.updateBookmark(updated);
      setState(() {
        bookmark = updated;
        _syncCategory();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تم النقل إلى "${cat.title}" ✓')));
      }
    } else {
      final newBookmark = VerseBookmark(
        id:
            '${widget.surah}_${widget.verse.number}_'
            '${DateTime.now().millisecondsSinceEpoch}',
        surah: widget.surah,
        verse: widget.verse.number,
        pageNumber: Quran.instance.getPageNumber(widget.surah, widget.verse.number),
        createdAt: DateTime.now(),
        categoryId: cat.id,
      );
      await bookmarkService.addBookmark(newBookmark);
      setState(() {
        isBookmarked = true;
        bookmark = newBookmark;
        _syncCategory();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تمت إضافة العلامة ✓')));
      }
    }
  }

  Future<void> _onRemoveBookmark(BuildContext context) async {
    await bookmarkService.removeBookmarkByVerse(widget.surah, widget.verse.number);
    setState(() {
      isBookmarked = false;
      bookmark = null;
      currentCategory = null;
    });
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تمت إزالة العلامة')));
    }
  }

  Future<void> _onNoteTap(BuildContext context) async {
    final result = await showEditNoteDialog(context, bookmark);
    if (result == null) return;

    final updatedNote = result == '\x00'
        ? null
        : (result.trim().isEmpty ? null : result.trim());

    if (isBookmarked) {
      final updated = bookmark!.copyWith(note: () => updatedNote);
      await bookmarkService.updateBookmark(updated);
      setState(() => bookmark = updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updatedNote == null ? 'تم حذف الملاحظة' : 'تم حفظ الملاحظة ✓'),
          ),
        );
      }
    } else {
      final newBookmark = VerseBookmark(
        id:
            '${widget.surah}_${widget.verse.number}_'
            '${DateTime.now().millisecondsSinceEpoch}',
        surah: widget.surah,
        verse: widget.verse.number,
        pageNumber: Quran.instance.getPageNumber(widget.surah, widget.verse.number),
        createdAt: DateTime.now(),
        categoryId: _defaultCategoryId,
        note: updatedNote,
      );
      await bookmarkService.addBookmark(newBookmark);
      setState(() {
        isBookmarked = true;
        bookmark = newBookmark;
        _syncCategory();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تمت إضافة العلامة ✓')));
      }
    }
  }

  void _copyVerse(BuildContext context) {
    final surahName = Quran.instance.getSurahNameArabic(widget.surah);
    final verseInPlainText = Quran.instance.getVerseInPlainText(
      widget.surah,
      widget.verse.number,
    );
    final textToCopy =
        'سورة $surahName - الآية {${getArabicNumber(widget.verse.number)}}\n'
        '"$verseInPlainText"\n';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم النسخ إلى الحافظة')));
  }
}

// ─────────────────────────────────────────────────────────
// Compact action button
// ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            decoration: isSelected
                ? BoxDecoration(
                    color: colorScheme.primaryContainer.applyOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  )
                : null,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: isSelected ? colorScheme.primary : null),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : null,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Bookmark button with color picker popup
// ─────────────────────────────────────────────────────────

class _BookmarkActionButton extends StatelessWidget {
  const _BookmarkActionButton({
    required this.isBookmarked,
    required this.currentCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.onRemove,
  });

  final bool isBookmarked;
  final BookmarkCategory? currentCategory;
  final List<BookmarkCategory> categories;
  final ValueChanged<BookmarkCategory> onCategorySelected;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = currentCategory?.color ?? Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showColorPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 22,
                color: isBookmarked ? color : null,
              ),
              const SizedBox(height: 4),
              Text(
                isBookmarked ? 'تعديل' : 'علامة',
                style: TextStyle(
                  fontSize: 11,
                  color: isBookmarked ? color : Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final itemCount = categories.length + (isBookmarked ? 2 : 0);
    final menuHeight = itemCount * 44.0 + 16.0;
    final topPosition = (offset.dy - menuHeight).clamp(8.0, screenHeight - 48);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        topPosition,
        offset.dx + size.width,
        offset.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        ...categories.map((cat) {
          final isSelected = isBookmarked && currentCategory?.id == cat.id;
          return PopupMenuItem<String>(
            value: cat.id,
            height: 44,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 2,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cat.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          );
        }),
        if (isBookmarked) ...[
          const PopupMenuItem<String>(enabled: false, height: 8, child: Divider(height: 1)),
          PopupMenuItem<String>(
            value: '__remove__',
            height: 44,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark_remove_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'إزالة العلامة',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ).then((value) {
      if (value == null) return;
      if (value == '__remove__') {
        onRemove();
        return;
      }
      try {
        final cat = categories.firstWhere((c) => c.id == value);
        if (isBookmarked && currentCategory?.id == cat.id) return;
        onCategorySelected(cat);
      } catch (_) {}
    });
  }
}
