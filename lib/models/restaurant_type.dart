/// One entry from `GET /api/type-of-restro` (e.g. "FastFood", "Cafe").
/// Field names are inferred from the standard `{id, name}` shape used
/// elsewhere in this API — verify against the actual response if Save
/// starts rejecting `restaurantTypeId`.
class RestaurantType {
  final String id;
  final String name;

  const RestaurantType({required this.id, required this.name});

  factory RestaurantType.fromJson(Map<String, dynamic> json) {
    return RestaurantType(
      id: json['id'].toString(),
      name: json['name'] as String? ?? json['title'] as String? ?? '',
    );
  }
}
