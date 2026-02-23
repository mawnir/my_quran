import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:my_quran/quran/data/rayan_moh_aud.dart';
import 'package:rxdart/rxdart.dart';

class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  int? _currentSurahId;
  bool _isInitialized = false;

  final ValueNotifier<AudioMetadata?> metadata = ValueNotifier(null);

  /// Updates only the UI labels (surah name, verse number).
  /// Called on every scroll — does NOT touch the audio source.
  void updateMetadata({
    required int surahNumber,
    required int verseNumber,
    required String surahName,
    required String arabicName,
  }) {
    metadata.value = AudioMetadata(
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      surahName: surahName,
      arabicName: arabicName,
    );
  }

  /// Loads the correct audio source based on the current metadata.
  /// Call this only when the user explicitly opens the player sheet.
  Future<void> loadAudioForCurrentSurah() async {
    final meta = metadata.value;
    if (meta == null) return;

    final surahNumber = meta.surahNumber;
    if (_currentSurahId == surahNumber) return;

    _currentSurahId = surahNumber;

    final audioData = surahAudio.firstWhere(
      (s) => s['id'] == surahNumber,
      orElse: () => surahAudio.first,
    );

    final url = audioData['audio'] as String;

    try {
      debugPrint('AudioService: Loading Surah $surahNumber ($url)');
      await _player.stop();
      await _player.setUrl(url);
    } catch (e) {
      debugPrint("Error loading audio for surah $surahNumber: $e");
      _currentSurahId = null; // Allow retry
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _isInitialized = true;

    // Initial load will happen via updateMetadata call from HomePage
  }

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  void dispose() {
    _player.dispose();
  }
}

class AudioMetadata {
  final int surahNumber;
  final int verseNumber;
  final String surahName;
  final String arabicName;

  AudioMetadata({
    required this.surahNumber,
    required this.verseNumber,
    required this.surahName,
    required this.arabicName,
  });
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
