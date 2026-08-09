/// A menu category (backend: `menu-category`), e.g. "Breakfast", "Lunch".
///
/// Named `MenuCategory` (not `Category`) to avoid clashing with Flutter's
/// own `Category` annotation class exported by `foundation.dart`.
class MenuCategory {
  final String id;
  final String categoryName;
  final String? image;
  final String? imageUrl;

  const MenuCategory({required this.id, required this.categoryName, this.image, this.imageUrl});

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    // Same "flat media id on create, nested media object when expanded"
    // shape seen on Dish's `dishPhoto` — handle both. See DishModel.
    final rawImage = json['image'];
    return MenuCategory(
      id: json['id'].toString(),
      categoryName: json['categoryName'] as String? ?? '',
      image: switch (rawImage) {
        String s => s,
        Map<String, dynamic> m => m['id']?.toString(),
        _ => null,
      },
      imageUrl: rawImage is Map<String, dynamic> ? rawImage['url'] as String? : null,
    );
  }
}
