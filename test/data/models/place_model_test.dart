import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/data/models/place_model.dart';
import 'package:lg_flutter_stater_kit/domain/entities/place_entity.dart';

void main() {
  group('PlaceModel', () {
    const tDescription = 'Sydney, NSW, Australia';
    const tPlaceId = 'ChIJP3Sa8ziEVDURS9H7y1H7y1g';
    const tPlaceModel = PlaceModel(
      description: tDescription,
      placeId: tPlaceId,
    );
    const tPlaceEntity = PlaceEntity(
      description: tDescription,
      placeId: tPlaceId,
    );

    test('should convert Model to Entity correctly', () {
      // Act
      final result = tPlaceModel.toEntity();

      // Assert
      expect(result, tPlaceEntity);
    });

    test('should create Model from Entity correctly', () {
      // Act
      final result = PlaceModel.fromEntity(tPlaceEntity);

      // Assert
      expect(result.description, tPlaceEntity.description);
      expect(result.placeId, tPlaceEntity.placeId);
    });

    test('should create Model from JSON correctly', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'description': tDescription,
        'place_id': tPlaceId,
      };

      // Act
      final result = PlaceModel.fromJson(jsonMap);

      // Assert
      expect(result.description, tDescription);
      expect(result.placeId, tPlaceId);
    });

    test('should convert Model to JSON correctly', () {
      // Act
      final result = tPlaceModel.toJson();

      // Assert
      final expectedMap = {
        'description': tDescription,
        'place_id': tPlaceId,
      };
      expect(result, expectedMap);
    });
  });
}
