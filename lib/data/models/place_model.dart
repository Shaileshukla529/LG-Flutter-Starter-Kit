import '../../domain/entities/place_entity.dart';

/// Data layer model for Place - handles JSON serialization
/// This separates data layer concerns from domain entities
class PlaceModel {
  final String description;
  final String placeId;

  const PlaceModel({
    required this.description,
    required this.placeId,
  });

  /// Factory constructor to create PlaceModel from JSON
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'place_id': placeId,
    };
  }

  /// Convert to domain entity
  PlaceEntity toEntity() {
    return PlaceEntity(
      description: description,
      placeId: placeId,
    );
  }

  /// Create from domain entity
  factory PlaceModel.fromEntity(PlaceEntity entity) {
    return PlaceModel(
      description: entity.description,
      placeId: entity.placeId,
    );
  }
}
