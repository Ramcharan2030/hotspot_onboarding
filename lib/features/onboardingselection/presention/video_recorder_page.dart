import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hottspot_onboarding/features/onboardingselection/data/video_record_service.dart';

class VideoRecorderPage extends StatefulWidget {
  const VideoRecorderPage({super.key});

  @override
  State<VideoRecorderPage> createState() => _VideoRecorderPageState();
}

class _VideoRecorderPageState extends State<VideoRecorderPage> {
  final VideoRecorderService _service = VideoRecorderService();
  CameraDescription? _camera;
  bool _isInitialized = false;
  bool _isRecording = false;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _camera = cameras.first;
        await _service.initCamera(_camera!);
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _service.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_isInitialized) return;
    try {
      await _service.startRecording();
      setState(() {
        _isRecording = true;
        _seconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
      });
    } catch (e) {
      // ignore: avoid_print
      print('Start video recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _service.stopRecording();
      _timer?.cancel();
      setState(() => _isRecording = false);
      // return path to caller (ensure widget still mounted)
      if (!mounted) return;
      Navigator.of(context).pop(path);
    } catch (e) {
      // ignore: avoid_print
      print('Stop video recording error: $e');
      if (mounted) Navigator.of(context).pop(null);
    }
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Record Video', style: GoogleFonts.inter()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isInitialized && _service.controller != null
                    ? AspectRatio(
                        aspectRatio: _service.controller!.value.aspectRatio,
                        child: CameraPreview(_service.controller!),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _format(_seconds),
                    style: const TextStyle(color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_isRecording) {
                        await _startRecording();
                      } else {
                        await _stopRecording();
                      }
                    },
                    child: Text(_isRecording ? 'Stop' : 'Record'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
