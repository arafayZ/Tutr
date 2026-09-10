// lib/services/audio_player_service.dart
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  String? _currentAudioUrl;

  bool get isPlaying => _player.playing;
  bool get isBuffering => _player.processingState == ProcessingState.buffering;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  double get progress => duration.inMilliseconds > 0
      ? position.inMilliseconds / duration.inMilliseconds
      : 0.0;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<bool> get bufferingStream => _player.processingStateStream.map(
        (state) => state == ProcessingState.buffering,
  );

  Future<void> play(String audioUrl) async {
    try {
      if (_currentAudioUrl != audioUrl) {
        _currentAudioUrl = audioUrl;
        await _player.setUrl(audioUrl);
      }
      await _player.play();
    } catch (e) {
      print('❌ Error playing audio: $e');
      rethrow;
    }
  }

  void pause() {
    _player.pause();
  }

  void resume() {
    _player.play();
  }

  void stop() {
    _player.stop();
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  void dispose() {
    _player.dispose();
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}