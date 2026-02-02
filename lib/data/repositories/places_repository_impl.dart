import '../../domain/entities/fly_to_entity.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource _dataSource;

  PlacesRepositoryImpl(this._dataSource);

  @override
  Future<List<PlaceEntity>> searchPlaces(String query) async {
    return await _dataSource.searchPlaces(query);
  }

  @override
  Future<FlyToEntity?> getPlaceDetails(String placeId) async {
    return await _dataSource.getPlaceDetails(placeId);
  }
}
