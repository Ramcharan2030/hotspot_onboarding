# Hotspot Onboarding App

A modern, scalable Flutter application for onboarding users to the Hotspot platform. This repository contains the onboarding flows with audio/video capture, immediate playback, experience selection UI, and several UI/UX polish items implemented during the work session.

## 📱 Features

### ✨ Core Features (implemented)
- Experience Selection — horizontal stamp/card picker with per-card tilt and selection state
- Audio Recording — record to file with waveform visualization, stop/cancel, and immediate playback
- Video Recording — camera preview and video capture, immediate playback in a dialog
- Immediate Playback — play recorded audio/video back from the onboarding screen
- File Management — delete recorded files with robust fallbacks (normalized file:// handling and File.fromUri)
- Wave Progress Header — Curved wave progress indicator used in the onboarding flow

### 🎨 UI/UX polish (implemented)
- Animated Cards — subtle tilt per-card and selection visuals (shadow, desaturation removal)
- Slide-to-front — selecting a stamp animates that card towards the left/front and reorders the list
- Animated Next button — Next button expands/contracts smoothly when record buttons appear/disappear
- Wave header — two-layer wave (filled progress + track) for nicer visuals
- Keyboard-safe layouts — onboarding text fields are placed inside scrollable areas so the keyboard doesn't overflow the UI

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                              # App entry point
├── core/
│   ├── router/                           # Navigation (future: Go Router)
│   ├── theme/                            # Theme configuration
│   └── widgets/                          # Reusable widgets
├── features/
│   ├── expericeneselction/               # Experience selection feature
│   │   ├── data/                        # Models & services
│   │   ├── presentation/                # UI screens & widgets
│   │   └── provider/                    # State management
│   └── onboardingselection/             # Recording feature
│       ├── data/                        # Recording services
│       ├── presentation/                # UI screens & widgets
│       └── provider/                    # State management
```

**Pattern**: Clean Architecture with feature-based modular structure

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart 3.0+

### Installation

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Format code
dart format lib/

# Analyze code
flutter analyze
```

---

## 📚 Documentation

Comprehensive guides and documentation:

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Project architecture, scalability guide, and future roadmap
- **[CODE_STYLE_GUIDE.md](./CODE_STYLE_GUIDE.md)** - Code style, naming conventions, and best practices
- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)** - Development workflow, patterns, and testing guidelines

---

## 🎬 Key Features Implemented

### 1. Experience Selection Screen
- Horizontal scrolling card list with tilt effect
- Smooth card selection animation (scale, slide to front)
- Selected card glow effect and desaturation removal
- Progress header showing 33% completion

### 2. Onboarding/Question Screen
- Audio recording with waveform visualization
- Video recording with camera preview
- Immediate playback of recorded media
- Delete functionality with UI refresh
- Animated Next button expansion
- Progress header showing 66% completion

### 3. Animations
- ✅ Card tilt effect on all cards (subtle rotation)
- ✅ Selected card slides to first position with smooth scroll
- ✅ Wave progress header (animated blue wave + gray track)
- ✅ Button width animation when recording buttons disappear
- ✅ Card size growth on selection with shadow effect

---

## 🎖️ Brownie points / Extra improvements implemented

- Robust file deletion: code normalizes file:// URIs and falls back to File.fromUri; if deletion still fails the code logs the directory contents for debugging.
- Defensive async checks: used mounted checks before calling Navigator/Dialogs after async operations to avoid use_build_context_synchronously issues.
- withOpacity deprecation fixes: replaced several uses of .withOpacity with .withAlpha where appropriate to address deprecation warnings.
- Small UI improvements: consistent spacing, SafeArea/SingleChildScrollView usage to prevent keyboard overlap, and animated opacity/size transitions across components.

## 🔧 Additional notes / next steps

- Static analysis: there are several lint items (avoid_print uses, a few unused imports). Replacing debug prints with a logger and applying minor cleanups will clear analyzer warnings.
- Tests: no new unit/widget tests were added in this pass; adding tests for providers and recorder services is recommended next.
- Permissions: runtime permission prompts for camera/microphone are required for production; current code assumes permissions are handled elsewhere.

If you'd like, I can:
- finish replacing remaining debug prints with a logger
- add runtime permission handling
- re-implement the slide-to-front card animation variant with a polished, robust animation controller and unit tests
- run `flutter analyze` and fix the remaining lints

---

## 📊 State Management (Riverpod)

Providers are organized by feature:

```dart
// Experience Selection
final experienceSelectionProvider = StateNotifierProvider<...>(...);

// Onboarding
final onboardingProvider = StateNotifierProvider.autoDispose<...>(...);

// Async Data
final experiencesProvider = FutureProvider<...>(...);
```

---

## 🛠️ Development

### Code Quality
```bash
# Format code according to Dart style
dart format lib/

# Analyze for issues
flutter analyze

# Run tests
flutter test
```

### Best Practices
✅ Clean architecture (presentation/business/data layers)
✅ Feature-based modular structure
✅ Type safety (no unnecessary dynamic types)
✅ Proper error handling with recovery
✅ Resource cleanup in dispose methods
✅ Reusable components and services
✅ Clear separation of concerns

### Code Style
- Follow Dart Style Guide conventions
- Use camelCase for variables/functions
- Use PascalCase for classes
- Use kConstants for constants
- Add doc comments (///) for public APIs

---

## 📦 Key Dependencies

```yaml
flutter_riverpod: ^2.0.0        # State management
audio_waveforms: ^1.0.0         # Audio recording visualization
just_audio: ^0.9.0              # Audio playback
camera: ^0.10.0                 # Camera control
video_player: ^2.0.0            # Video playback
path_provider: ^2.0.0           # File paths
google_fonts: ^6.0.0            # Typography
```

---

## 🔐 Security & Permissions

### Android
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to record videos</string>
```

---

## 📈 Scalability

The project is structured for easy scaling:

✅ **Feature Isolation** - Each feature is independent and self-contained
✅ **Layer Separation** - Data, business logic, and UI are clearly separated
✅ **Provider Pattern** - Easy to add new state management
✅ **Reusable Services** - Services can be shared across features
✅ **Widget Composition** - Build complex UIs from simple components

### Future Enhancements
- Add repository pattern for data abstraction
- Implement Go Router for type-safe navigation
- Add comprehensive logging system
- Create service locator for dependency injection
- Add unit & widget tests
- Implement caching layer

---

## 🐛 Troubleshooting

### Audio/Video Recording
1. Check permissions are granted (Runtime + Manifest)
2. Ensure sufficient storage space
3. Check microphone/camera availability

### Animations Stuttering
1. Check device performance in DevTools
2. Profile with Flutter DevTools
3. Reduce animation complexity if needed

---

## 📝 Contributing

When adding new code:
1. Follow [CODE_STYLE_GUIDE.md](./CODE_STYLE_GUIDE.md)
2. Maintain feature-based structure
3. Add documentation for public APIs
4. Test thoroughly before committing

---

## 📞 Support

For questions about architecture or development:
- Review the comprehensive guides in this repository
- Check existing code for patterns and examples
- Refer to package documentation for dependencies

