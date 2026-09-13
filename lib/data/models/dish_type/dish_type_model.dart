/// A Dish Type (backend: `dish-type`), e.g. "Veg", "Non-Veg", "Vegan".
class DishType {
  final String id;
  final String dishTypeName;

  const DishType({required this.id, required this.dishTypeName});

  factory DishType.fromJson(Map<String, dynamic> json) {
    return DishType(
      id: json['id'].toString(),
      // The backend's dish-type resource calls this field `name`, not
      // `dishTypeName` — confirmed live (`GET /api/dish-type` returns
      // `{"id":"4","name":"Veg",...}`). Kept as `dishTypeName` on this
      // Dart model since that's what every call site already expects.
      dishTypeName: json['name'] as String? ?? '',
    );
  }
}
