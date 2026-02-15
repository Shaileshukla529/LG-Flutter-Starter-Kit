import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/domain/repositories/lg_repository.dart';
import 'package:lg_flutter_stater_kit/domain/repositories/places_repository.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/connect_to_lg.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/system_control.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/search_places.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/get_place_details.dart';
import 'package:lg_flutter_stater_kit/ui/providers/lg_providers.dart';
import 'package:mockito/annotations.dart';
import 'lg_providers_test.mocks.dart';

@GenerateMocks([LGRepository, PlacesRepository])
void main() {
  late MockLGRepository mockLGRepository;
  late MockPlacesRepository mockPlacesRepository;
  late ProviderContainer container;

  setUp(() {
    mockLGRepository = MockLGRepository();
    mockPlacesRepository = MockPlacesRepository();
    container = ProviderContainer(
      overrides: [
        lgRepositoryProvider.overrideWithValue(mockLGRepository),
        placesRepositoryProvider.overrideWithValue(mockPlacesRepository),
      ],
    );
  });
  tearDown(() {
    container.dispose();
  });

  group('LG Use Case Providers Wiring', () {
    test('should provide ConnectToLgUseCase correctly', () {
      final useCase = container.read(connectToLgUseCaseProvider);
      expect(useCase, isA<ConnectToLgUseCase>());
    });

    test('should provide DisconnectFromLgUseCase correctly', () {
      final useCase = container.read(disconnectFromLgUseCaseProvider);
      expect(useCase, isA<DisconnectFromLgUseCase>());
    });

    test('should provide FlyToLocationUseCase correctly', () {
      final useCase = container.read(flyToLocationUseCaseProvider);
      expect(useCase, isA<FlyToLocationUseCase>());
    });
  });

  group('System Control Use Case Providers Wiring', () {
    test('should provide RebootLgUseCase correctly', () {
      final useCase = container.read(rebootLgUseCaseProvider);
      expect(useCase, isA<RebootLgUseCase>());
    });

    test('should provide RelaunchLgUseCase correctly', () {
      final useCase = container.read(relaunchLgUseCaseProvider);
      expect(useCase, isA<RelaunchLgUseCase>());
    });

    test('should provide ShutdownLgUseCase correctly', () {
      final useCase = container.read(shutdownLgUseCaseProvider);
      expect(useCase, isA<ShutdownLgUseCase>());
    });

    test('should provide CleanAllKmlUseCase correctly', () {
      final useCase = container.read(cleanKmlUseCaseProvider);
      expect(useCase, isA<CleanAllKmlUseCase>());
    });

    test('should provide CleanLogoUseCase correctly', () {
      final useCase = container.read(cleanLogoUseCaseProvider);
      expect(useCase, isA<CleanLogoUseCase>());
    });

    test('should provide SendLogoUseCase correctly', () {
      final useCase = container.read(sendLogoUseCaseProvider);
      expect(useCase, isA<SendLogoUseCase>());
    });
  });

  group('Places Use Case Providers Wiring', () {
    test('should provide SearchPlaces correctly', () {
      final useCase = container.read(searchPlacesUseCaseProvider);
      expect(useCase, isA<SearchPlaces>());
    });

    test('should provide GetPlaceDetails correctly', () {
      final useCase = container.read(getPlaceDetailsUseCaseProvider);
      expect(useCase, isA<GetPlaceDetails>());
    });
  });
}
