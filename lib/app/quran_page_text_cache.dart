import 'package:flutter/foundation.dart';

import 'package:my_quran/app/models.dart';
import 'package:my_quran/quran/quran.dart';

@immutable
class VerseSegment {
  const VerseSegment({
    required this.verse,
    required this.text,
    required this.symbolText,
    required this.start, // inclusive in the final paragraph text
    required this.end, // exclusive
  });

  final int verse;
  final String text;
  final String symbolText;
  final int start;
  final int end;
}

@immutable
class SurahBlockText {
  const SurahBlockText({required this.surahNumber, required this.segments});

  final int surahNumber;
  final List<VerseSegment> segments; // in visual order
}

@immutable
class QuranPageTextModel {
  const QuranPageTextModel({
    required this.pageNumber,
    required this.surahs,
    required this.blocks,
  });

  final int pageNumber;
  final List<SurahInPage> surahs;
  final List<SurahBlockText> blocks; // same length/order as surahs
}

class QuranPageTextCache {
  QuranPageTextCache._();
  static final instance = QuranPageTextCache._();

  // Bump this when Quran.data changes (i.e., switching JSON dataset).
  int _revision = 0;

  // LRU: key = (revision, pageNumber)
  final _lru = <({int rev, int page}), QuranPageTextModel>{};
  final int maxEntries = 30;

  void invalidateForNewQuranData() {
    _revision++;
    _lru.clear();
  }

  QuranPageTextModel get(int pageNumber) {
    final key = (rev: _revision, page: pageNumber);

    final cached = _lru.remove(key);
    if (cached != null) {
      _lru[key] = cached;
      return cached;
    }

    final built = _build(pageNumber);
    _lru[key] = built;

    while (_lru.length > maxEntries) {
      _lru.remove(_lru.keys.first);
    }
    return built;
  }

  QuranPageTextModel _build(int pageNumber) {
    final rawData = Quran.instance.getPageData(pageNumber);
    final surahs = <SurahInPage>[];

    for (final item in rawData) {
      final surahNum = item['surah']!;
      final start = item['start']!;
      final end = item['end']!;

      final verses = <Verse>[];
      for (int v = start; v <= end; v++) {
        verses.add((number: v, text: Quran.instance.getVerse(surahNum, v)));
      }
      surahs.add(SurahInPage(surahNumber: surahNum, verses: verses));
    }

    final blocks = <SurahBlockText>[];
    for (final surah in surahs) {
      blocks.add(_buildSurahBlockText(surah));
    }

    return QuranPageTextModel(
      pageNumber: pageNumber,
      surahs: surahs,
      blocks: blocks,
    );
  }

  SurahBlockText _buildSurahBlockText(SurahInPage surah) {
    final segments = <VerseSegment>[];
    var charCount = 0;

    for (final verse in surah.verses) {
      final start = charCount;

      final text = verse.text;
      charCount += text.length;

      // Put spaces here so they are part of the symbol span.
      final symbol = Quran.instance.getVerseEndSymbol(verse.number);
      final symbolText = ' $symbol '; // tweak spacing as you like
      charCount += symbolText.length;

      segments.add(
        VerseSegment(
          verse: verse.number,
          text: text,
          symbolText: symbolText,
          start: start,
          end: charCount,
        ),
      );
    }

    return SurahBlockText(surahNumber: surah.surahNumber, segments: segments);
  }
}
