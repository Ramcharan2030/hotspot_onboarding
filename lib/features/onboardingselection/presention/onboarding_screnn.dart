import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hottspot_onboarding/features/onboardingselection/presention/widgets/record_audio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';

import 'package:hottspot_onboarding/features/onboardingselection/data/video_record_service.dart';
import 'package:hottspot_onboarding/features/onboardingselection/presention/widgets/video_recorder_widget.dart';

import 'package:hottspot_onboarding/features/expericeneselction/presentaion/widgets/animate_wave.dart';
import 'package:hottspot_onboarding/features/onboardingselection/provider/on_boarding_provider.dart';
import 'package:hottspot_onboarding/core/widgets/zigzag_background.dart';

/// --- AUDIO BUTTON ---
class RecordAudioButton extends StatelessWidget {
  final VoidCallback onRecord;
  final VoidCallback? onDelete;
  final bool hasRecording;

  const RecordAudioButton({
    super.key,
    required this.onRecord,
    this.onDelete,
    required this.hasRecording,
  });

  @override
  Widget build(BuildContext context) {
    const Color kButtonColor = Color(0xFF1E1E1E);
    const Color kBorderColor = Color(0xFF2E2E2E);
    const Color kDeleteColor = Color(0xFFE53935);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: hasRecording ? 120 : 55,
      height: 55,
      decoration: BoxDecoration(
        color: hasRecording ? kDeleteColor.withAlpha(38) : kButtonColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasRecording ? kDeleteColor.withAlpha(204) : kBorderColor,
        ),
      ),
      child: InkWell(
        onTap: hasRecording ? onDelete : onRecord,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: hasRecording
                ? Row(
                    key: const ValueKey('delete'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, color: kDeleteColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          color: kDeleteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    key: ValueKey('record'),
                    Icons.mic,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}

/// --- VIDEO BUTTON ---
class RecordVideoButton extends StatelessWidget {
  final VoidCallback onRecord;
  final VoidCallback? onDelete;
  final bool hasRecording;

  const RecordVideoButton({
    super.key,
    required this.onRecord,
    this.onDelete,
    required this.hasRecording,
  });

  @override
  Widget build(BuildContext context) {
    const Color kButtonColor = Color(0xFF1E1E1E);
    const Color kBorderColor = Color(0xFF2E2E2E);
    const Color kDeleteColor = Color(0xFFE53935);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: hasRecording ? 120 : 55,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: hasRecording ? kDeleteColor.withAlpha(38) : kButtonColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasRecording ? kDeleteColor.withAlpha(204) : kBorderColor,
        ),
      ),
      child: InkWell(
        onTap: hasRecording ? onDelete : onRecord,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: hasRecording
                ? Row(
                    key: const ValueKey('delete'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, color: kDeleteColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          color: kDeleteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    key: ValueKey('record'),
                    Icons.videocam_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}

/// --- MAIN SCREEN ---
class OnboardingQuestionScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState
    extends ConsumerState<OnboardingQuestionScreen> {
  final FocusNode _focusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RecorderController _recorderController = RecorderController();
  final VideoRecorderService _videoService = VideoRecorderService();
  Duration? _audioDuration;

  @override
  void initState() {
    super.initState();
    // Initialize recorder with proper configuration
    _recorderController.updateFrequency = Duration(milliseconds: 100);
    _recorderController.androidEncoder = AndroidEncoder.aac;
    _recorderController.androidOutputFormat = AndroidOutputFormat.mpeg4;
    _recorderController.iosEncoder = IosEncoder.kAudioFormatMPEG4AAC;
    _recorderController.sampleRate = 44100;
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorderController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(
      dir.path,
      "voice_${DateTime.now().millisecondsSinceEpoch}.m4a",
    );

    await _recorderController.record(path: path);
    print("🎙 Recording started: $path");
  }

  Future<void> _stopRecording() async {
    final path = await _recorderController.stop();
    if (path != null) {
      print("✅ Audio saved at: $path");

      // Get duration using just_audio
      try {
        final player = AudioPlayer();
        await player.setFilePath(path);
        final duration = player.duration ?? Duration.zero;

        setState(() {
          _audioDuration = duration;
        });

        await player.dispose();
      } catch (e) {
        print("❌ Error getting duration: $e");
      }

      ref.read(onboardingProvider.notifier).stopAudioRecording(path);
    }
  }

  Future<void> _playRecording(String path) async {
    try {
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
      print("▶ Playing: $path");
    } catch (e) {
      print("❌ Playback error: $e");
    }
  }

  Future<void> _deleteVideoFile(String videoPath) async {
    try {
      print("🔍 Attempting to delete video: $videoPath");
      String normPath = videoPath;
      try {
        if (videoPath.startsWith('file://')) {
          normPath = Uri.parse(videoPath).toFilePath();
        }
      } catch (_) {}

      final file = File(normPath);
      final exists = await file.exists();
      print("📁 Normalized video path: $normPath | exists: $exists");

      if (exists) {
        await file.delete();
        print("✅ Video deleted: $normPath");
        setState(() {});
        return;
      }

      // fallback: try File.fromUri
      try {
        final alt = File.fromUri(Uri.parse(videoPath));
        final altExists = await alt.exists();
        print("📁 Alt path from uri: ${alt.path} | exists: $altExists");
        if (altExists) {
          await alt.delete();
          print("✅ Video deleted via URI: ${alt.path}");
          setState(() {});
          return;
        }
      } catch (_) {}

      print(
        "⚠️ Video file not found at provided path: $videoPath (normalized: $normPath)",
      );
      try {
        final dir = Directory(File(normPath).parent.path);
        final files = dir.existsSync() ? dir.listSync() : <FileSystemEntity>[];
        print("📂 Files in directory: ${files.map((f) => f.path).toList()}");
      } catch (e) {
        print("Could not list directory for video delete: $e");
      }
    } catch (e, st) {
      print("❌ Error deleting video: $e");
      print(st);
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "00:00";
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _deleteAudio(String audioPath) async {
    try {
      print("🔍 Attempting to delete: $audioPath");
      String normPath = audioPath;
      try {
        if (audioPath.startsWith('file://')) {
          normPath = Uri.parse(audioPath).toFilePath();
        }
      } catch (_) {
        // ignore parse errors and fall back to raw path
      }

      final file = File(normPath);
      final exists = await file.exists();
      print("📁 Normalized path: $normPath | exists: $exists");

      if (exists) {
        await file.delete();
        print("✅ Audio file deleted successfully: $normPath");
        setState(() {
          _audioDuration = null;
        });
      } else {
        // Try alternate strategies: treat as URI
        try {
          final alt = File.fromUri(Uri.parse(audioPath));
          final altExists = await alt.exists();
          print("📁 Alt path from uri: ${alt.path} | exists: $altExists");
          if (altExists) {
            await alt.delete();
            print("✅ Audio file deleted via URI: ${alt.path}");
            setState(() {
              _audioDuration = null;
            });
            return;
          }
        } catch (_) {}

        print("⚠️ File not found at path: $audioPath (normalized: $normPath)");
        try {
          final dir = Directory(File(normPath).parent.path);
          final files = dir.listSync();
          print("📂 Files in directory: ${files.map((f) => f.path).toList()}");
        } catch (e) {
          print("Could not list directory: $e");
        }
      }
    } catch (e, st) {
      print("❌ Error deleting audio file: $e");
      print(st);
    }
  }

  Future<void> _playVideoRecording(String path) async {
    if (path.isEmpty) return;

    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      controller.setLooping(false);
      await controller.play();

      // if the state was disposed while initializing/playing, abort
      if (!mounted) return;

      // show dialog with player
      await showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(12),
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(controller),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  VideoProgressIndicator(controller, allowScrubbing: true),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('❌ Error playing video: $e');
    } finally {
      try {
        await controller?.pause();
        await controller?.dispose();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    // Figma Colors
    const Color kBackgroundColor = Color(0xFF0B0B0B);
    const Color kFieldBackgroundColor = Color(0xFF121212);
    const Color kFieldBorderColor = Color(0xFF222222);
    const Color kFieldBorderActiveColor = Color(0xFF448AFF);
    const Color kHintTextColor = Color(0xFF6B6B6B);
    const Color kButtonDisabledColor = Color(0xFF1A1A1A);
    const Color kButtonEnabledColor = Color(0xFF2E2E2E);
    const Color kHeaderTextColor = Color(0xFF8E8E8E);
    const Color kSubHeaderTextColor = Color(0xFFC2C2C2);
    const Color kRecordingWidgetColor = Color(0xFF1C1C1E);

    final bool isButtonEnabled =
        state.answerText.isNotEmpty ||
        state.audioPath != null ||
        state.videoPath != null;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const CurvedWaveProgressHeader(progress: 0.66),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ZigzagBackground(
        backgroundColor: kBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Text(
                  '02',
                  style: GoogleFonts.inter(
                    color: kHeaderTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Why do you want to host with us?',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tell us about your intent and what motivates you to create experiences.',
                  style: GoogleFonts.inter(
                    color: kSubHeaderTextColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // --- Dynamic Section ---
                if (state.isRecordingAudio)
                  RecordAudioWidget(
                    recorderController: _recorderController,
                    onStop: () async {
                      await _stopRecording();
                      setState(() {});
                    },
                    onCancel: () async {
                      await _recorderController.stop();
                      ref.read(onboardingProvider.notifier).deleteAudio();
                      setState(() {});
                    },
                  )
                else if (state.isRecordingVideo)
                  VideoRecorderWidget(
                    videoService: _videoService,
                    isRecording: state.isRecordingVideo,
                    width: MediaQuery.of(context).size.width,
                    onStop: () async {
                      try {
                        final recordedPath = await _videoService
                            .stopRecording();
                        await _videoService.dispose();
                        if (recordedPath != null) {
                          ref
                              .read(onboardingProvider.notifier)
                              .stopVideoRecording(recordedPath);
                        } else {
                          ref.read(onboardingProvider.notifier).deleteVideo();
                        }
                      } catch (e) {
                        print('❌ Error stopping video: $e');
                        ref.read(onboardingProvider.notifier).deleteVideo();
                      }
                      setState(() {});
                    },
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: kFieldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? kFieldBorderActiveColor
                            : kFieldBorderColor,
                      ),
                    ),
                    child: TextField(
                      focusNode: _focusNode,
                      maxLength: 600,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '/ Start typing here',
                        hintStyle: TextStyle(
                          color: kHintTextColor,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      onChanged: (val) => notifier.setAnswer(val),
                    ),
                  ),

                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: Column(
                      children: [
                        if (state.audioPath != null && !state.isRecordingAudio)
                          _RecordedItemWidget(
                            title:
                                'Audio Recorded - ${_formatDuration(_audioDuration)}',
                            icon: Icons.play_arrow,
                            onDelete: () async {
                              await _deleteAudio(state.audioPath!);
                              notifier.deleteAudio();
                              setState(() {});
                            },
                            onTap: () => _playRecording(state.audioPath!),
                            color: kRecordingWidgetColor,
                          ),

                        if (state.videoPath != null && !state.isRecordingVideo)
                          _RecordedItemWidget(
                            title: 'Video Recorded',
                            icon: Icons.videocam,
                            onDelete: () async {
                              if (state.videoPath != null) {
                                await _deleteVideoFile(state.videoPath!);
                                notifier.deleteVideo();
                                setState(() {});
                              }
                            },
                            onTap: () => _playVideoRecording(state.videoPath!),
                            color: kRecordingWidgetColor,
                          ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // --- Bottom Bar ---
                AnimatedRow(
                  showRecordButtons: state.videoPath == null,
                  isButtonEnabled: isButtonEnabled,
                  kButtonEnabledColor: kButtonEnabledColor,
                  kButtonDisabledColor: kButtonDisabledColor,
                  onRecordAudio: () async {
                    notifier.startAudioRecording();
                    await _startRecording();
                    setState(() {});
                  },
                  audioRecording: state.audioPath != null,
                  onDeleteAudio: () async {
                    if (state.audioPath != null) {
                      await _deleteAudio(state.audioPath!);
                      notifier.deleteAudio();
                      setState(() {});
                    }
                  },
                  onRecordVideo: () async {
                    notifier.startVideoRecording();
                    try {
                      final cameras = await availableCameras();
                      if (cameras.isNotEmpty) {
                        await _videoService.initCamera(cameras.first);
                        await _videoService.startRecording();
                        setState(() {});
                      } else {
                        print('⚠ No cameras available');
                        notifier.deleteVideo();
                      }
                    } catch (e) {
                      print('❌ Error starting video recording: $e');
                      notifier.deleteVideo();
                    }
                  },
                  videoRecording: state.videoPath != null,
                  onDeleteVideo: () async {
                    if (state.videoPath != null) {
                      await _deleteVideoFile(state.videoPath!);
                      notifier.deleteVideo();
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Video recording now uses the reusable `VideoRecorderWidget`.

/// --- RECORDED AUDIO ITEM ---
class _RecordedItemWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final Color color;

  const _RecordedItemWidget({
    required this.title,
    required this.icon,
    required this.onDelete,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF448AFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// --- ANIMATED ROW WITH COLLAPSIBLE RECORD BUTTONS ---
class AnimatedRow extends StatelessWidget {
  final bool showRecordButtons;
  final bool isButtonEnabled;
  final Color kButtonEnabledColor;
  final Color kButtonDisabledColor;
  final VoidCallback onRecordAudio;
  final bool audioRecording;
  final VoidCallback onDeleteAudio;
  final VoidCallback onRecordVideo;
  final bool videoRecording;
  final VoidCallback onDeleteVideo;

  const AnimatedRow({
    super.key,
    required this.showRecordButtons,
    required this.isButtonEnabled,
    required this.kButtonEnabledColor,
    required this.kButtonDisabledColor,
    required this.onRecordAudio,
    required this.audioRecording,
    required this.onDeleteAudio,
    required this.onRecordVideo,
    required this.videoRecording,
    required this.onDeleteVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Animated record buttons (slide in/out)
        if (showRecordButtons)
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Row(
              children: [
                RecordAudioButton(
                  onRecord: onRecordAudio,
                  hasRecording: audioRecording,
                  onDelete: onDeleteAudio,
                ),
                const SizedBox(width: 8),
                RecordVideoButton(
                  onRecord: onRecordVideo,
                  hasRecording: videoRecording,
                  onDelete: onDeleteVideo,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        // Animated Next button (expands/contracts based on record buttons visibility)
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isButtonEnabled
                  ? kButtonEnabledColor
                  : kButtonDisabledColor,
            ),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: isButtonEnabled ? () {} : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
