import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/ui/widgets/custom_action_button.dart';

void main() {
  // Helper to pump the widget inside a MaterialApp (required for Theme/Text)
  Future<void> pumpButton(
    WidgetTester tester, {
    required VoidCallback onPressed,
    bool isLoading = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CustomActionButton(
              onPressed: onPressed,
              label: 'Test Button',
              icon: Icons.check,
              isLoading: isLoading,
              width: 200, // Increase size to prevent overflow
              height: 150,
            ),
          ),
        ),
      ),
    );
  }

  group('CustomActionButton', () {
    testWidgets('renders Label and Icon correctly', (tester) async {
      // 1. Arrange & Act
      await pumpButton(tester, onPressed: () {});

      // 2. Assert
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      // 1. Arrange & Act
      await pumpButton(tester, onPressed: () {}, isLoading: true);

      // 2. Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing); // Icon should be hidden
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      // 1. Arrange
      bool wasPressed = false;
      await pumpButton(tester, onPressed: () {
        wasPressed = true;
      });

      // 2. Act
      await tester.tap(find.byType(CustomActionButton));
      await tester.pump();

      // 3. Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('does NOT call onPressed when tapped while loading',
        (tester) async {
      // 1. Arrange
      bool wasPressed = false;
      await pumpButton(tester, onPressed: () {
        wasPressed = true;
      }, isLoading: true);

      // 2. Act
      await tester.tap(find.byType(CustomActionButton));
      await tester.pump();

      // 3. Assert
      expect(wasPressed, isFalse);
    });
  });
}
