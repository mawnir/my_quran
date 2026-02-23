class VerseLocation {
  // Word position in verse

  VerseLocation({
    required this.surah,
    required this.verse,
    required this.position,
  });

  factory VerseLocation.fromJson(Map<String, dynamic> json) => VerseLocation(
    surah: json['surah'] as int,
    verse: json['verse'] as int,
    position: json['position'] as int,
  );
  final int surah;
  final int verse;
  final int position;

  Map<String, dynamic> toJson() => {
    'surah': surah,
    'verse': verse,
    'position': position,
  };
}

class SearchResult {
  SearchResult({required this.surah, required this.verse});
  final int surah;
  final int verse;
}
