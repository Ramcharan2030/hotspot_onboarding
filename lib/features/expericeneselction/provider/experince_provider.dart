import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:hottspot_onboarding/features/expericeneselction/data/expericen_service.dart';

class ExperienceSelectionState {
  final List<int> selectedIds;
  final String description;

  ExperienceSelectionState({
    required this.selectedIds,
    required this.description,
  });

  ExperienceSelectionState copyWith({
    List<int>? selectedIds,
    String? description,
  }) {
    return ExperienceSelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      description: description ?? this.description,
    );
  }
}

class ExperienceSelectionNotifier
    extends StateNotifier<ExperienceSelectionState> {
  ExperienceSelectionNotifier()
      : super(ExperienceSelectionState(selectedIds: [], description: ''));

  void toggleSelection(int id) {
    final newIds = List<int>.from(state.selectedIds);
    if (newIds.contains(id)) {
      newIds.remove(id);
    } else {
      newIds.add(id);
    }
    state = state.copyWith(selectedIds: newIds);
  }

  void setDescription(String text) {
    state = state.copyWith(description: text);
  }
}

// Providers
final experienceSelectionProvider =
    StateNotifierProvider<ExperienceSelectionNotifier, ExperienceSelectionState>(
        (ref) => ExperienceSelectionNotifier());

final experienceServiceProvider = Provider((ref) => ExperienceService());
