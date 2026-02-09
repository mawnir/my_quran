class Surah {
  const Surah({
    required this.arabicName,
    required this.id,
    required this.name,
    required this.revelationPlace,
    required this.verseCount,
  });

  final int id;
  final int verseCount;
  final String revelationPlace;
  final String name;
  final String arabicName;
}

typedef Verse = ({int number, String text});

class SurahInPage {
  const SurahInPage({required this.surahNumber, required this.verses});

  final int surahNumber;
  Verse? get firstVerse => verses.firstOrNull;
  Verse? get lastVerse => verses.lastOrNull;
  final List<Verse> verses;

  /// Returns true if this surah has Basmala.
  ///
  /// It will return false for "Al-Fatihah" and "At-Tawbah".
  bool get hasBasmala => surahNumber != 1 && surahNumber != 9;
  bool get isAlfatihah => surahNumber == 1;
}

class QuranPage {
  const QuranPage({required this.pageNumber, required this.surahs});
  final int pageNumber;
  final List<SurahInPage> surahs;
}

class PageLocation {
  PageLocation({
    required this.pageNumber,
    required this.surahNumber,
    required this.surahName,
  });
  final int pageNumber;
  final int surahNumber;
  final String surahName;
}

class ReadingPosition {
  const ReadingPosition({
    required this.pageNumber,
    required this.surahNumber,
    required this.verseNumber,
    required this.juzNumber,
  });
  factory ReadingPosition.fromJson(Map<String, dynamic> json) =>
      ReadingPosition(
        pageNumber: json['pageNumber'] as int,
        surahNumber: json['surahNumber'] as int,
        verseNumber: json['verseNumber'] as int,
        juzNumber: json['juzNumber'] as int,
      );
  final int pageNumber;
  final int surahNumber;
  final int verseNumber;
  final int juzNumber;

  @override
  String toString() =>
      'Page: $pageNumber, Surah: $surahNumber, Verse: $verseNumber, '
      'Juz: $juzNumber';

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'surahNumber': surahNumber,
    'verseNumber': verseNumber,
    'juzNumber': juzNumber,
  };
}

class VerseBookmark {
  // Optional user note

  VerseBookmark({
    required this.id,
    required this.surah,
    required this.verse,
    required this.pageNumber,
    required this.createdAt,
    this.note,
  });

  factory VerseBookmark.fromJson(Map<String, dynamic> json) => VerseBookmark(
    id: json['id'] as String,
    surah: json['surah'] as int,
    verse: json['verse'] as int,
    pageNumber: json['pageNumber'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    note: json['note'] as String?,
  );
  final String id;
  final int surah;
  final int verse;
  final int pageNumber;
  final DateTime createdAt;
  final String? note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'surah': surah,
    'verse': verse,
    'pageNumber': pageNumber,
    'createdAt': createdAt.toIso8601String(),
    'note': note,
  };

  String get verseKey => '$surah:$verse';
}

enum FontFamily {
  hafs,
  rustam,
  warsh,
  scheherazade;

  static FontFamily get defaultFontFamily => hafs;
  static FontFamily get arabicNumbersFontFamily => scheherazade;

  bool get isHafs => this == hafs;
  bool get isWarsh => this == warsh;

  String get name {
    return switch (this) {
      FontFamily.hafs => 'Hafs',
      FontFamily.rustam => 'Rustam',
      FontFamily.scheherazade => 'Scheherazade',
      FontFamily.warsh => 'Warsh',
    };
  }
}
