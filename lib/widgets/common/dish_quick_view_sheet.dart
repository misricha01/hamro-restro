import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/dish/dish_model.dart';
import '../../data/models/variant/variant_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/dish_provider.dart';
import '../../providers/variant_provider.dart';
import '../../screens/create_dish/add_dish_screen.dart' show AddDishScreen;
import 'menu_setup_widgets.dart';

/// Quick-view bottom sheet for a single dish, opened by tapping a
/// [MenuSetupDishRow] in the Menu Setup screens (Default Menu Set / Sub Menu
/// detail's Dishes tabs) — matches the reference: photo/name/price, a
/// Category + Available toggle row, a per-variant price/discount table, and
/// a description box. All data is the live [Dish]/[CategoryProvider]/
/// [VariantProvider] — nothing here is static. The Available toggle and
/// "Tap Price to Edit" both go through the existing real update/edit paths
/// ([DishProvider.updateDish], [AddDishScreen]) rather than adding new ones.
class DishQuickViewSheet extends StatelessWidget {
  final String dishId;
  const DishQuickViewSheet({super.key, required this.dishId});

  static Future<void> show(BuildContext context, {required String dishId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DishQuickViewSheet(dishId: dishId),
    );
  }

  Future<void> _toggleAvailable(BuildContext context, Dish dish) async {
    final provider = context.read<DishProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await provider.updateDish(
      id: dish.id,
      dishName: dish.dishName,
      hsCode: dish.hsCode,
      dishPhoto: dish.dishPhoto,
      description: dish.description,
      price: dish.price,
      unitId: dish.unitId,
      cogs: dish.cogs,
      discountType: dish.discountType,
      discount: dish.discount,
      priceAfterDiscount: dish.priceAfterDiscount,
      variantIds: dish.variantIds,
      addonIds: dish.addonIds,
      dishTypeId: dish.dishTypeId,
      typeOfMenuId: dish.typeOfMenuId,
      menuCategoryId: dish.menuCategoryId,
      available: !dish.available,
      stockConsumptions: dish.stockConsumptions,
    );
    if (result == null && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(provider.updateErrorMessage ?? 'Failed to update dish')));
    }
  }

  Future<void> _editPrice(BuildContext context, Dish dish) async {
    Navigator.pop(context);
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddDishScreen(existingDish: dish)));
  }

  @override
  Widget build(BuildContext context) {
    final dishProvider = context.watch<DishProvider>();
    final matches = dishProvider.dishes.where((d) => d.id == dishId).toList();
    final dish = matches.isEmpty ? null : matches.first;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                if (dish == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('This dish is no longer available.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                    ),
                  )
                else
                  _DishQuickViewBody(
                    dish: dish,
                    scrollController: scrollController,
                    isUpdating: dishProvider.isUpdating,
                    onToggleAvailable: () => _toggleAvailable(context, dish),
                    onEditPrice: () => _editPrice(context, dish),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DishQuickViewBody extends StatelessWidget {
  final Dish dish;
  final ScrollController scrollController;
  final bool isUpdating;
  final VoidCallback onToggleAvailable;
  final VoidCallback onEditPrice;

  const _DishQuickViewBody({
    required this.dish,
    required this.scrollController,
    required this.isUpdating,
    required this.onToggleAvailable,
    required this.onEditPrice,
  });

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final variantProvider = context.watch<VariantProvider>();

    final categoryMatches = categoryProvider.categories.where((c) => c.id == dish.menuCategoryId).toList();
    final categoryName = categoryMatches.isEmpty ? '—' : categoryMatches.first.categoryName;
    final variants = dish.variantIds
        .map((id) {
          final match = variantProvider.variants.where((v) => v.id == id).toList();
          return match.isEmpty ? null : match.first;
        })
        .whereType<Variant>()
        .toList();

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        const Text('Dishes', style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MenuSetupDishAvatar(dish: dish, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dish.dishName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                        const SizedBox(height: 4),
                        Text(
                          dishPriceLabel(dish, variantProvider.variants),
                          style: const TextStyle(color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 13, decoration: TextDecoration.none),
                          children: [
                            const TextSpan(text: 'Category : ', style: TextStyle(color: AppTheme.textSecondary)),
                            TextSpan(text: categoryName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
                          Switch(
                            value: dish.available,
                            onChanged: isUpdating ? null : (_) => onToggleAvailable(),
                            activeThumbColor: AppTheme.completed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Menu Set's Price", style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
            GestureDetector(
              onTap: onEditPrice,
              child: const Text('Tap Price to Edit', style: TextStyle(color: AppTheme.accent, fontSize: 13.5, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (variants.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
            child: const Center(
              child: Text('No variants for this dish.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
            clipBehavior: Clip.antiAlias,
            child: Table(
              columnWidths: const {0: FlexColumnWidth(0.6), 1: FlexColumnWidth(1.6), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: AppTheme.card),
                  children: [
                    _TableCell('SN.', header: true),
                    _TableCell('Variant Name', header: true),
                    _TableCell('Price', header: true),
                    _TableCell('Discount', header: true),
                  ],
                ),
                for (var i = 0; i < variants.length; i++)
                  TableRow(
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: AppTheme.divider))),
                    children: [
                      _TableCell('${i + 1}.'),
                      _TableCell(variants[i].variantName),
                      _TableCell('Rs ${variants[i].actualPrice.toStringAsFixed(0)}'),
                      _TableCell('Rs ${variants[i].discount.toStringAsFixed(0)}'),
                    ],
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        const Text('Description', style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
          child: Text(
            (dish.description == null || dish.description!.trim().isEmpty) ? 'No description added.' : dish.description!,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
          ),
        ),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool header;
  const _TableCell(this.text, {this.header = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: header ? AppTheme.textSecondary : AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: header ? FontWeight.w600 : FontWeight.w500,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
