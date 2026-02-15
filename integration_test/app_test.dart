import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lg_flutter_stater_kit/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LG Controller - Complete User Flow', (tester) async {
    // ═══════════════════════════════════════════════════════════
    // STEP 1: Launch App & Verify Home Page
    // ═══════════════════════════════════════════════════════════
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Liquid Galaxy'), findsOneWidget);
    expect(find.text('Controller'), findsOneWidget);
    expect(find.text('Disconnected'), findsOneWidget);

    // ═══════════════════════════════════════════════════════════
    // STEP 2: Navigate to Settings
    // ═══════════════════════════════════════════════════════════
    await tester.tap(find.byKey(const Key('Settings Icons')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    // ═══════════════════════════════════════════════════════════
    // STEP 3: Enter Connection Details
    // ═══════════════════════════════════════════════════════════
    final textFields = find.byType(TextField);

    // IP Address
    await tester.enterText(textFields.at(0), '10.62.108.40');
    await tester.pumpAndSettle();

    // Username
    await tester.enterText(textFields.at(1), 'lg');
    await tester.pumpAndSettle();

    // Password
    await tester.enterText(textFields.at(2), 'lg');
    await tester.pumpAndSettle();

    // Port
    await tester.enterText(textFields.at(3), '22');
    await tester.pumpAndSettle();

    // ═══════════════════════════════════════════════════════════
    // STEP 4: Connect to LG
    // ═══════════════════════════════════════════════════════════
    final connectButton = find.text('CONNECT TO RIG');
    await tester.scrollUntilVisible(
      connectButton,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(connectButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify connection status
    final isConnected = find.text('CONNECTED').evaluate().isNotEmpty ||
        find.text('Connected').evaluate().isNotEmpty;

    if (!isConnected) {
      // Skip remaining steps if connection failed
      return;
    }

    // ═══════════════════════════════════════════════════════════
    // STEP 5: Navigate to Map Page
    // ═══════════════════════════════════════════════════════════
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    // ═══════════════════════════════════════════════════════════
    // STEP 6: Search for Paris
    // ═══════════════════════════════════════════════════════════
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Paris');
    final location = find.text('Paris, France');
    await tester.scrollUntilVisible(
      location,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(location);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ═══════════════════════════════════════════════════════════
    // STEP 7: Navigate to Home & Show Logo
    // ═══════════════════════════════════════════════════════════
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Liquid Galaxy'), findsOneWidget);

    final showLogoButton = find.text('Show Logo');
    await tester.scrollUntilVisible(
      showLogoButton,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(showLogoButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ═══════════════════════════════════════════════════════════
    // STEP 8: Clean KML
    // ═══════════════════════════════════════════════════════════
    final cleanKmlButton = find.text('Clean KML');
    await tester.scrollUntilVisible(
      cleanKmlButton,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(cleanKmlButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
