import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordAudioWidget extends StatelessWidget {
  final RecorderController recorderController;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  const RecordAudioWidget({
    super.key,
    required this.recorderController,
    required this.onStop,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF7BDFFF); // your Figma accent color
    const Color backgroundDark = Color(0xFF151515);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: backgroundDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🎙️ Waveform container
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryBlue.withAlpha(31),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryBlue.withAlpha(77), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: AudioWaveforms(
              size: const Size(double.infinity, 80),
              recorderController: recorderController,
              enableGesture: false,
              waveStyle: const WaveStyle(
                waveColor: primaryBlue,
                extendWaveform: true,
                showMiddleLine: false,
                spacing: 4,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 🔴 Recording indicator + timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recording in progress...',
                style: GoogleFonts.inter(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🎛️ Control buttons row
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Stop Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onStop,
                  icon: const Icon(Icons.stop_circle_rounded, size: 18),
                  label: Text(
                    'Stop',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
