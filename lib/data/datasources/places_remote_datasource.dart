import 'package:dio/dio.dart';
import 'package:lg_flutter_stater_kit/core/constant/log_service.dart';
import '../models/place_model.dart';
import '../models/fly_to_model.dart';

class PlacesRemoteDataSource {
  final log = LogService();
  final Dio _dio;
  final String _apiKey;

  PlacesRemoteDataSource(this._dio, {required String apiKey})
      : _apiKey = apiKey;

  Future<List<PlaceModel>> searchPlaces(String query) async {
    if (_apiKey.isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _apiKey,
        },
      );
      log.d(response.toString());

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          return (data['predictions'] as List)
              .map((json) => PlaceModel.fromJson(json))
              .toList();
        }
        if (data['status'] == 'ZERO_RESULTS') {
          return [];
        }
        throw Exception(data['error_message'] ?? data['status']);
      }

      throw Exception('Failed to load places: ${response.statusCode}');
    } catch (e) {
      log.e('PlacesRemoteDataSource Search Error: $e');
      rethrow;
    }
  }

  Future<FlyToModel?> getPlaceDetails(String placeId) async {
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
      log.d(response.toString());

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          return FlyToModel.fromPlacesApiJson(location);
        }
        if (data['status'] == 'ZERO_RESULTS' || data['status'] == 'NOT_FOUND') {
          return null;
        }
        // Throw proper API error message
        throw Exception(data['error_message'] ?? data['status']);
      }

      throw Exception('Failed to get place details: ${response.statusCode}');
    } catch (e) {
      log.e('PlacesRemoteDataSource Details Error: $e');
      rethrow;
    }
  }
}
