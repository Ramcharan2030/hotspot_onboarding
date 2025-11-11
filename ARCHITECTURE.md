# Hotspot Onboarding - Architecture & Scalability Guide

## Project Structure Overview

```
lib/
├── main.dart                          # App entry point with MaterialApp setup
├── core/                              # Shared utilities, widgets, theme
│   ├── router/                        # Navigation routing (future: Go Router)
│   ├── theme/                         # App theme, colors, typography
│   └── widgets/                       # Reusable widgets (ZigzagBackground, etc.)
├── features/                          # Feature-based modular structure
│   ├── expericeneselction/            # Experience Selection Feature
│   │   ├── data/                      # Data layer (models, services)
│   │   │   ├── experince_model.dart
│   │   │   └── experince_service.dart
│   │   ├── presentaion/               # Presentation layer (UI)
│   │   │   ├── experince_screen.dart  # Main screen with animations
│   │   │   └── widgets/               # Feature-specific widgets
│   │   │       └── animate_wave.dart  # Wave progress header
│   │   └── provider/                  # State management (Riverpod)
│   │       └── experince_provider.dart
│   └── onboardingselection/           # Onboarding/Question Feature
│       ├── data/                      # Data layer
│       │   ├── audio_record_service.dart
│       │   └── video_record_service.dart
│       ├── presention/                # Presentation layer (UI)
│       │   ├── onboarding_screnn.dart # Main onboarding screen
│       │   └── widgets/               # Feature-specific widgets
│       │       ├── record_audio.dart
│       │       └── video_recorder_widget.dart
│       └── provider/                  # State management (Riverpod)
│           └── on_boarding_provider.dart
└── data/                              # App-wide data (if needed)
```

## Architectural Principles

### 1. **Clean Architecture - Layered Approach**

Each feature follows a **Clean Architecture** pattern with three layers:

#### **Presentation Layer** (`presentation/`)
- **Responsibility**: UI rendering, user interactions, animations
- **Contains**: Screens, UI widgets, animations
- **Example**: `experince_screen.dart`, `onboarding_screnn.dart`
- **Depends on**: Provider (for state), Models (for data display)

#### **Business Logic Layer** (`provider/`)
- **Responsibility**: State management, business rules
- **Tool**: Riverpod (StateNotifierProvider for mutations)
- **Example**: `on_boarding_provider.dart`, `experince_provider.dart`
- **Depends on**: Data layer (services, models)

#### **Data Layer** (`data/`)
- **Responsibility**: Data fetching, API calls, local storage, device services
- **Contains**: Services, models, repositories (future)
- **Example**: `audio_record_service.dart`, `video_record_service.dart`
- **Independent**: No dependencies on presentation or business logic

---

## Key Features & Best Practices

### 2. **Feature-Based Modular Structure**

Each feature is **self-contained** and can be developed/tested independently:

```
✓ Easy to add new features without affecting existing code
✓ Easy to test features in isolation
✓ Clear separation of concerns
✓ Simple to reuse features across the app
```

**Example**: Adding a new "Profile" feature:
```
features/profile/
├── data/
│   ├── profile_model.dart
│   └── profile_service.dart
├── presentation/
│   ├── profile_screen.dart
│   └── widgets/
└── provider/
    └── profile_provider.dart
```

### 3. **State Management - Riverpod Pattern**

```dart
// ✓ Good: State is defined clearly
final onboardingProvider = StateNotifierProvider.autoDispose<
  OnboardingNotifier,
  OnboardingState
>((ref) => OnboardingNotifier());

// ✓ Easy to test: Notifier is a plain class
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  void stopAudioRecording(String path) {
    state = state.copyWith(audioPath: path);
  }
}

// ✓ Usage in UI is simple
final state = ref.watch(onboardingProvider);
ref.read(onboardingProvider.notifier).stopAudioRecording(path);
```

---

## File Naming Conventions

### Screen Files
```
✓ {feature}_screen.dart       (e.g., experince_screen.dart)
✗ {feature}_page.dart         (Prefer 'screen' for clarity)
✗ {feature}_view.dart         (Prefer 'screen' for clarity)
```

### Widget Files
```
✓ {widget_name}_widget.dart   (e.g., video_recorder_widget.dart)
✓ {component}_button.dart     (e.g., record_audio_button.dart)
✓ animate_{feature}.dart      (e.g., animate_wave.dart)
```

### Service Files
```
✓ {service}_service.dart      (e.g., audio_record_service.dart)
✓ {feature}_repository.dart   (Future: data abstraction layer)
```

### Provider Files
```
✓ {feature}_provider.dart     (e.g., on_boarding_provider.dart)
```

### Model Files
```
✓ {model}_model.dart          (e.g., experince_model.dart)
✓ {model}.dart                (Alternate: simpler names)
```

---

## Best Practices Implemented

### ✅ Separation of Concerns
- **Services** handle device interactions (recording, camera)
- **Providers** manage app state
- **Screens** focus purely on UI and user interactions

