import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/domain/entities/connection_entity.dart';
import 'package:lg_flutter_stater_kit/domain/repositories/lg_repository.dart';
import 'package:lg_flutter_stater_kit/domain/services/ssh_service_interface.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/connect_to_lg.dart';
import 'package:lg_flutter_stater_kit/ui/providers/connection_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'connection_provider_test.mocks.dart';

@GenerateMocks(
    [LGRepository, ISshService, ConnectToLgUseCase, DisconnectFromLgUseCase])
void main() {
  group('Connection Provider Test- RiverPod Way', () {
    late ProviderContainer container;
    late MockLGRepository mockRepository;
    late MockISshService mockSshService;
    late MockConnectToLgUseCase mockConnectUseCase;
    late MockDisconnectFromLgUseCase mockDisconnectUseCase;
    setUp(() {
      mockRepository = MockLGRepository();
      mockSshService = MockISshService();
      mockConnectUseCase = MockConnectToLgUseCase();
      mockDisconnectUseCase = MockDisconnectFromLgUseCase();
      container = ProviderContainer(overrides: [
        connectionProvider.overrideWith((ref) => ConnectionNotifier(
            mockConnectUseCase,
            mockDisconnectUseCase,
            mockRepository,
            mockSshService))
      ]);
      // Default stub for getSettings
      when(mockRepository.getSettings()).thenAnswer((_) async => null);
      when(mockSshService.isConnected).thenReturn(false);
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default guest values', () {
      final state = container.read(connectionProvider);

      expect(state.ip, '');
      expect(state.port, 22);
      expect(state.password, '');
      expect(state.username, 'lg');
      expect(state.isConnected, false);
    });

    test('should update connection state to true when connect() succeeds',
        () async {
      // Arrange
      final notifier = container.read(connectionProvider.notifier);
      notifier.setIp('192.168.1.1');
      notifier.setPassword('lg');

      when(mockConnectUseCase.call(any, any, any, any))
          .thenAnswer((_) async {});
      when(mockRepository.storeSettings(any, any, any, any))
          .thenAnswer((_) async {});

      // Act
      await notifier.connect();

      // Assert
      final state = container.read(connectionProvider);
      expect(state.isConnected, true);
    });

    test('should throw Exception when connect() is called with empty fields',
        () async {
      // Arrange
      final notifier = container.read(connectionProvider.notifier);
      notifier.setIp(''); // Ensure IP is empty

      // Act & Assert
      expect(() => notifier.connect(), throwsException);
    });

    test('should set isConnected to false when disconnect() succeeds',
        () async {
      // Arrange
      final notifier = container.read(connectionProvider.notifier);
      // Manually set state to connected first (or connect successfully)
      when(mockConnectUseCase.call(any, any, any, any))
          .thenAnswer((_) async {});
      when(mockRepository.storeSettings(any, any, any, any))
          .thenAnswer((_) async {});
      notifier.setIp('1.1.1.1');
      notifier.setPassword('p');
      await notifier.connect();

      when(mockDisconnectUseCase.call()).thenAnswer((_) async {});

      // Act
      await notifier.disconnect();

      // Assert
      final state = container.read(connectionProvider);
      expect(state.isConnected, false);
    });

    test(
        'should update state to disconnected when SSH service loses connection',
        () async {
      // Arrange
      final notifier = container.read(connectionProvider.notifier);
      // Connect first
      when(mockConnectUseCase.call(any, any, any, any))
          .thenAnswer((_) async {});
      when(mockRepository.storeSettings(any, any, any, any))
          .thenAnswer((_) async {});
      notifier.setIp('1.1.1.1');
      notifier.setPassword('p');
      await notifier.connect();

      // Act: Extract the callback assigned in constructor and call it
      final captured = verify(mockSshService.onConnectionLost = captureAny)
          .captured
          .single as void Function();
      captured();

      // Assert
      final state = container.read(connectionProvider);
      expect(state.isConnected, false);
    });
  });

  group('ConnectionProvider - Initialization', () {
    test('should load saved settings from repository on creation', () async {
      // Arrange
      final mockRepo = MockLGRepository();
      final mockSsh = MockISshService();
      final mockConn = MockConnectToLgUseCase();
      final mockDis = MockDisconnectFromLgUseCase();

      final savedEntity = const ConnectionEntity(
        ip: '10.0.0.1',
        port: 2222,
        username: 'admin',
        password: 'password',
      );

      when(mockRepo.getSettings()).thenAnswer((_) async => savedEntity);
      when(mockSsh.isConnected).thenReturn(false);

      // Act
      final container = ProviderContainer(overrides: [
        connectionProvider.overrideWith(
            (ref) => ConnectionNotifier(mockConn, mockDis, mockRepo, mockSsh))
      ]);

      // Assert: Wait for internal _loadSettings to finish
      // We wait until the IP is correctly loaded or timeout
      int attempts = 0;
      while (container.read(connectionProvider).ip != '10.0.0.1' &&
          attempts < 10) {
        await pumpEventQueue();
        attempts++;
      }

      final state = container.read(connectionProvider);
      expect(state.ip, '10.0.0.1');
      expect(state.port, 2222);
      expect(state.username, 'admin');
    });
  });
}
