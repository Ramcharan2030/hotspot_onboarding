import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🌊 Animated curved wave progress bar (Figma accurate)
/// Use: `CurvedWaveProgressHeader(progress: 0.5)`
class CurvedWaveProgressHeader extends StatefulWidget {
  final double progress; // Range: 0.0 -> 1.0

  const CurvedWaveProgressHeader({super.key, required this.progress});

  @override
  State<CurvedWaveProgressHeader> createState() =>
      _CurvedWaveProgressHeaderState();
}

class _CurvedWaveProgressHeaderState extends State<CurvedWaveProgressHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // Continuous animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16, // height for the progress wave
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _CurvedWavePainter(
              phase: _controller.value,
              progress: widget.progress.clamp(0.0, 1.0),
            ),
          );
        },
      ),
    );
  }
}

class _CurvedWavePainter extends CustomPainter {
  final double phase;
  final double progress;

  _CurvedWavePainter({required this.phase, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    final double fullWidth = size.width;
    final double progressWidth = fullWidth * progress;

    // 🎨 Animated blue wave for progress (filled portion)
    final Paint wavePaint = Paint()
      ..color = const Color(0xFF5B7FFF)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 🎨 Background track (unfilled portion) — shows remaining progress
    final Paint trackPaint = Paint()
      ..color = Colors.white.withAlpha(38)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 🔄 Wave pattern settings
    const double waveAmplitude = 3.0; // height of curve
    const double waveLength = 18.0; // distance between waves

    // --- ANIMATED WAVE (filled progress) ---
    final Path wavePath = Path();
    wavePath.moveTo(0, centerY);
    for (double x = 0; x <= progressWidth; x += 0.5) {
      final double y =
          centerY +
          math.sin((x / waveLength * 2 * math.pi) + (phase * 2 * math.pi)) *
              waveAmplitude;
      wavePath.lineTo(x, y);
    }
    canvas.drawPath(wavePath, wavePaint);

    // --- BACKGROUND TRACK (remaining progress unfilled) with wave structure ---
    final Path trackPath = Path();
    trackPath.moveTo(progressWidth, centerY);
    for (double x = progressWidth; x <= fullWidth; x += 0.5) {
      // Wave structure for unfilled portion (same wave pattern, static)
      final double y =
          centerY +
          math.sin((x / waveLength * 2 * math.pi) + (phase * 2 * math.pi)) *
              waveAmplitude;
      trackPath.lineTo(x, y);
    }
    canvas.drawPath(trackPath, trackPaint);
  }

  @override
  bool shouldRepaint(_CurvedWavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.progress != progress;
  }
}
