import '../entities/place_entity.dart';
import '../entities/fly_to_entity.dart';

abstract class PlacesRepository {
  /// Returns a list of predictions based on the query.
  Future<List<PlaceEntity>> searchPlaces(String query);

  /// Returns the Lat/Lng of a specific place ID.
  /// We return FlyToEntity for convenience, or you could return a simple LatLng object.
  Future<FlyToEntity?> getPlaceDetails(String placeId);
}
