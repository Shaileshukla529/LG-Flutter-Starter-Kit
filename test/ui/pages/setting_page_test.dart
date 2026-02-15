import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/domain/entities/connection_entity.dart';
import 'package:lg_flutter_stater_kit/domain/repositories/lg_repository.dart';
import 'package:lg_flutter_stater_kit/domain/services/ssh_service_interface.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/connect_to_lg.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/system_control.dart';
import 'package:lg_flutter_stater_kit/ui/pages/setting_page.dart';
import 'package:lg_flutter_stater_kit/ui/providers/connection_provider.dart';
import 'package:lg_flutter_stater_kit/ui/providers/lg_providers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  LGRepository,
  ISshService,
  ConnectToLgUseCase,
  DisconnectFromLgUseCase,
  RebootLgUseCase,
  RelaunchLgUseCase,
  ShutdownLgUseCase,
])
import 'setting_page_test.mocks.dart';

void main() {
  late MockLGRepository mockRepository;
  late MockISshService mockSshService;
  late MockConnectToLgUseCase mockConnect;
  late MockDisconnectFromLgUseCase mockDisconnect;
  late MockRebootLgUseCase mockReboot;
  late MockRelaunchLgUseCase mockRelaunch;
  late MockShutdownLgUseCase mockShutdown;

  setUp(() {
    mockRepository = MockLGRepository();
    mockSshService = MockISshService();
    mockConnect = MockConnectToLgUseCase();
    mockDisconnect = MockDisconnectFromLgUseCase();
    mockReboot = MockRebootLgUseCase();
    mockRelaunch = MockRelaunchLgUseCase();
    mockShutdown = MockShutdownLgUseCase();

    when(mockRepository.getSettings()).thenAnswer((_) async => null);
    when(mockSshService.isConnected).thenReturn(false);
  });

  /// Helper to pump the SettingsPage with provider overrides
  Widget buildSettingsPage({bool connected = false}) {
    return ProviderScope(
      overrides: [
        connectionProvider.overrideWith((ref) {
          final notifier = ConnectionNotifier(
            mockConnect,
            mockDisconnect,
            mockRepository,
            mockSshService,
          );
          if (connected) {
            notifier.state = const ConnectionEntity(
              ip: '192.168.1.100',
              username: 'lg',
              password: 'lg',
              port: 22,
              isConnected: true,
            );
          }
          return notifier;
        }),
        rebootLgUseCaseProvider.overrideWithValue(mockReboot),
        relaunchLgUseCaseProvider.overrideWithValue(mockRelaunch),
        shutdownLgUseCaseProvider.overrideWithValue(mockShutdown),
      ],
      child: const MaterialApp(home: SettingsPage()),
    );
  }

  group('SettingsPage - Layout', () {
    testWidgets('should display section headers', (tester) async {
      await tester.pumpWidget(buildSettingsPage());
      await tester.pumpAndSettle();

      expect(find.text('Connection Settings'), findsOneWidget);
      expect(find.text('System Operations'), findsOneWidget);
    });

    testWidgets('should display all input fields', (tester) async {
      await tester.pumpWidget(buildSettingsPage());
      await tester.pumpAndSettle();

      expect(find.text('IP Address'), findsOneWidget);
      expect(find.text('User Name'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Port Number'), findsOneWidget);
    });

    testWidgets('should display connect button when disconnected',
        (tester) async {
      await tester.pumpWidget(buildSettingsPage());
      await tester.pumpAndSettle();

      expect(find.text('CONNECT TO RIG'), findsOneWidget);
      expect(find.text('DISCONNECT'), findsNothing);
    });

    testWidgets('should display both buttons when connected', (tester) async {
      when(mockSshService.isConnected).thenReturn(true);

      await tester.pumpWidget(buildSettingsPage(connected: true));
      await tester.pumpAndSettle();

      expect(find.text('CONNECTED'), findsOneWidget);
      expect(find.text('DISCONNECT'), findsOneWidget);
    });
  });

  group('SettingsPage - System Operations', () {
    testWidgets('should display all 4 operation cards', (tester) async {
      await tester.pumpWidget(buildSettingsPage());
      await tester.pumpAndSettle();

      // Scroll to make operations visible
      await tester.scrollUntilVisible(
        find.text('Relaunch'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Relaunch'), findsOneWidget);
      expect(find.text('Reboot'), findsOneWidget);
      expect(find.text('Shutdown'), findsOneWidget);
      expect(find.text('Test Polygon'), findsOneWidget);
    });

    testWidgets('should show warning when operation tapped while disconnected',
        (tester) async {
      await tester.pumpWidget(buildSettingsPage());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Relaunch'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('Relaunch'));
      await tester.pumpAndSettle();

      expect(find.text('Not connected to Liquid Galaxy!'), findsOneWidget);
    });
  });
}
