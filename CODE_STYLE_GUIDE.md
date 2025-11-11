# Code Style & Development Guidelines

## Dart/Flutter Formatting Standards

### 1. Code Organization

```dart
// ✓ GOOD: Clear organization with sections
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- CONSTANTS ---
const Color kBackgroundColor = Color(0xFF0B0B0B);
const double kPaddingHorizontal = 16.0;

// --- MAIN WIDGET ---
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  // --- HELPER METHODS ---
  Widget _buildBody() {
    return Container();
  }
}

// --- HELPER CLASSES ---
class _HelperWidget extends StatelessWidget {
  // ...
}
```

### 2. Naming Conventions

#### Constants
```dart
✓ const Color kPrimaryColor = Color(0xFF5B7FFF);
✓ const double kPaddingSmall = 8.0;
✓ const String kAppTitle = 'Hotspot';
✓ const Duration kAnimationDuration = Duration(milliseconds: 300);
```

#### Variables & Functions
```dart
✓ String userName = 'John';              // camelCase
✓ Future<void> fetchUserData() {}        // camelCase
✓ Widget _buildHeader() {}               // Private: underscore prefix
✓ void _handleButtonTap() {}             // Event handlers: _handle prefix
✗ String user_name = 'John';             // snake_case not allowed
✗ String UserName = 'John';              // PascalCase for variables not used
```

#### Classes & Types
```dart
✓ class UserProfile {}                   // PascalCase
✓ class AudioRecordService {}            // PascalCase
✓ enum RecordingState { idle, recording, paused }  // PascalCase
✗ class userProfile {}                   // Should be PascalCase
```

### 3. Documentation & Comments

#### Doc Comments (Public API)
```dart
/// Records audio from the device microphone.
///
/// Returns the file path of the recorded audio.
///
/// Example:
/// ```dart
/// final service = AudioRecordService();
/// final path = await service.recordAudio();
/// ```
Future<String> recordAudio() async {
  // Implementation
}
```

#### Inline Comments (Non-obvious logic)
```dart
// ✓ GOOD: Explains WHY, not WHAT
// Delay to allow UI to update before animation starts
Future.delayed(const Duration(milliseconds: 100), () {
  _animateCard();
});

✗ BAD: Redundant comments
// Increment counter
counter++;

✗ BAD: Outdated comments
// This was a workaround for bug #123 (already fixed)
```

#### Section Comments
```dart
/// Define clear sections for better code navigation
// --- CONSTANTS ---
// --- STATE VARIABLES ---
// --- LIFECYCLE ---
// --- BUILD METHOD ---
// --- HELPER METHODS ---
// --- ANIMATION CALLBACKS ---
```

### 4. Widget Structure

#### StatelessWidget
```dart
class ExperienceCard extends StatelessWidget {
  final ExperienceModel experience;
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.experience,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return Container(
      // Implementation
    );
  }
}
```

#### StatefulWidget
```dart
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late AudioRecordService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = AudioRecordService();
    _initializeRecording();
  }

  @override
  void dispose() {
    _audioService.dispose(); // Always cleanup
    super.dispose();
  }

  Future<void> _initializeRecording() async {
    // Implementation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Implementation
  }
}
```

### 5. Error Handling

```dart
// ✓ GOOD: Specific error handling with recovery
Future<void> deleteAudio(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      logger.info('Audio deleted: $path');
    } else {
      logger.warn('File not found: $path');
      // Graceful handling
    }
  } catch (e, stackTrace) {
    logger.error('Error deleting audio: $e', stackTrace);
    rethrow; // or handle silently depending on use case
  }
}

✗ BAD: Bare catch
try {
  // operation
} catch (e) {
  print(e); // No context, no recovery
}
```

### 6. Async/Await Best Practices

```dart
// ✓ GOOD: Use async/await instead of .then()
Future<void> loadData() async {
  try {
    final data = await fetchFromServer();
    updateUI(data);
  } catch (e) {
    handleError(e);
  }
}

✗ BAD: Callback hell
Future<void> loadData() {
  return fetchFromServer().then((data) {
    return updateUI(data);
  }).catchError((e) {
    handleError(e);
  });
}

// ✓ GOOD: Use Future.wait for parallel operations
Future<void> initializeServices() async {
  await Future.wait([
    _initAudioService(),
    _initVideoService(),
    _initPermissions(),
  ]);
}

✗ BAD: Sequential when parallel is possible
await _initAudioService();
await _initVideoService();
await _initPermissions();
```

### 7. Type Safety

```dart
// ✓ GOOD: Explicit types
Map<String, List<int>> parseData(String json) {
  // Clear intent
}

// ✓ GOOD: Type inference where obvious
final config = <String, dynamic>{
  'apiUrl': 'https://api.example.com',
  'timeout': 30,
};

