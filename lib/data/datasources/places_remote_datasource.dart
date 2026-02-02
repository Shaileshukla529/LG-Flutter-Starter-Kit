import 'package:dio/dio.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/fly_to_entity.dart';
import '../models/place_model.dart';
import '../models/fly_to_model.dart';

class PlacesRemoteDataSource {
  final Dio _dio;
  final String _apiKey;

  // We inject Dio for testability and API Key for config
  PlacesRemoteDataSource(this._dio, {required String apiKey})
      : _apiKey = apiKey;

  Future<List<PlaceEntity>> searchPlaces(String query) async {
    if (_apiKey.isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final List predictions = response.data['predictions'];
        // Use PlaceModel for JSON parsing, then convert to entity
        return predictions
            .map((json) => PlaceModel.fromJson(json).toEntity())
            .toList();
      }
      return [];
    } catch (e) {
      // In real app: Log error
      print('PlacesRemoteDataSource Search Error: $e');
      return [];
    }
  }

  Future<FlyToEntity?> getPlaceDetails(String placeId) async {
    if (_apiKey.isEmpty) return null;

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry',
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final location = response.data['result']['geometry']['location'];
        // Use FlyToModel for construction, then convert to entity
        return FlyToModel.fromPlacesApiJson(location).toEntity();
      }
      return null;
    } catch (e) {
      print('PlacesRemoteDataSource Details Error: $e');
      return null;
    }
  }
}
