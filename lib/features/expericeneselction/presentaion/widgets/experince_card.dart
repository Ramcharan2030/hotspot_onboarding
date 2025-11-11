import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hottspot_onboarding/features/expericeneselction/data/experince_model.dart';

class ExperienceCard extends StatefulWidget {
  final ExperienceModel experience;
  final bool isSelected;
  final VoidCallback onTap;
  final int index; // <-- add index to make tilt consistent per card

  const ExperienceCard({
    super.key,
    required this.experience,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  late final double _tiltAngle;

  @override
  void initState() {
    super.initState();
    // Make each card tilt based on its index — consistent per rebuild
    final tiltDirection = widget.index.isEven ? 1 : -1;
    _tiltAngle = tiltDirection * (pi / 15); // ≈ 5 degrees tilt
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Transform.rotate(
        angle: _tiltAngle,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? Color(0xFF7BDFFF).withAlpha(128)
                    : Colors.black.withAlpha(102),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.white.withAlpha(230), width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background image
                Positioned.fill(
                  child: Image.network(
                    widget.experience.imageUrl,
                    fit: BoxFit.cover,
                    color: widget.isSelected
                        ? null
                        : Colors.black.withAlpha(128),
                    colorBlendMode: widget.isSelected
                        ? null
                        : BlendMode.saturation,
                  ),
                ),

                // Gradient overlay for readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(179),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Text label
                Positioned(
                  bottom: 12,
                  left: 8,
                  right: 8,
                  child: Text(
                    widget.experience.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                // Checkmark
                if (widget.isSelected)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.check_circle, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
