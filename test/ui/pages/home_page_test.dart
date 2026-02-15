import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/ui/providers/navigation_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lg_flutter_stater_kit/domain/entities/connection_entity.dart';
import 'package:lg_flutter_stater_kit/domain/repositories/lg_repository.dart';
import 'package:lg_flutter_stater_kit/domain/services/ssh_service_interface.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/connect_to_lg.dart';
import 'package:lg_flutter_stater_kit/ui/pages/home_page.dart';
import 'package:lg_flutter_stater_kit/ui/providers/connection_provider.dart';

@GenerateMocks(
    [LGRepository, ISshService, ConnectToLgUseCase, DisconnectFromLgUseCase])
import 'home_page_test.mocks.dart';

void main() {
  late MockLGRepository mockRepository;
  late MockISshService mockSshService;
  late MockConnectToLgUseCase mockConnectUseCase;
  late MockDisconnectFromLgUseCase mockDisconnectUseCase;

  setUp(() {
    mockRepository = MockLGRepository();
    mockSshService = MockISshService();
    mockConnectUseCase = MockConnectToLgUseCase();
    mockDisconnectUseCase = MockDisconnectFromLgUseCase();

    // Default stub for getSettings
    when(mockRepository.getSettings()).thenAnswer((_) async => null);
    when(mockSshService.isConnected).thenReturn(false);
  });

  group('Home Page test cases', () {
    testWidgets('Home page displays Liquid Galaxy Controller correctly',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionProvider.overrideWith((ref) => ConnectionNotifier(
                  mockConnectUseCase,
                  mockDisconnectUseCase,
                  mockRepository,
                  mockSshService,
                )),
          ],
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Liquid Galaxy'), findsOneWidget);
      expect(find.text('Controller'), findsOneWidget);
      expect(find.text("Gemini's Summer of Code"), findsOneWidget);
    });

    testWidgets('HomePage displays disconnected status correctly',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionProvider.overrideWith((ref) => ConnectionNotifier(
                  mockConnectUseCase,
                  mockDisconnectUseCase,
                  mockRepository,
                  mockSshService,
                )),
          ],
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify disconnected state
      expect(find.text('Disconnected'), findsOneWidget);
      expect(find.text('Connect from settings to get started'), findsOneWidget);
    });

    testWidgets('Quick action shows warning when disconnected', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionProvider.overrideWith((ref) => ConnectionNotifier(
                  mockConnectUseCase,
                  mockDisconnectUseCase,
                  mockRepository,
                  mockSshService,
                )),
          ],
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final cleanKmlCard = find.ancestor(
        of: find.text('Clean KML'),
        matching: find.byType(InkWell),
      );

      expect(cleanKmlCard, findsOneWidget);
      await tester.tap(cleanKmlCard);
      await tester.pumpAndSettle();

      // Verify warning appears
      expect(find.text('Not connected to Liquid Galaxy!'), findsOneWidget);
    });

    testWidgets('Quick action executes when connected', (tester) async {
      // Mock connected state
      when(mockSshService.isConnected).thenReturn(true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionProvider.overrideWith((ref) {
              final notifier = ConnectionNotifier(
                mockConnectUseCase,
                mockDisconnectUseCase,
                mockRepository,
                mockSshService,
              );

              notifier.state = const ConnectionEntity(
                ip: '192.168.1.100',
                username: 'lg',
                password: 'lg',
                port: 22,
                isConnected: true,
              );
              return notifier;
            }),
          ],
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify connected state is shown
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('lg@192.168.1.100:22'), findsOneWidget);
    });

    testWidgets('When click on view map, navigation index changes to 2',
        (tester) async {
      // 1. Setup the container to track state
      final container = ProviderContainer(
        overrides: [
          connectionProvider.overrideWith((ref) => ConnectionNotifier(
                mockConnectUseCase,
                mockDisconnectUseCase,
                mockRepository,
                mockSshService,
              )),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        // Do not create conatiner and use the custom one
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final viewMapFinder = find.text('View Map');

      await tester.scrollUntilVisible(
        viewMapFinder,
        500.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(viewMapFinder);
      await tester.pumpAndSettle();

      // 5. Verify the state in the container
      expect(container.read(navigationProvider), 2);
    });
  });

  testWidgets(' When click on settings icon, navigation index changes to 1',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        connectionProvider.overrideWith((ref) => ConnectionNotifier(
              mockConnectUseCase,
              mockDisconnectUseCase,
              mockRepository,
              mockSshService,
            )),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final settingsFinder = find.byKey(Key('Settings Icons'));

    await tester.tap(settingsFinder);
    await tester.pumpAndSettle();

    // 5. Verify the state in the container
    expect(container.read(navigationProvider), 1);
  });
}
