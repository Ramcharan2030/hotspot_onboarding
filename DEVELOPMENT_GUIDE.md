# Development Workflow & Best Practices

## Feature Development Checklist

When starting a new feature, follow this checklist:

### 1. **Plan the Feature Structure**
```
✓ Define feature name and scope
✓ Identify required models and data structures
✓ Plan state management needs (providers)
✓ Design UI screens and components
✓ Identify reusable vs. feature-specific widgets
```

### 2. **Create Feature Directory**
```bash
mkdir -p lib/features/my_feature/{data,presentation,provider}

# Create subdirectories
mkdir -p lib/features/my_feature/presentation/widgets
```

### 3. **Implement in Order**
```
1. Models (data/)
   └─ {feature}_model.dart - Define data structures

2. Services (data/)
   └─ {feature}_service.dart - API/device interactions

3. State Management (provider/)
   └─ {feature}_provider.dart - Riverpod providers

4. Widgets (presentation/widgets/)
   └─ {component}_widget.dart - Reusable components
   └─ {button}_button.dart - Custom buttons

5. Screens (presentation/)
   └─ {feature}_screen.dart - Main screen
```

### 4. **Write Documentation**
```dart
/// Model representing user experience preferences.
class ExperienceModel {
  /// Unique identifier for the experience
  final String id;

  /// Display name of the experience
  final String name;

  ExperienceModel({
    required this.id,
    required this.name,
  });
}
```

### 5. **Test Integration**
```
✓ Test with hot reload
✓ Test state persistence
✓ Test error scenarios
✓ Test animations and UI transitions
✓ Test on different screen sizes
```

---

## State Management (Riverpod) Best Practices

### ✅ DO

```dart
// ✓ DO: Use StateNotifierProvider for mutable state
final userProvider = StateNotifierProvider<
  UserNotifier,
  UserState
>((ref) => UserNotifier());

// ✓ DO: Keep notifiers pure and testable
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState.initial());

  void updateName(String name) {
    state = state.copyWith(name: name);
  }
}

// ✓ DO: Use FutureProvider for async data
final userDataProvider = FutureProvider<UserData>((ref) async {
  return await fetchUserData();
});

// ✓ DO: Use .select() to watch specific fields
final userName = ref.watch(
  userProvider.select((state) => state.name)
);

// ✓ DO: Properly invalidate providers when needed
ref.invalidate(userProvider);
```

### ❌ DON'T

```dart
// ✗ DON'T: Access notifier in build method
final state = ref.read(userProvider.notifier).state;

// ✗ DON'T: Mutate state directly
state.name = 'John'; // Wrong

// ✗ DON'T: Create providers in build method
@override
Widget build(BuildContext context) {
  final provider = StateNotifierProvider(...); // Wrong
}

// ✗ DON'T: Use .watch in event handlers
onPressed: () => ref.watch(userProvider), // Wrong - use .read()
```

---

## Widget Composition Patterns

### Pattern 1: Reusable Button
```dart
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isLoading ? Colors.grey : Colors.blue,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}
```

### Pattern 2: Animated Card with Interaction
```dart
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isSelected;

  const AnimatedCard({
    super.key,
    required this.child,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.isSelected) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.1)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
        child: widget.child,
      ),
    );
  }
}
```

### Pattern 3: Form Validation
```dart
class FormField<T> extends StatefulWidget {
  final String label;
  final String Function(T)? validator;
  final ValueChanged<T> onChanged;

  const FormField({
    super.key,
    required this.label,
    this.validator,
    required this.onChanged,
  });

  @override
  State<FormField<T>> createState() => _FormFieldState<T>();
}

class _FormFieldState<T> extends State<FormField<T>> {
  String? _error;

  void _validate(T value) {
    setState(() {
      _error = widget.validator?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        TextField(
          onChanged: (value) {
            widget.onChanged(value as T);
            _validate(value as T);
          },
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
```

---

## Performance Optimization Tips

### 1. **Rebuild Optimization with .select()**
```dart
// ✗ Bad: Rebuilds when ANY state changes
final state = ref.watch(userProvider);

// ✓ Good: Rebuilds only when name changes
final userName = ref.watch(
  userProvider.select((state) => state.name)
);
```

### 2. **Const Widgets**
```dart
// ✓ GOOD: Mark widgets as const
const SizedBox(height: 16);
const Icon(Icons.check);

// ✓ GOOD: Use const constructors
const EdgeInsets.symmetric(horizontal: 16);

// Automatically rebuild child widgets less
```

