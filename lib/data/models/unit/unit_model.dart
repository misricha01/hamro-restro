/// A measuring unit (e.g. `kg`, `ltr`) used by Dish/Stock Item `unitId`
/// fields. Confirmed against a real `GET /api/unit` response — `name` is the
/// short form (e.g. "kg"), `description` the long-form text (e.g. "Kilogram
/// unit"), matching the backend's own `CreateUnitDTO` example.
class Unit {
  final String? id;
  final String name;
  final String? description;

  const Unit({required this.id, required this.name, this.description});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id']?.toString(),
      name: (json['name'] ?? json['unitName'] ?? '').toString(),
      description: json['description'] as String?,
    );
  }
}
