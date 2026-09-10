// lib/services/audio_recorder_service.dart
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  static final AudioRecorderService _instance = AudioRecorderService._internal();
  factory AudioRecorderService() => _instance;
  AudioRecorderService._internal();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderOpen = false;
  String? _filePath;
  DateTime? _startTime;

  bool get isRecording => _recorder.isRecording;

  // ✅ Initialize recorder
  Future<void> init() async {
    if (_isRecorderOpen) return;
    await _recorder.openRecorder();
    _isRecorderOpen = true;
  }

  // ✅ Request permissions
  Future<bool> requestPermissions() async {
    final micStatus = await Permission.microphone.request();
    return micStatus.isGranted;
  }

  // ✅ Start recording
  Future<void> startRecording() async {
    if (!_isRecorderOpen) {
      await init();
    }

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _filePath = '${directory.path}/audio_$timestamp.aac';

      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
        bitRate: 64000,
        sampleRate: 44100,
      );

      _startTime = DateTime.now();
      print('🎙️ Recording started: $_filePath');
    } catch (e) {
      print('❌ Error starting recording: $e');
      rethrow;
    }
  }

  // ✅ Stop recording and return file
  Future<File?> stopRecording() async {
    if (!_recorder.isRecording) return null;

    try {
      final path = await _recorder.stopRecorder();
      print('🎙️ Recording stopped: $path');

      if (path != null) {
        return File(path);
      }
      return null;
    } catch (e) {
      print('❌ Error stopping recording: $e');
      return null;
    }
  }

  // ✅ Get recorded duration
  int getDuration() {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  // ✅ Cancel recording
  Future<void> cancelRecording() async {
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
    if (_filePath != null) {
      try {
        final file = File(_filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting file: $e');
      }
      _filePath = null;
    }
    _startTime = null;
  }

  // ✅ Dispose
  Future<void> dispose() async {
    if (_isRecorderOpen) {
      await _recorder.closeRecorder();
      _isRecorderOpen = false;
    }
  }
}