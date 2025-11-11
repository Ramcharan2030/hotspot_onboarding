import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hottspot_onboarding/features/onboardingselection/data/video_record_service.dart';

class VideoRecorderWidget extends StatefulWidget {
  final VideoRecorderService videoService;
  final bool isRecording;
  final VoidCallback onStop;
  final double width;

  const VideoRecorderWidget({
    super.key,
    required this.videoService,
    required this.isRecording,
    required this.onStop,
    required this.width,
  });

  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _recordingIndicatorController;

  @override
  void initState() {
    super.initState();
    _recordingIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Start or stop the blinking light animation
    if (widget.isRecording) {
      _recordingIndicatorController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VideoRecorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_recordingIndicatorController.isAnimating) {
      _recordingIndicatorController.repeat(reverse: true);
    } else if (!widget.isRecording &&
        _recordingIndicatorController.isAnimating) {
      _recordingIndicatorController.stop();
    }
  }

  @override
  void dispose() {
    _recordingIndicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.videoService.controller;

    // Safety checks — avoid crashes if controller is null or not initialized
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      );
    }

    return AnimatedOpacity(
      opacity: widget.isRecording ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Column(
          children: [
            // --- Top recording indicator ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(26),
                border: Border.all(color: Colors.red.withAlpha(77), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.9, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _recordingIndicatorController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withAlpha(204),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Recording Video...",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- Camera Preview ---
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withAlpha(102),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withAlpha(51),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: widget.width * 0.9,
                  height: widget.width * 0.7,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(controller),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withAlpha(204),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const SizedBox(
                            width: 6,
                            height: 6,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- Stop Button ---
            ElevatedButton.icon(
              onPressed: widget.onStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.stop, size: 18),
              label: const Text(
                "Stop Recording",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
