class PlaceEntity {
  final String description;
  final String placeId;

  const PlaceEntity({
    required this.description,
    required this.placeId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceEntity &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          placeId == other.placeId;

  @override
  int get hashCode => description.hashCode ^ placeId.hashCode;

  @override
  String toString() =>
      'PlaceEntity(description: $description, placeId: $placeId)';
}
