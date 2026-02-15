import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/domain/repositories/lg_repository.dart';
import 'package:lg_flutter_stater_kit/domain/services/ssh_service_interface.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/connect_to_lg.dart';
import 'package:lg_flutter_stater_kit/ui/pages/main_page.dart';
import 'package:lg_flutter_stater_kit/ui/providers/connection_provider.dart';
import 'package:lg_flutter_stater_kit/ui/providers/navigation_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  LGRepository,
  ISshService,
  ConnectToLgUseCase,
  DisconnectFromLgUseCase,
])
import 'main_page_test.mocks.dart';

void main() {
  late MockLGRepository mockRepository;
  late MockISshService mockSshService;
  late MockConnectToLgUseCase mockConnect;
  late MockDisconnectFromLgUseCase mockDisconnect;

  setUp(() {
    mockRepository = MockLGRepository();
    mockSshService = MockISshService();
    mockConnect = MockConnectToLgUseCase();
    mockDisconnect = MockDisconnectFromLgUseCase();

    when(mockRepository.getSettings()).thenAnswer((_) async => null);
    when(mockSshService.isConnected).thenReturn(false);
  });

  /// Helper: build MainPage with provider overrides
  ProviderContainer buildContainer({int initialIndex = 0}) {
    final container = ProviderContainer(
      overrides: [
        connectionProvider.overrideWith((ref) => ConnectionNotifier(
              mockConnect,
              mockDisconnect,
              mockRepository,
              mockSshService,
            )),
      ],
    );
    if (initialIndex != 0) {
      container.read(navigationProvider.notifier).setIndex(initialIndex);
    }
    return container;
  }

  group('MainPage - Navigation', () {
    testWidgets('should show HomePage by default (index 0)', (tester) async {
      final container = buildContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: MainPage()),
        ),
      );
      await tester.pumpAndSettle();

      // HomePage content — no AppBar for index 0
      expect(find.text('Liquid Galaxy'), findsOneWidget);
      expect(find.text('Controller'), findsOneWidget);
    });

    testWidgets('should show Settings AppBar when index is 1', (tester) async {
      final container = buildContainer(initialIndex: 1);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: MainPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should have a drawer', (tester) async {
      final container = buildContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: MainPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Open the drawer
      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Verify drawer content
      expect(find.text('LG Controller'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
    });

    testWidgets('should navigate to Settings when tapped in drawer',
        (tester) async {
      final container = buildContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: MainPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Open the drawer
      final scaffoldState =
          tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Tap Settings in drawer
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify navigation index changed
      expect(container.read(navigationProvider), 1);
    });
  });
}