✗ BAD: Dynamic typing
dynamic data = fetchData(); // No type information
var result = parseJson(data); // Unclear type

✗ BAD: Using `var` when explicit type is clearer
var screens = [
  ExperienceScreen(),
  OnboardingScreen(),
]; // Type is unclear
```

### 8. Collections & Nullability

```dart
// ✓ GOOD: Use nullable types explicitly
String? getDescription() {
  return _description.isEmpty ? null : _description;
}

// ✓ GOOD: Null coalescing and null-aware operators
final description = user.bio ?? 'No bio provided';
final length = user.bio?.length;

✗ BAD: Unhandled nullability
String getDescription() {
  return _description; // Could be null
}

// ✓ GOOD: Use List.from() when modifying original list
List<Item> items = fetchItems();
List<Item> sortedItems = List.from(items)..sort();

✗ BAD: Mutating original list unexpectedly
items.sort(); // Modifies original
```

### 9. Constants & Magic Numbers

```dart
// ✓ GOOD: Extracted constants
const double kCardAnimationDuration = 400.0;
const double kCardWidthSelected = 100.0;
const double kCardWidthDefault = 90.0;

class CardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: kCardAnimationDuration.toInt()),
      width: isSelected ? kCardWidthSelected : kCardWidthDefault,
      // ...
    );
  }
}

✗ BAD: Magic numbers scattered in code
duration: const Duration(milliseconds: 400),
width: 100,
```

### 10. Provider Usage (Riverpod)

```dart
// ✓ GOOD: Clear, testable provider
final onboardingProvider = StateNotifierProvider.autoDispose<
  OnboardingNotifier,
  OnboardingState
>((ref) => OnboardingNotifier());

// ✓ GOOD: Notifier is a plain, testable class
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier()
      : super(OnboardingState(
          audioPath: null,
          videoPath: null,
          answerText: '',
        ));

  /// Records audio and updates state
  void stopAudioRecording(String path) {
    state = state.copyWith(audioPath: path);
  }
}

// ✓ GOOD: Usage in widgets is clear
final state = ref.watch(onboardingProvider);
ref.read(onboardingProvider.notifier).stopAudioRecording(path);

✗ BAD: Complex logic in provider
final userData = ref.watch(userProvider);
// No clear data flow
```

---

## Project-Specific Guidelines

### 1. Animation Best Practices

```dart
// ✓ GOOD: Use AnimatedContainer for simple animations
AnimatedContainer(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  width: isSelected ? 100 : 90,
  child: child,
)

// ✓ GOOD: Use Transform for rotation
Transform.rotate(
  angle: tiltAngle,
  child: card,
)

// ✓ GOOD: Use explicit AnimationController when needed
late AnimationController _controller;

@override
void initState() {
  _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat();
}

@override
void dispose() {
  _controller.dispose(); // Always cleanup
  super.dispose();
}
```

### 2. Recording Services Pattern

```dart
// ✓ GOOD: Services encapsulate device interaction
class AudioRecordService {
  final RecorderController _recorderController;

  AudioRecordService() : _recorderController = RecorderController();

  Future<void> initialize() async {
    await _recorderController.checkPermission();
  }

  Future<String?> record({required String path}) async {
    try {
      await _recorderController.record(path: path);
      return path;
    } catch (e) {
      logger.error('Recording failed: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _recorderController.dispose();
  }
}

// ✓ GOOD: Usage is simple
final audioService = AudioRecordService();
await audioService.initialize();
final path = await audioService.record(path: 'audio.m4a');
```

### 3. File Operations

```dart
// ✓ GOOD: Robust file handling with path normalization
Future<void> deleteFile(String filePath) async {
  try {
    String normPath = filePath;
    
    // Handle file:// URIs
    if (filePath.startsWith('file://')) {
      normPath = Uri.parse(filePath).toFilePath();
    }

    final file = File(normPath);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    logger.error('Error deleting file: $e');
  }
}
```

---

## Checklist Before Committing Code

- [ ] Code follows Dart style guide (`dart format`)
- [ ] No `print()` statements (use proper logging)
- [ ] All public methods have doc comments (`///`)
- [ ] Error handling is implemented
- [ ] Constants are extracted (no magic numbers)
- [ ] Resource cleanup in `dispose()` methods
- [ ] No hardcoded strings
- [ ] Naming follows conventions (camelCase, PascalCase, kConstants)
- [ ] Functions are single-responsibility
- [ ] Comments explain WHY, not WHAT
- [ ] Type safety is maintained (no unnecessary `dynamic`)
- [ ] Tests pass (when added)

---

## Tools & Commands

```bash
# Format code
dart format lib/

# Analyze code
flutter analyze

# Run tests
flutter test

# Clean build
flutter clean && flutter pub get
```

