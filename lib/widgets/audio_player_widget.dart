// lib/widgets/audio_player_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../config/api_config.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool isMe;
  final int? durationInSeconds;
  final int? messageId; // ✅ for unique waveform per message

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.isMe = false,
    this.durationInSeconds,
    this.messageId,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // ✅ Waveform bar heights (generated per message)
  late List<double> _barHeights;
  static const int _totalBars = 28;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _generateBarHeights();
    _setupListeners();
  }

  // ✅ Generate unique waveform per message using messageId as seed
  void _generateBarHeights() {
    final seed = widget.messageId ?? widget.audioUrl.hashCode;
    final random = Random(seed);
    _barHeights = List.generate(
      _totalBars,
          (_) => 6 + random.nextInt(20).toDouble(), // 6 to 26
    );
  }

  void _setupListeners() {
    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _player.durationStream.listen((dur) {
      if (mounted && dur != null) setState(() => _duration = dur);
    });

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;

          if (state.processingState == ProcessingState.completed) {
            _player.seek(Duration.zero);
            _player.pause();
          }
        });
      }
    });
  }

  Future<void> _togglePlay() async {
    try {
      if (!_isInitialized) {
        setState(() => _isLoading = true);

        // ✅ Prefix base URL if relative
        final String fullUrl = widget.audioUrl.startsWith('http')
            ? widget.audioUrl
            : '${ApiConfig.baseUrl}${widget.audioUrl}';

        print('🎵 Playing audio from: $fullUrl');

        await _player.setUrl(fullUrl);
        _isInitialized = true;
        setState(() => _isLoading = false);
      }

      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e) {
      print('❌ Audio error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Colors
    final primaryColor = widget.isMe ? Colors.white : Colors.black;
    final fadedColor = widget.isMe
        ? Colors.white.withOpacity(0.35)
        : Colors.black.withOpacity(0.25);

    // ✅ Progress
    final totalMs = _duration.inMilliseconds > 0
        ? _duration.inMilliseconds
        : (widget.durationInSeconds ?? 0) * 1000;
    final progress = totalMs > 0
        ? (_position.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 0.0;

    final playedBars = (progress * _totalBars).floor();

    final displayDuration = _duration.inSeconds > 0
        ? _duration
        : Duration(seconds: widget.durationInSeconds ?? 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Play / Pause button
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? Padding(
                padding: const EdgeInsets.all(9.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.isMe ? Colors.black : Colors.white,
                ),
              )
                  : Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isMe ? Colors.black : Colors.white,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ✅ Waveform + duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Waveform bars
                SizedBox(
                  height: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(_totalBars, (index) {
                      final isPlayed = index < playedBars;
                      final barHeight = _barHeights[index];

                      // ✅ Animate bar height while playing
                      final animatedHeight = _isPlaying && isPlayed
                          ? barHeight * (0.85 + Random().nextDouble() * 0.3)
                          : barHeight;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        width: 2.5,
                        height: animatedHeight.clamp(4.0, 28.0),
                        decoration: BoxDecoration(
                          color: isPlayed ? primaryColor : fadedColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 6),

                // ✅ Duration row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _position.inSeconds > 0
                          ? _formatDuration(_position)
                          : _formatDuration(displayDuration),
                      style: TextStyle(
                        fontSize: 10,
                        color: primaryColor.withOpacity(0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.mic,
                      size: 12,
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}