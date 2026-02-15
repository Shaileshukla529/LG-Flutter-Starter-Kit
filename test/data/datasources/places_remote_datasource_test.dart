import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/data/datasources/places_remote_datasource.dart';
import 'package:lg_flutter_stater_kit/data/models/fly_to_model.dart';
import 'package:lg_flutter_stater_kit/data/models/place_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Dio])
import 'places_remote_datasource_test.mocks.dart';

void main() {
  late MockDio mockdio;
  late PlacesRemoteDataSource dataSource;
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });

  setUp(() {
    mockdio = MockDio();
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    dataSource = PlacesRemoteDataSource(mockdio, apiKey: apiKey);
  });

  group('test cases for searchPlaces', () {
    test('Should return List<PlaceModel> on success', () async {
      when(mockdio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(data: {
                'status': 'OK',
                'predictions': [
                  {'description': 'New_Delhi', 'place_id': 'abcd'}
                ],
              }, statusCode: 200, requestOptions: RequestOptions(path: '')));
      final val = await dataSource.searchPlaces('New_Delhi');
      expect(val, isA<List<PlaceModel>>());
    });

    test('Throw Exception on internal server error', () async {
      when(mockdio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(data: {
                'status': 'Internal Server Error',
                'error_message': 'Serious error'
              }, statusCode: 500, requestOptions: RequestOptions(path: '')));
      final val = dataSource.searchPlaces('New_Delhi');
      expect(val, throwsException);
    });

    test('Throw Exception on internal server error', () async {
      when(mockdio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(Exception('Some Error Occured'));
      final val = dataSource.searchPlaces('New_Delhi');
      expect(val, throwsException);
    });
  });

  group('test cases for getPlaceDetails', () {
    const tPlaceId = 'abcd';
    const tLat = -33.86;
    const tLng = 151.20;

    test('Should return FlyToModel on success', () async {
      // Arrange
      when(mockdio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'status': 'OK',
                  'result': {
                    'geometry': {
                      'location': {'lat': tLat, 'lng': tLng}
                    }
                  }
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getPlaceDetails(tPlaceId);

      // Assert
      expect(result, isA<FlyToModel>());
      expect(result?.latitude, tLat);
      expect(result?.longitude, tLng);
    });

    test('Should return null when status is ZERO_RESULTS or NOT_FOUND',
        () async {
      // Arrange
      when(mockdio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {'status': 'ZERO_RESULTS'},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getPlaceDetails(tPlaceId);

      // Assert
      expect(result, isNull);
    });

    test('Should throw Exception on API error status', () async {
      // Arrange
      when(mockdio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'status': 'REQUEST_DENIED',
                  'error_message': 'Invalid API Key'
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final call = dataSource.getPlaceDetails(tPlaceId);

      // Assert
      expect(call, throwsException);
    });

    test('Should throw Exception on network/Dio error', () async {
      // Arrange
      when(mockdio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No Internet',
      ));

      // Act
      final call = dataSource.getPlaceDetails(tPlaceId);

      // Assert
      expect(call, throwsException);
    });
  });
}
