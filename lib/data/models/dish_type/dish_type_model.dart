/// A Dish Type (backend: `dish-type`), e.g. "Veg", "Non-Veg", "Vegan".
class DishType {
  final String id;
  final String dishTypeName;

  const DishType({required this.id, required this.dishTypeName});

  factory DishType.fromJson(Map<String, dynamic> json) {
    return DishType(
      id: json['id'].toString(),
      dishTypeName: json['dishTypeName'] as String? ?? '',
    );
  }
}
