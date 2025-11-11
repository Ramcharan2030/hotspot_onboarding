import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Figma-aligned colors
    const Color kButtonColor = Color(0xFF1E1E1E);
    const Color kBorderColor = Color(0xFF2E2E2E);
    const Color kDeleteColor = Color(0xFFE53935); // Red for delete

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      // User's logic: change width, but sized for Figma
      width: hasRecording ? 120 : 55,
      height: 55, // Figma height
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        // User's logic: change color
        color: hasRecording ? kDeleteColor.withAlpha(38) : kButtonColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasRecording ? kDeleteColor.withAlpha(204) : kBorderColor,
        ),
      ),
      child: InkWell(
        // User's logic: change action
        onTap: hasRecording ? onDelete : onRecord,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: hasRecording
                // User's logic: show "Delete" icon and text
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
                // User's logic: show "Video" icon only
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