### ✅ Reusable Components
- `ZigzagBackground` - shared background widget
- `CurvedWaveProgressHeader` - reusable wave animation
- `RecordAudioButton`, `RecordVideoButton` - feature-specific but reusable

### ✅ Type Safety
- Models are properly typed (ExperienceModel, OnboardingState)
- No `dynamic` types (prefer explicit typing)
- Dart's type inference is used where appropriate

### ✅ Error Handling
- Services provide try-catch wrappers
- Print diagnostics for debugging (can be replaced with logging later)
- Graceful fallbacks for file operations

### ✅ Code Documentation
- Comments explain non-obvious logic
- Class purposes documented with `///` doc comments
- Parameter purposes and return types are clear

---

## Scalability Roadmap

### Phase 1: Current ✅
```
✓ Feature-based structure
✓ Clean layered architecture
✓ Riverpod state management
✓ Reusable widgets and services
```

### Phase 2: Future Enhancements

#### **Add Repository Pattern** (Data Abstraction)
```dart
// Replace direct service calls with repositories
abstract class IAudioRepository {
  Future<String> recordAudio();
  Future<void> playAudio(String path);
  Future<void> deleteAudio(String path);
}

class AudioRepository implements IAudioRepository {
  final AudioRecordService _service;
  // Implementation
}
```

#### **Add Dependency Injection** (GetIt or Riverpod Providers)
```dart
// Centralize all service instantiation
final audioServiceProvider = Provider((ref) => AudioRecordService());
```

#### **Add Navigation Router** (Go Router)
```dart
// Type-safe routing with parameters
final goRouter = GoRouter(
  routes: [
    GoRoute(path: '/experience', builder: (_, __) => ExperienceScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => OnboardingScreen()),
  ],
);
```

#### **Add Logging** (Replace print with proper logging)
```dart
import 'logger/app_logger.dart';

class AudioRecordService {
  void startRecording() {
    logger.info('Recording started');
  }
}
```

#### **Add Unit & Widget Tests**
```
test/
├── unit/
│   ├── services/
│   │   └── audio_record_service_test.dart
│   └── providers/
│       └── on_boarding_provider_test.dart
└── widget/
    ├── screens/
    │   └── onboarding_screen_test.dart
    └── widgets/
        └── animate_wave_test.dart
```

---

## Current Code Quality Metrics

| Aspect | Status | Notes |
|--------|--------|-------|
| **Architecture** | ✅ Excellent | Clean, layered, modular |
| **Separation of Concerns** | ✅ Good | Clear boundaries between layers |
| **Naming Conventions** | ⚠️ Minor | Typo: `experince_` (should be `experience_`) |
| **Type Safety** | ✅ Strong | Proper models and typing |
| **Reusability** | ✅ Good | Shared widgets and services |
| **Documentation** | ⚠️ Fair | Add more doc comments |
| **Testing** | ❌ None | No tests yet (Phase 2) |
| **Error Handling** | ✅ Good | Try-catch with fallbacks |
| **Performance** | ✅ Good | Efficient animations, proper disposal |

---

## Recommended Next Steps

### Short Term (Immediate)
1. ✅ **Fix naming typo**: `experince_` → `experience_` (for consistency)
2. ✅ **Add more doc comments** to services and providers
3. ✅ **Replace print() with logger** for production-ready logging

### Medium Term (Sprint 2-3)
1. Add Repository pattern for better data abstraction
2. Implement Go Router for type-safe navigation
3. Add comprehensive error handling with custom exceptions
4. Create reusable service locator (GetIt or Riverpod)

### Long Term (Sprint 4+)
1. Add unit tests for services and providers
2. Add widget tests for screens
3. Add integration tests
4. Implement analytics logging
5. Add feature flags for A/B testing
6. Implement offline-first caching strategy

---

## Code Quality Checklist

When adding new features, ensure:

- [ ] Feature is in its own directory under `features/`
- [ ] Data layer is separated from presentation
- [ ] Services handle all device interactions
- [ ] Providers manage all state mutations
- [ ] UI screens only display UI (no business logic)
- [ ] All models are properly typed
- [ ] Error handling is in place
- [ ] Comments document non-obvious logic
- [ ] Code follows Dart style guide (`dart format`)
- [ ] No `print()` statements in production code (use logger)
- [ ] Widgets are properly disposed (AnimationController, StreamSubscription)
- [ ] No hardcoded strings (use constants)

---

## Resources & References

- **Riverpod**: https://riverpod.dev/ - State management
- **Clean Architecture**: https://www.freecodecamp.org/news/a-quick-introduction-to-clean-architecture-useful-for-django-django-rest-framework-and-flask/
- **Flutter Best Practices**: https://flutter.dev/docs/testing/best-practices
- **Dart Style Guide**: https://dart.dev/guides/language/effective-dart/style

---

## Contact & Questions

For architecture questions or to propose structural changes, please document the rationale and impact before implementing.

