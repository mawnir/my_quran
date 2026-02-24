import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_quran/app/services/audio_service.dart';

class AudioPlayerSheet extends StatefulWidget {
  const AudioPlayerSheet({super.key});

  @override
  State<AudioPlayerSheet> createState() => _AudioPlayerSheetState();
}

class _AudioPlayerSheetState extends State<AudioPlayerSheet> {
  final AudioService _audioService = AudioService.instance;

  @override
  void initState() {
    super.initState();
    _audioService.init();
    _audioService.loadAudioForCurrentSurah();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final player = _audioService.player;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Title Area
          ValueListenableBuilder<AudioMetadata?>(
            valueListenable: _audioService.metadata,
            builder: (context, metadata, _) {
              return Column(
                children: [
                  Text(
                    metadata?.surahName ?? 'Quran Recitation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metadata != null
                        ? '${metadata.arabicName} (آية ${metadata.verseNumber})'
                        : 'Surah Al-Baqarah',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          // Position Slider
          StreamBuilder<PositionData>(
            stream: _audioService.positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: positionData?.duration.inMilliseconds.toDouble() ?? 0.0,
                      value:
                          positionData?.position.inMilliseconds.toDouble().clamp(
                            0,
                            positionData.duration.inMilliseconds.toDouble(),
                          ) ??
                          0.0,
                      onChanged: (value) {
                        player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(positionData?.position ?? Duration.zero),
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                        Text(
                          _formatDuration(positionData?.duration ?? Duration.zero),
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Playback Speed
              StreamBuilder<double>(
                stream: player.speedStream,
                builder: (context, snapshot) {
                  final speed = snapshot.data ?? 1.0;
                  return InkWell(
                    onTap: () => _showSpeedDialog(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${speed}x',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Backward 10s
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {
                  final newPos = player.position - const Duration(seconds: 10);
                  player.seek(newPos < Duration.zero ? Duration.zero : newPos);
                },
              ),
              // Play/Pause Button
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return const SizedBox(
                      width: 64,
                      height: 64,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    );
                  } else if (playing != true) {
                    return IconButton(
                      icon: const Icon(Icons.play_circle_fill),
                      iconSize: 64,
                      color: colorScheme.primary,
                      onPressed: player.play,
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      icon: const Icon(Icons.pause_circle_filled),
                      iconSize: 64,
                      color: colorScheme.primary,
                      onPressed: player.pause,
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.replay_circle_filled),
                      iconSize: 64,
                      color: colorScheme.primary,
                      onPressed: () => player.seek(Duration.zero),
                    );
                  }
                },
              ),
              // Forward 10s
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  final newPos = player.position + const Duration(seconds: 10);
                  player.seek(newPos);
                },
              ),
              const SizedBox(width: 48), // Balancing the speed button
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    final player = _audioService.player;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Playback Speed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                return ListTile(
                  title: Text('${speed}x'),
                  trailing: player.speed == speed ? const Icon(Icons.check) : null,
                  onTap: () {
                    player.setSpeed(speed);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }
}
