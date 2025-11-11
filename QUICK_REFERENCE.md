# Quick Reference Guide

A fast lookup guide for common tasks and patterns.

## 📂 Adding a New Feature

### Step 1: Create Directory Structure
```bash
mkdir -p lib/features/my_feature/{data,presentation/widgets,provider}
```

### Step 2: Create Files in Order
```
1. data/
   └─ my_feature_model.dart      # Define data structures
   └─ my_feature_service.dart    # External interactions

2. provider/
   └─ my_feature_provider.dart   # State management

3. presentation/widgets/
   └─ my_component_widget.dart   # Reusable components

4. presentation/
   └─ my_feature_screen.dart     # Main screen
```

### Step 3: Template Files

**Model Template**:
```dart
/// Represents a [MyFeature] entity.
class MyFeatureModel {
  final String id;
  final String name;

  MyFeatureModel({
    required this.id,
    required this.name,
  });

  MyFeatureModel copyWith({
    String? id,
    String? name,
  }) {
    return MyFeatureModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
```

**Service Template**:
```dart
/// Service for handling [MyFeature] operations.
class MyFeatureService {
  /// Fetches data from API or device.
  Future<MyFeatureModel> fetch() async {
    try {
      // Implementation
      return MyFeatureModel(id: '1', name: 'Example');
    } catch (e) {
      logger.error('Error fetching data: $e');
      rethrow;
    }
  }

  /// Cleanup resources
  Future<void> dispose() async {
    // Cleanup if needed
  }
}
```

**Provider Template**:
```dart
final myFeatureProvider = StateNotifierProvider.autoDispose<
  MyFeatureNotifier,
  MyFeatureState
>((ref) => MyFeatureNotifier());

class MyFeatureState {
  final String? data;
  final bool isLoading;
  final String? error;

  MyFeatureState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  MyFeatureState copyWith({
    String? data,
    bool? isLoading,
    String? error,
  }) {
    return MyFeatureState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MyFeatureNotifier extends StateNotifier<MyFeatureState> {
  MyFeatureNotifier() : super(MyFeatureState());

  void updateData(String data) {
    state = state.copyWith(data: data);
  }
}
```

---

## 🎬 Common Animations

### AnimatedContainer
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isSelected ? 100 : 90,
  height: isSelected ? 115 : 110,
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
)
```

### Transform.rotate
```dart
Transform.rotate(
  angle: 0.04, // radians
  child: Card(
    child: child,
  ),
)
```

### SlideTransition
```dart
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: Curves.easeInOut,
  )),
  child: child,
)
```

### FadeTransition
```dart
FadeTransition(
  opacity: Tween<double>(begin: 0, end: 1)
      .animate(controller),
  child: child,
)
```

---

## 🔌 Riverpod Patterns

### Watch a Provider
```dart
final state = ref.watch(myProvider);
```

### Read a Provider (one-time)
```dart
ref.read(myProvider.notifier).updateData('new value');
```

### Select Specific Field
```dart
final name = ref.watch(
  userProvider.select((state) => state.name)
);
```

### Async Operations
```dart
final dataProvider = FutureProvider<List<String>>((ref) async {
  return await fetchData();
});

// In UI
final asyncData = ref.watch(dataProvider);
asyncData.when(
  loading: () => CircularProgressIndicator(),
  error: (err, _) => Text('Error: $err'),
  data: (data) => ListView(children: [...]),
);
```

---

## 📁 File Operations

### Get Application Directory
```dart
import 'package:path_provider/path_provider.dart';

