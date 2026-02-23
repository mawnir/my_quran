import 'package:my_quran/quran/quran.dart';

/// Calculates the scroll alignment needed to bring a specific verse into view.
double getVerseAlignmentOnPage({
  required int pageNumber,
  required int highlightSurah,
  required int highlightVerse,
}) {
  final pageData = Quran.instance.getPageData(pageNumber);
  if (pageData.isEmpty) return 0;

  int totalVersesOnPage = 0;
  int targetVerseIndex = -1; // Use -1 to indicate not found

  for (final seg in pageData) {
    final sNum = seg['surah']!;
    final start = seg['start']!;
    final end = seg['end']!;
    final len = end - start + 1;

    if (targetVerseIndex == -1 && sNum == highlightSurah) {
      if (highlightVerse >= start && highlightVerse <= end) {
        targetVerseIndex = totalVersesOnPage + (highlightVerse - start);
      }
    }
    totalVersesOnPage += len;
  }

  if (targetVerseIndex != -1 && totalVersesOnPage > 0) {
    final ratio = targetVerseIndex / totalVersesOnPage;
    // If the verse is in the bottom half of the page's content,
    // provide a slight negative alignment. This scrolls the page up a bit,
    // bringing the target verse more towards the center of the screen.
    if (ratio > 0.5) {
      return -0.1;
    }
  }

  return 0; // Default alignment
}
