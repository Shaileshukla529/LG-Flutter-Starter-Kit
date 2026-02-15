import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/domain/entities/place_entity.dart';
import 'package:lg_flutter_stater_kit/domain/entities/fly_to_entity.dart';
import 'package:lg_flutter_stater_kit/domain/repositories/places_repository.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/search_places.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/get_place_details.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([PlacesRepository])
import 'places_usecases_test.mocks.dart';

void main() {
  late MockPlacesRepository mockRepository;

  setUp(() {
    mockRepository = MockPlacesRepository();
  });

  group('SearchPlaces', () {
    test('should delegate search to PlacesRepository and return results',
        () async {
      final mockResults = [
        PlaceEntity(description: 'New Delhi', placeId: 'abc'),
        PlaceEntity(description: 'New York', placeId: 'xyz'),
      ];
      when(mockRepository.searchPlaces(any))
          .thenAnswer((_) async => mockResults);

      final useCase = SearchPlaces(mockRepository);
      final result = await useCase.call('New');

      expect(result.length, 2);
      expect(result[0].description, 'New Delhi');
      verify(mockRepository.searchPlaces('New')).called(1);
    });

    test('should return empty list when no results found', () async {
      when(mockRepository.searchPlaces(any)).thenAnswer((_) async => []);

      final useCase = SearchPlaces(mockRepository);
      final result = await useCase.call('zzzzz');

      expect(result, isEmpty);
      verify(mockRepository.searchPlaces('zzzzz')).called(1);
    });
  });

  group('GetPlaceDetails', () {
    test('should delegate to PlacesRepository and return FlyToEntity',
        () async {
      final mockEntity = FlyToEntity(
        latitude: 28.6139,
        longitude: 77.2090,
        altitude: 0,
        range: 1000,
        tilt: 45,
        heading: 0,
      );
      when(mockRepository.getPlaceDetails(any))
          .thenAnswer((_) async => mockEntity);

      final useCase = GetPlaceDetails(mockRepository);
      final result = await useCase.call('abc123');

      expect(result, isNotNull);
      expect(result!.latitude, 28.6139);
      verify(mockRepository.getPlaceDetails('abc123')).called(1);
    });

    test('should return null when place is not found', () async {
      when(mockRepository.getPlaceDetails(any)).thenAnswer((_) async => null);

      final useCase = GetPlaceDetails(mockRepository);
      final result = await useCase.call('invalid_id');

      expect(result, isNull);
      verify(mockRepository.getPlaceDetails('invalid_id')).called(1);
    });
  });
}
