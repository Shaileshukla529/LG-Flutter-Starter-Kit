import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/domain/entities/fly_to_entity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lg_flutter_stater_kit/domain/repositories/lg_repository.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/connect_to_lg.dart';

// Import the generated file (will be created by build_runner)
import 'connect_to_lg_test.mocks.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
// flutter test test/domain/usecases/connect_to_lg_test.dart
@GenerateMocks([LGRepository])
void main() {
  late MockLGRepository mockLGRepository;
  late ConnectToLgUseCase useCase;
  late FlyToLocationUseCase flyUseCase;
  late DisconnectFromLgUseCase disconnectUseCase;

  setUp(() {
    mockLGRepository = MockLGRepository();
    useCase = ConnectToLgUseCase(mockLGRepository);
    flyUseCase = FlyToLocationUseCase(mockLGRepository);
    disconnectUseCase = DisconnectFromLgUseCase(mockLGRepository);
  });

  group('ConnectToLgUseCase', () {
    test('should call repository.connect with correct arguments', () async {
      // 1. Arrange
      const ip = '192.168.0.10';
      const user = 'lg';
      const pass = 'lg';
      const port = 22;

      // Stub the repository method
      when(mockLGRepository.connect(any, any, any, any))
          .thenAnswer((_) async {});

      // 2. Act
      await useCase.call(ip, user, pass, port);

      // 3. Assert
      verify(mockLGRepository.connect(ip, user, pass, port)).called(1);
    });

    test('should rethrow exception when repository fails', () async {
      // 1. Arrange (Failure Scenario)
      const ip = '192.168.0.10';

      // Stub the repository to THROW an error
      when(mockLGRepository.connect(any, any, any, any))
          .thenThrow(Exception('Connection Failed'));

      // 2. Act & 3. Assert (Check validation)
      // Expect that calling the function throws an Exception
      expect(() => useCase.call(ip, 'lg', 'lg', 22), throwsException);
    });
  });

  group('FlyToLocationUseCase', () {
    test('should call repository.flyTo with correct entity values', () async {
      // 1. Arrange
      // NOTE: The UseCase HARDCODES altitude to 0, tilt to 45, heading to 0.
      // So we must expect those exact values.
      const destination = FlyToEntity(
        latitude: 10.0,
        longitude: 20.0,
        altitude: 0, // <--- Corrected from 100 to 0
        heading: 0,
        tilt: 45,
        range: 1000,
        altitudeMode: 'relativeToGround',
      );

      when(mockLGRepository.flyTo(any)).thenAnswer((_) async {});

      // 2. Act
      await flyUseCase.call(10.0, 20.0);

      // 3. Assert
      verify(mockLGRepository.flyTo(destination)).called(1);
    });
  });

  group('DisconnectFromLgUseCase', () {
    test('should call repository.disconnect', () async {
      // 1. Arrange
      when(mockLGRepository.disconnect()).thenAnswer((_) async {});

      // 2. Act
      await disconnectUseCase.call();

      // 3. Assert
      verify(mockLGRepository.disconnect()).called(1);
    });
  });
}
