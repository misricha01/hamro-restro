/// A "Sub-Menu" in this app's UI language (e.g. "Food Menu", "Bar Menu",
/// "Cafe Menu"). Backend: `/api/type-of-menu`.
class TypeOfMenu {
  final String id;
  final String name;
  final String? description;
  final bool status;

  const TypeOfMenu({required this.id, required this.name, this.description, this.status = true});

  factory TypeOfMenu.fromJson(Map<String, dynamic> json) {
    return TypeOfMenu(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as bool? ?? true,
    );
  }
}