### 3. **Lazy Initialization**
```dart
// ✓ GOOD: Use autoDispose for temporary providers
final tempProvider = StateNotifierProvider.autoDispose<...>(...);

// ✓ GOOD: Lazy instantiation of expensive objects
late final ExpensiveService _service;

@override
void initState() {
  super.initState();
  _service = ExpensiveService(); // Only when needed
}
```

### 4. **Image Optimization**
```dart
// ✓ GOOD: Cache network images
Image.network(
  imageUrl,
  cacheWidth: 400,
  cacheHeight: 400,
  fadeInDuration: const Duration(milliseconds: 200),
)

// ✓ GOOD: Use cached_network_image package
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Container(color: Colors.grey),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

---

## Debugging Tips

### 1. **Enable Riverpod Logging**
```dart
ProviderContainer(
  observers: [
    RiverpodObserver(),
  ],
)
```

### 2. **Use DevTools**
```bash
# Launch Flutter DevTools
flutter pub global activate devtools
devtools

# Connect to running app
flutter run --enable-software-animation
```

### 3. **Print State Changes**
```dart
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  @override
  set state(OnboardingState value) {
    print('State changed from: $state → $value');
    super.state = value;
  }
}
```

### 4. **Inspect Widget Tree**
```dart
@override
Widget build(BuildContext context) {
  // Use DevTools -> Inspector to inspect widget tree
  return Scaffold(
    // ...
  );
}
```

---

## Testing Guidelines

### Unit Tests (Services & Providers)
```dart
test('AudioRecordService should record audio', () async {
  final service = AudioRecordService();
  final path = await service.record(path: 'test.m4a');
  
  expect(path, isNotNull);
  expect(File(path).existsSync(), true);
});

test('OnboardingNotifier should update state on recording', () {
  final notifier = OnboardingNotifier();
  notifier.stopAudioRecording('audio.m4a');
  
  expect(notifier.state.audioPath, 'audio.m4a');
});
```

### Widget Tests (UI Components)
```dart
testWidgets('ExperienceCard should animate on tap', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ExperienceCard(
          experience: mockExperience,
          isSelected: false,
          onTap: () {},
        ),
      ),
    ),
  );

  await tester.tap(find.byType(ExperienceCard));
  await tester.pumpAndSettle();

  expect(find.byType(ScaleTransition), findsOneWidget);
});
```

---

## Deployment Checklist

Before deploying to production:

- [ ] All print() statements removed or replaced with logging
- [ ] Error handling implemented for all network/device operations
- [ ] No hardcoded URLs or sensitive data
- [ ] All images optimized and compressed
- [ ] Animations tested on low-end devices
- [ ] Permissions properly requested and handled
- [ ] All widgets properly disposed (AnimationController, Stream, etc.)
- [ ] No memory leaks (checked with DevTools memory profiler)
- [ ] Performance acceptable (60 FPS maintained)
- [ ] Accessibility considerations (colors, text size, etc.)
- [ ] Tested on multiple device sizes and OS versions
- [ ] App signing keys secured
- [ ] Analytics properly configured
- [ ] Crash reporting configured (Firebase Crashlytics)

---

## Version Control Best Practices

### Commit Message Format
```
[TYPE] Brief description (50 chars max)

Detailed explanation of changes (if needed)

Fixes: #123
Related: #456
```

### Types
```
[feat]     - New feature
[fix]      - Bug fix
[refactor] - Code restructuring
[style]    - Formatting/style changes
[docs]     - Documentation
[test]     - Test additions/changes
[chore]    - Build/dependency updates
```

### Example Commits
```
[feat] Add audio recording with playback animation
- Implement AudioRecordService for device recording
- Add immediate playback in onboarding screen
- Animate wave header during recording

[fix] Handle file URI paths in delete operation
- Normalize file:// URIs before deletion
- Add fallback for alternate path formats
- Add diagnostic logging for debugging

[refactor] Extract AnimatedRow component
- Move bottom button row to separate widget
- Improve code reusability and testability
- Add proper animation timing
```

---

## Code Review Checklist

When reviewing others' code:

- [ ] Code follows architecture (data/presentation/provider layers)
- [ ] No business logic in UI widgets
- [ ] Error handling is comprehensive
- [ ] Comments are clear and necessary
- [ ] No performance red flags (unnecessary rebuilds, etc.)
- [ ] Type safety maintained
- [ ] Resources properly cleaned up
- [ ] Constants extracted (no magic numbers)
- [ ] Naming follows conventions
- [ ] Functions are single-responsibility
- [ ] Tests cover edge cases
- [ ] Documentation updated if needed