final dir = await getApplicationDocumentsDirectory();
final filePath = '${dir.path}/my_file.txt';
```

### Create & Write File
```dart
final file = File(filePath);
await file.writeAsString('content');
```

### Read File
```dart
final file = File(filePath);
if (await file.exists()) {
  final content = await file.readAsString();
}
```

### Delete File
```dart
final file = File(filePath);
if (await file.exists()) {
  await file.delete();
}
```

### List Files in Directory
```dart
final dir = Directory(dirPath);
final files = dir.listSync();
```

---

## 🎤 Audio Recording

### Initialize
```dart
final recorderController = RecorderController();
await recorderController.record(path: 'audio.m4a');
```

### Stop & Get Path
```dart
final path = await recorderController.stop();
```

### Play Audio
```dart
final audioPlayer = AudioPlayer();
await audioPlayer.setFilePath(path);
await audioPlayer.play();
```

---

## 📹 Video Recording

### Initialize Camera
```dart
final cameras = await availableCameras();
final controller = CameraController(
  cameras.first,
  ResolutionPreset.medium,
);
await controller.initialize();
```

### Start Recording
```dart
await controller.startVideoRecording();
```

### Stop Recording
```dart
final file = await controller.stopVideoRecording();
final path = file.path;
```

### Play Video
```dart
final videoController = VideoPlayerController.file(File(path));
await videoController.initialize();
videoController.play();
```

---

## 🧪 Testing Patterns

### Test a Service
```dart
test('AudioRecordService should record', () async {
  final service = AudioRecordService();
  final path = await service.record(path: 'test.m4a');
  
  expect(path, isNotNull);
  expect(File(path).existsSync(), true);
});
```

### Test a Provider
```dart
test('UserNotifier should update name', () {
  final notifier = UserNotifier();
  notifier.updateName('John');
  
  expect(notifier.state.name, 'John');
});
```

### Test a Widget
```dart
testWidgets('Button should call onTap', (tester) async {
  bool tapped = false;
  await tester.pumpWidget(
    MaterialApp(
      home: MyButton(
        onTap: () => tapped = true,
      ),
    ),
  );

  await tester.tap(find.byType(MyButton));
  expect(tapped, true);
});
```

---

## 🐛 Debugging

### Print with Context
```dart
logger.info('Debug info');
logger.warn('Warning message');
logger.error('Error occurred', stackTrace);
```

### Inspect State in Provider
```dart
class MyNotifier extends StateNotifier<MyState> {
  @override
  set state(MyState value) {
    print('State: $state → $value');
    super.state = value;
  }
}
```

### DevTools
```bash
# Launch DevTools
flutter pub global activate devtools
devtools

# Connect app
flutter run --enable-software-animation
```

---

## 📊 Performance Tips

### Use Const Widgets
```dart
✓ const SizedBox(height: 16);
✓ const Icon(Icons.check);
```

### Use .select() for Watching
```dart
✓ final name = ref.watch(userProvider.select((s) => s.name));
✗ final user = ref.watch(userProvider); // Rebuilds on any change
```

### Use Keys Wisely
```dart
✓ Use ValueKey for unique items in lists
✓ Use ObjectKey for complex objects
```

### Cache Images
```dart
Image.network(
  url,
  cacheWidth: 400,
  cacheHeight: 400,
)
```

---

## 📝 Common Errors & Solutions

### "The named parameter isn't defined"
```
✗ Issue: Widget signature mismatch
✓ Solution: Check widget constructor matches usage
```

### "Unhandled Exception: _CastError"
```
✗ Issue: Type mismatch or null value
✓ Solution: Add proper null checks and typing
```

### "setState() called after dispose()"
```
✗ Issue: Async callback after widget disposed
✓ Solution: Check if widget mounted before setState
  if (mounted) setState(() { });
```

### "Bad State: Stream is already being consumed"
```
✗ Issue: Stream listened to multiple times
✓ Solution: Use broadcast stream or create new subscription
```

---

## 🚀 Quick Commands

```bash
# Format all code
dart format lib/

# Analyze code
flutter analyze

# Run tests
flutter test

# Clean build
flutter clean && flutter pub get

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Check device logs
flutter logs

# Kill running app
flutter run --kill-running-app
```

---

## 📖 File Structure Quick Reference

```
✓ CORRECT:
lib/features/user/
├── data/
│   ├── user_model.dart
│   └── user_service.dart
├── presentation/
│   ├── user_screen.dart
│   └── widgets/
│       └── user_card.dart
└── provider/
    └── user_provider.dart

✗ WRONG:
lib/screens/
│   └── user_screen.dart
lib/models/
│   └── user_model.dart
lib/providers/
    └── user_provider.dart
```

---

## 🎯 Naming Quick Reference

| Type | Format | Example |
|------|--------|---------|
| Class | PascalCase | `UserProfile`, `AudioRecorder` |
| Variable | camelCase | `userName`, `isLoading` |
| Constant | kPascalCase | `kPrimaryColor`, `kPaddingSmall` |
| Function | camelCase | `fetchData()`, `buildHeader()` |
| Private | _camelCase | `_initializeRecorder()` |
| File | snake_case | `user_model.dart` |
| Enum | PascalCase | `RecordingState` |

---

## 💾 Git Commands Quick Reference

```bash
# Create feature branch
git checkout -b feature/add-payments

# Commit with proper message
git commit -m "[feat] Add payment integration
- Implement Stripe SDK
- Add success/error screens"

# Push to remote
git push origin feature/add-payments

# Create pull request
# (on GitHub/GitLab UI)

# After approval, merge to main
git checkout main
git pull origin main
git merge feature/add-payments
git push origin main

# Delete feature branch
git branch -d feature/add-payments
```

