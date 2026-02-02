import '../entities/fly_to_entity.dart';
import '../repositories/places_repository.dart';

class GetPlaceDetails {
  final PlacesRepository repository;

  GetPlaceDetails(this.repository);

  Future<FlyToEntity?> call(String placeId) {
    return repository.getPlaceDetails(placeId);
  }
}
