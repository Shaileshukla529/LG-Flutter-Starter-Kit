import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/data/datasources/places_remote_datasource.dart';
import 'package:lg_flutter_stater_kit/data/models/fly_to_model.dart';
import 'package:lg_flutter_stater_kit/data/models/place_model.dart';
import 'package:lg_flutter_stater_kit/data/repositories/places_repository_impl.dart';
import 'package:lg_flutter_stater_kit/domain/entities/fly_to_entity.dart';
import 'package:lg_flutter_stater_kit/domain/entities/place_entity.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([PlacesRemoteDataSource])
import 'places_repository_impl_test.mocks.dart';

void main() {
  late PlacesRepositoryImpl repository;
  late MockPlacesRemoteDataSource mocksPlacesRemoteDataSource;
  setUp(() {
    mocksPlacesRemoteDataSource = MockPlacesRemoteDataSource();
    repository = PlacesRepositoryImpl(mocksPlacesRemoteDataSource);
  });
  group('Place Repository Implementation', () {
    group('serachplaces', () {
      test(
          ' given mock data return List Place Model Repo should return List place Entity',
          () async {
        // 1. Arrange
        final tModels = [PlaceModel(placeId: '1', description: 'Test')];
        final tEntities = [PlaceEntity(placeId: '1', description: 'Test')];

        when(mocksPlacesRemoteDataSource.searchPlaces(any))
            .thenAnswer((_) async => tModels);

        // 2. Act
        final result = await repository.searchPlaces('query');

        // 3. Assert
        expect(result, tEntities);
        verify(mocksPlacesRemoteDataSource.searchPlaces('query')).called(1);
      });
      test(' given mock data return [] Repo should return []', () async {
        when(mocksPlacesRemoteDataSource.searchPlaces(any))
            .thenAnswer((_) async => []);

        // 2. Act
        final result = await repository.searchPlaces('query');

        // 3. Assert
        expect(result, []);
      });
    });

    group('getPlaceDetails', () {
      test(' given Mock data source return null the repo should return null',
          () async {
        when(mocksPlacesRemoteDataSource.getPlaceDetails('query'))
            .thenAnswer((_) async => null);

        // 2. Act
        final result = await repository.getPlaceDetails('query');

        // 3. Assert
        expect(result, null);
      });
      test(
          ' given Mock data source return FlyToModel the repo should return FlyToEntity ',
          () async {
        // 1. Arrange
        const flyModel = FlyToModel(
            latitude: 10,
            longitude: 10,
            altitude: 10,
            range: 10,
            tilt: 10,
            heading: 10);
        const flyEntity = FlyToEntity(
            latitude: 10,
            longitude: 10,
            altitude: 10,
            range: 10,
            tilt: 10,
            heading: 10);

        when(mocksPlacesRemoteDataSource.getPlaceDetails('query'))
            .thenAnswer((_) async => flyModel);

        final result = await repository.getPlaceDetails('query');
        expect(result, flyEntity);
      });
    });
  });
}
