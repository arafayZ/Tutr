// lib/widgets/audio_recorder_widget.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_recorder_service.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Function(File file, int duration) onSend;
  final VoidCallback onCancel;

  const AudioRecorderWidget({
    super.key,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorderService _recorder = AudioRecorderService();
  final AudioPlayer _previewPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _hasRecording = false;
  bool _isPlayingPreview = false;
  int _recordDuration = 0;
  Timer? _timer;
  File? _recordedFile;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _previewPlayer.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    // Request permission
    final hasPermission = await _recorder.requestPermissions();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required'),
            backgroundColor: Colors.red,
          ),
        );
        widget.onCancel();
      }
      return;
    }

    try {
      await _recorder.startRecording();
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });

      // Timer for duration
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (mounted) setState(() => _recordDuration++);
      });
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) widget.onCancel();
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();

    try {
      final file = await _recorder.stopRecording();
      if (file != null) {
        setState(() {
          _isRecording = false;
          _hasRecording = true;
          _recordedFile = file;
        });
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _playPreview() async {
    if (_recordedFile == null) return;

    try {
      if (_isPlayingPreview) {
        await _previewPlayer.pause();
        setState(() => _isPlayingPreview = false);
      } else {
        await _previewPlayer.setFilePath(_recordedFile!.path);
        await _previewPlayer.play();
        setState(() => _isPlayingPreview = true);

        _previewPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) setState(() => _isPlayingPreview = false);
            _previewPlayer.seek(Duration.zero);
          }
        });
      }
    } catch (e) {
      print('Error preview: $e');
    }
  }

  Future<void> _cancel() async {
    _timer?.cancel();
    await _recorder.cancelRecording();
    widget.onCancel();
  }

  void _send() {
    if (_recordedFile != null && _recordDuration > 0) {
      widget.onSend(_recordedFile!, _recordDuration);
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Cancel button
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: _cancel,
        ),

        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isRecording ? Colors.red.shade200 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                // Recording indicator
                if (_isRecording)
                  const Icon(Icons.circle, color: Colors.red, size: 12)
                else
                  Icon(Icons.mic, color: Colors.grey.shade600, size: 16),

                const SizedBox(width: 8),

                // Duration
                Text(
                  _formatTime(_recordDuration),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _isRecording ? Colors.red : Colors.black87,
                  ),
                ),

                const Spacer(),

                // Preview play button (after recording)
                if (_hasRecording && !_isRecording)
                  IconButton(
                    icon: Icon(
                      _isPlayingPreview
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.black,
                      size: 32,
                    ),
                    onPressed: _playPreview,
                  ),

                // Stop button (while recording)
                if (_isRecording)
                  IconButton(
                    icon: const Icon(Icons.stop_circle,
                        color: Colors.red, size: 32),
                    onPressed: _stopRecording,
                  ),
              ],
            ),
          ),
        ),

        // Send button
        IconButton(
          icon: Icon(
            Icons.send_rounded,
            color: _hasRecording ? Colors.green : Colors.grey,
            size: 28,
          ),
          onPressed: _hasRecording ? _send : null,
        ),
      ],
    );
  }
}