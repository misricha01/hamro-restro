import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/dish/dish_model.dart';
import '../../data/models/variant/variant_model.dart';

/// Shared building blocks for the Menu Setup screens (Default Menu Set,
/// Sub Menu detail) — kept in one place so the Dishes/Sub Menu/Category
/// tabs render identically everywhere they're reused, per the reference
/// screenshots.

/// Computes the same "Rs X" / "Rs X - Rs Y" label the reference screenshots
/// show: a single price for dishes with no variants, or the min-max range
/// across the dish's variant listed prices (falling back to the dish's own
/// price as one more data point) when it has variants.
String dishPriceLabel(Dish dish, List<Variant> allVariants) {
  final variantPrices = allVariants.where((v) => dish.variantIds.contains(v.id)).map((v) => v.listedPrice).toList();
  final basePrice = dish.priceAfterDiscount ?? dish.price;

  if (variantPrices.isEmpty) {
    return basePrice == null ? 'Rs —' : 'Rs ${basePrice.toStringAsFixed(0)}';
  }

  final prices = [if (basePrice != null && basePrice > 0) basePrice, ...variantPrices];
  final minPrice = prices.reduce((a, b) => a < b ? a : b);
  final maxPrice = prices.reduce((a, b) => a > b ? a : b);
  if (minPrice == maxPrice) return 'Rs ${minPrice.toStringAsFixed(0)}';
  return 'Rs ${minPrice.toStringAsFixed(0)} - Rs ${maxPrice.toStringAsFixed(0)}';
}

/// A single dish row: circular photo, name, category-name subtitle, price
/// on the right — the "Dishes" tab layout shared by [DefaultMenuSetScreen]
/// and [SubMenuDetailScreen].
class MenuSetupDishRow extends StatelessWidget {
  final Dish dish;
  final String categoryName;
  final String priceLabel;
  final VoidCallback? onTap;

  const MenuSetupDishRow({super.key, required this.dish, required this.categoryName, required this.priceLabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            MenuSetupDishAvatar(dish: dish, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.dishName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, decoration: TextDecoration.none),
                  ),
                  if (categoryName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(categoryName, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(priceLabel, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

/// Circular dish photo with an icon fallback, shared by [MenuSetupDishRow]
/// and [DishQuickViewSheet] so the "no photo yet" look stays identical.
class MenuSetupDishAvatar extends StatelessWidget {
  final Dish dish;
  final double size;

  const MenuSetupDishAvatar({super.key, required this.dish, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: dish.dishPhotoUrl != null
          ? Image.network(
              '${ApiClient.mediaBaseUrl}${dish.dishPhotoUrl}',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      color: AppTheme.surface,
      child: Icon(Icons.restaurant_menu, color: AppTheme.accent, size: size * 0.45),
    );
  }
}

/// Empty state for a Dishes list with nothing in it — matches the "No Dish"
/// reference screenshot's copy (using this app's own icon language rather
/// than the reference's illustration asset, which isn't available here).
class MenuSetupNoDishState extends StatelessWidget {
  const MenuSetupNoDishState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
              child: const Icon(Icons.no_food_outlined, color: AppTheme.accent, size: 40),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                children: [
                  TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                  TextSpan(text: 'Dish', style: TextStyle(color: AppTheme.cancelled)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No Dish found. Needs to create the Dish!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
            ),
          ],
        ),
      ),
    );
  }
}

/// Picks a themed icon for a Sub Menu / Category card from its name — same
/// "best-effort keyword lookup, generic fallback" approach already used for
/// Dish Type icons in [SelectDishTypeSheet].
IconData menuSetupIconFor(String name) {
  final n = name.toLowerCase();
  if (n.contains('bar') || n.contains('drink') || n.contains('beverage')) return Icons.local_bar_outlined;
  if (n.contains('cafe') || n.contains('coffee')) return Icons.coffee_outlined;
  if (n.contains('food') || n.contains('lunch') || n.contains('dinner')) return Icons.ramen_dining_outlined;
  if (n.contains('dessert') || n.contains('sweet')) return Icons.icecream_outlined;
  return Icons.restaurant_menu_outlined;
}

/// Dark card grid tile used by the "Sub Menu" tab — icon, name, dish count.
class MenuSetupSubMenuCard extends StatelessWidget {
  final String name;
  final int dishCount;
  final VoidCallback onTap;

  const MenuSetupSubMenuCard({super.key, required this.name, required this.dishCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(menuSetupIconFor(name), size: 32, color: AppTheme.accent),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 2),
              Text(
                '$dishCount Dishes',
                style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Light card grid tile used by the top-level "Category" tab.
class MenuSetupCategoryCard extends StatelessWidget {
  final String name;
  final int dishCount;
  final VoidCallback? onTap;

  const MenuSetupCategoryCard({super.key, required this.name, required this.dishCount, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(menuSetupIconFor(name), size: 30, color: AppTheme.accent),
            const SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 2),
            Text('$dishCount Dish', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

/// Row layout used for the "Category" tab when viewed *inside* a specific
/// Sub Menu (Food/Bar/Cafe Menu), matching the reference's leading
/// drag-handle look. The handle is decorative only — there's no reorder
/// endpoint for categories to persist a drag against.
class MenuSetupCategoryRow extends StatelessWidget {
  final String name;
  final int dishCount;

  const MenuSetupCategoryRow({super.key, required this.name, required this.dishCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
            child: Icon(menuSetupIconFor(name), color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
                Text('$dishCount Dishes', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
