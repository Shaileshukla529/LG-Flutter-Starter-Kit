import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lg_flutter_stater_kit/data/repositories/lg_repository_impl.dart';
import 'package:lg_flutter_stater_kit/data/datasources/ssh_service.dart';
import 'package:lg_flutter_stater_kit/data/datasources/local_storage_source.dart';
import 'package:lg_flutter_stater_kit/domain/entities/connection_entity.dart';
import 'package:lg_flutter_stater_kit/domain/entities/fly_to_entity.dart';

// This is the Magic! 🪄
// We tell Mockito to create "fake" versions of these classes.
@GenerateMocks([SshService, LocalStorageDataSource])
import 'lg_repository_impl_test.mocks.dart';

void main() {
  late LgRepositoryImpl repository;
  late MockSshService mockSshService;
  late MockLocalStorageDataSource mockStorage;

  setUp(() {
    // 1. Initialize the Mocks
    mockSshService = MockSshService();
    mockStorage = MockLocalStorageDataSource();

    // Stub loadSettings - called in constructor's _loadScreenNumber()
    when(mockStorage.loadSettings()).thenAnswer((_) async => null);

    // 2. Pass the Mocks to the Repository
    repository = LgRepositoryImpl(mockSshService, mockStorage);
  });

  // Grouping tests specifically for the 'connect' functionality
  group('connect', () {
    test('should call sshService.connect with correct arguments', () async {
      // 1. Arrange (Given)
      const ip = '192.168.0.10';
      const user = 'lg';
      const pass = 'lg';
      const port = 22;

      // STUB: Return a completed Future (success) when connect is called
      when(mockSshService.connect(any, any, any, any)).thenAnswer((_) async {});

      // We don't expect a return value, just successful execution,
      // so we use verify later. We can stub if needed, e.g.:
      // when(mockSshService.connect(any, any, any, any)).thenAnswer((_) async {});

      // 2. Act (When)
      await repository.connect(ip, user, pass, port);

      // 3. Assert (Then)
      // Verify that the repository actually called the SSH service with the *exact* values we passed.
      verify(mockSshService.connect(ip, pass, user, port)).called(1);
    });
  });

  // Grouping tests for Storage
  group('storeSettings', () {
    test('should save settings to local storage', () async {
      // 1. Arrange
      const ip = '10.0.0.1';

      // STUB: Return success
      when(mockStorage.saveSettings(any)).thenAnswer((_) async {});

      // 2. Act
      await repository.storeSettings(ip, 'user', 'pass', 22);

      // 3. Assert
      // We check that saveSettings was called with an entity containing our IP.
      verify(mockStorage.saveSettings(
        argThat(predicate<ConnectionEntity>((e) => e.ip == ip)),
      )).called(1);
    });
  });

  // Grouping tests for LG Commands (FlyTo)
  group('flyTo', () {
    test('should build correct KML and execute it via SSH', () async {
      // 1. Arrange
      final destination = FlyToEntity(
        latitude: 10.0,
        longitude: 20.0,
        altitude: 100.0,
        heading: 0,
        tilt: 45,
        range: 1000,
        altitudeMode: 'relativeToGround',
      );

      // STUB: Return generic success response
      when(mockSshService.execute(any)).thenAnswer((_) async => 'Success');

      // 2. Act
      await repository.flyTo(destination);

      // 3. Assert
      // This is the tricky part! We need to verify the KML string.
      // We know flyTo calls _uploadKml, which calls _execute('echo "..." > /tmp/query.txt').
      // So we verify execute was called with a string containing our coordinates.
      verify(mockSshService.execute(
        argThat(contains('<latitude>10.0</latitude>')),
      )).called(1);
    });
  });
}
