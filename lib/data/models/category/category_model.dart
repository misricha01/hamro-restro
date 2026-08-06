/// A menu category (backend: `menu-category`), e.g. "Breakfast", "Lunch".
///
/// Named `MenuCategory` (not `Category`) to avoid clashing with Flutter's
/// own `Category` annotation class exported by `foundation.dart`.
class MenuCategory {
  final String id;
  final String categoryName;

  const MenuCategory({required this.id, required this.categoryName});

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'].toString(),
      categoryName: json['categoryName'] as String? ?? '',
    );
  }
}
