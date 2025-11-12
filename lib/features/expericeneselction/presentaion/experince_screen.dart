import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hottspot_onboarding/features/expericeneselction/data/experince_model.dart';
import 'package:hottspot_onboarding/features/expericeneselction/presentaion/widgets/animate_wave.dart';
import 'package:hottspot_onboarding/features/expericeneselction/provider/experince_provider.dart';
import 'package:hottspot_onboarding/features/onboardingselection/presention/onboarding_screnn.dart';
import 'package:hottspot_onboarding/core/widgets/zigzag_background.dart';

// FIX: Add a FutureProvider to fetch and cache the experiences.
// This provider will be read by the UI.
final experiencesProvider = FutureProvider.autoDispose<List<ExperienceModel>>((ref) {
  // It reads the service provider to get the service instance
  final service = ref.read(experienceServiceProvider);
  // It calls the fetch method and returns the Future
  return service.fetchExperiences();
});

class ExperienceSelectionScreen extends ConsumerStatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  ConsumerState<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState
    extends ConsumerState<ExperienceSelectionScreen> {
  late ScrollController _scrollController;
  List<ExperienceModel> _sortedExperiences = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleCardSelection(ExperienceModel selectedExp) {
    // Toggle selection
    ref
        .read(experienceSelectionProvider.notifier)
        .toggleSelection(selectedExp.id);

    // Sort: move selected card to front
    if (_sortedExperiences.isNotEmpty) {
      _sortedExperiences.removeWhere((e) => e.id == selectedExp.id);
      _sortedExperiences.insert(0, selectedExp);

      // Scroll to top smoothly
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This state.watch is now safe and will NOT cause a data reload.
    final selectionState = ref.watch(experienceSelectionProvider);

    // This is the *only* provider we need for the data.
    // Riverpod handles the loading/error/data states for us.
    final experiencesAsync = ref.watch(experiencesProvider);

    // UI-Kit Colors from Figma
    const Color kBackgroundColor = Color(0xFF0B0B0B);
    // ... (all your other color constants remain)
    const Color kFieldBackgroundColor = Color(0xFF121212);
    const Color kFieldBorderColor = Color(0xFF222222);
    const Color kHintTextColor = Color(0xFF6B6B6B);
    const Color kButtonDisabledColor = Color(0xFF1A1A1A);
    const Color kButtonEnabledColor = Color(0xFF2E2E2E);
    const Color kHeaderTextColor = Color(0xFF8E8E8E);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const CurvedWaveProgressHeader(progress: 0.33),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              // TODO: Add close logic (e.g., pop to root)
            },
          ),
        ],
      ),
      body: ZigzagBackground(
        backgroundColor: kBackgroundColor,
        child: SafeArea(
          // FIX: Replaced FutureBuilder with providers .when() method
          // This handles loading/error states without re-fetching on build.
          child: experiencesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (err, stack) => Center(
              child: Text(
                'Error loading experiences: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            data: (experiences) {
              // Data is successfully loaded.
              // This 'experiences' list is now cached.

              if (experiences.isEmpty) {
                return const Center(
                  child: Text(
                    'No experiences found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // Initialize sorted list on first build
              if (_sortedExperiences.isEmpty) {
                _sortedExperiences = List.from(experiences);
              }

              // Button state is driven by ID selection
              final bool isButtonEnabled =
                  selectionState.selectedIds.isNotEmpty;

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --------- Header Text ----------
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          '01',
                          style: GoogleFonts.inter(
                            color: kHeaderTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        'What kind of experiences do you want to host?',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --------- Horizontal scroll cards ----------
                      // This ListView will now rebuild efficiently
                      // without triggering any data fetching.
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: _sortedExperiences.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final exp = _sortedExperiences[index];
                            // Watches selectionState to rebuild *only* this card
                            final isSelected = selectionState.selectedIds
                                .contains(exp.id);
                            // give each small horizontal card a subtle tilt
                            final tiltAngles = [-0.06, -0.03, 0.03, 0.06];
                            final double tilt =
                                tiltAngles[index % tiltAngles.length];

                            return AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: GestureDetector(
                                onTap: () => _handleCardSelection(exp),
                                child: Transform.rotate(
                                  angle: tilt,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.only(right: 12),
                                      width: isSelected ? 100 : 90,
                                      height: isSelected ? 115 : 110,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                          image: NetworkImage(exp.imageUrl),
                                          colorFilter: isSelected
                                              ? null
                                              : const ColorFilter.mode(
                                                  Colors.grey,
                                                  BlendMode.saturation,
                                                ),
                                          fit: BoxFit.cover,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.white.withAlpha(
                                                    77,
                                                  ),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --------- TextField -----------
                      Container(
                        decoration: BoxDecoration(
                          color: kFieldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color.fromARGB(255, 61, 91, 243)),
                        ),
                        child: TextField(
                          maxLength: 250,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: const Color.fromARGB(255, 61, 91, 243),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '/ Describe your perfect hotspot',
                            hintStyle: TextStyle(
                              color: kHintTextColor,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                          ),
                          onChanged: (val) => ref
                              .read(experienceSelectionProvider.notifier)
                              .setDescription(val),
                        ),
                      ),

                      const Spacer(),

                      // --------- Solid "Next" button ----------
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isButtonEnabled ? 1 : 0.6,
                        child: GestureDetector(
                          onTap: isButtonEnabled
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const OnboardingQuestionScreen(),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isButtonEnabled
                                  ? kButtonEnabledColor
                                  : kButtonDisabledColor,
                            ),
                            alignment: Alignment.center,
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
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
