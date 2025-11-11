import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class AudioRecordService {
  final RecorderController recorderController = RecorderController();

  /// Initialize recorder with proper configuration
  Future<void> initialize() async {
    recorderController.updateFrequency = Duration(milliseconds: 100);
    recorderController.androidEncoder = AndroidEncoder.aac;
    recorderController.androidOutputFormat = AndroidOutputFormat.mpeg4;
    recorderController.iosEncoder = IosEncoder.kAudioFormatMPEG4AAC;
    recorderController.sampleRate = 44100;
  }

  /// Start recording with a valid file path
  Future<String?> startRecording() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = "voice_${DateTime.now().millisecondsSinceEpoch}.m4a";
      final filePath = p.join(dir.path, fileName);

      await recorderController.record(path: filePath);
      print("🎙 Recording started: $filePath");
      return filePath;
    } catch (e) {
      print("❌ Error starting recording: $e");
      return null;
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      final path = await recorderController.stop();
      print("✅ Recording saved at: $path");
      return path;
    } catch (e) {
      print("❌ Error stopping recording: $e");
      return null;
    }
  }

  /// Delete audio file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print("🗑 Audio deleted: $filePath");
        return true;
      } else {
        print("⚠ File not found: $filePath");
        return false;
      }
    } catch (e) {
      print("❌ Error deleting file: $e");
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    recorderController.dispose();
  }
}
