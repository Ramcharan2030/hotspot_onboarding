import 'package:camera/camera.dart';

class VideoRecorderService {
  CameraController? _controller;

  Future<void> initCamera(CameraDescription cameraDescription) async {
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
    await _controller!.initialize();
  }

  CameraController? get controller => _controller;

  /// Start video recording. The `CameraController` will manage the file path
  /// and return it when stopped.
  Future<void> startRecording() async {
    if (_controller == null) throw StateError('Camera not initialized');
    // startVideoRecording doesn't take a path in newer camera versions;
    // stopVideoRecording returns an XFile with the path.
    await _controller!.startVideoRecording();
  }

  /// Stop video recording and return the recorded file path (or null).
  Future<String?> stopRecording() async {
    if (_controller != null && _controller!.value.isRecordingVideo) {
      final XFile file = await _controller!.stopVideoRecording();
      return file.path;
    }
    return null;
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
