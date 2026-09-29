import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/category/category_model.dart';
import '../../data/models/dish/dish_model.dart' as catalog;
import '../../providers/category_provider.dart';
import '../../providers/dish_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/quick_billing_actions_sheet.dart';
import '../../widgets/common/menu_sets_sheet.dart';
import '../../widgets/common/customize_dish_sheet.dart';
import '../../widgets/common/filter_sort_sheet.dart';
import '../../widgets/common/add_custom_item_sheet.dart';
import 'order_cart_screen.dart';

class Dish {
  final String name;
  final String imageAsset;
  final IconData icon;
  final double minPrice;
  final double? maxPrice;
  final int optionsCount;
  final String category;
  final bool isRecommended;
  final List<DishVariant> variants;

  /// The real catalog id, set when this [Dish] was built from
  /// [DishProvider] rather than local dummy data — carried through to the
  /// cart so order placement can send a real `dishId`.
  final String? id;

  Dish({
    required this.name,
    required this.icon,
    required this.minPrice,
    this.maxPrice,
    required this.optionsCount,
    required this.category,
    this.isRecommended = false,
    this.imageAsset = '',
    this.variants = const [],
    this.id,
  });

  String get priceLabel {
    if (maxPrice != null) {
      return 'Rs ${minPrice.toStringAsFixed(1)} - Rs ${maxPrice!.toStringAsFixed(1)}';
    }
    return 'Rs ${minPrice.toStringAsFixed(1)}';
  }
}

class QuickBillingScreen extends StatefulWidget {
  final String title;
  final bool showBottomActionBar;

  /// When true, tapping a dish's Add button opens [CustomizeDishSheet] and
  /// collects picks into a cart; a bottom bar then lets the caller confirm
  /// the selection, returning it via [Navigator.pop]. Used by the Sales
  /// Return "Return Items" step so item picking can reuse this screen
  /// instead of duplicating the dish-grid UI.
  final bool isSelectionMode;

  /// The table this order is for, passed through to [OrderCartScreen] so
  /// "Confirm Order" can call `POST /api/order`. `null` for flows with no
  /// real table context yet (Take Away, the generic Quick Billing entry) —
  /// [OrderCartScreen] surfaces an error if the cart is confirmed without one.
  final String? tableId;

  const QuickBillingScreen({
    super.key,
    this.title = 'Quick Billing',
    this.showBottomActionBar = false,
    this.isSelectionMode = false,
    this.tableId,
  });

  @override
  State<QuickBillingScreen> createState() => _QuickBillingScreenState();
}

class _QuickBillingScreenState extends State<QuickBillingScreen> {
  String _selectedCategory = 'All Categories';
  bool _categoryPanelVisible = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _cart = [];

  @override
  void initState() {
    super.initState();
    final dishProvider = context.read<DishProvider>();
    if (dishProvider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => dishProvider.fetchDishes());
    }
    final categoryProvider = context.read<CategoryProvider>();
    if (categoryProvider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => categoryProvider.fetchCategories());
    }
  }

  /// Maps the real [DishProvider] catalog into this screen's display [Dish]
  /// shape — no icon or variant/add-on details come from the backend yet,
  /// so those stay generic (see [_DishCard] and [_addDish]).
  List<Dish> _adaptDishes(List<catalog.Dish> dishes, List<MenuCategory> categories) {
    final categoryNames = {for (final c in categories) c.id: c.categoryName};
    return dishes.map((d) {
      return Dish(
        id: d.id,
        name: d.dishName,
        icon: Icons.restaurant_menu,
        minPrice: d.priceAfterDiscount ?? d.price ?? 0,
        optionsCount: d.addonIds.length + d.variantIds.length,
        category: categoryNames[d.menuCategoryId] ?? 'Uncategorized',
      );
    }).toList();
  }

  List<Dish> _filterDishes(List<Dish> dishes) {
    var list = dishes;

    if (_selectedCategory != 'All Categories') {
      list = list.where((d) => d.category == _selectedCategory).toList();
    }

    if (_searchController.text.isNotEmpty) {
      list = list
          .where((d) => d.name.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addDish(Dish dish) {
    CustomizeDishSheet.show(
      context,
      dishName: dish.name,
      dishIcon: dish.icon,
      basePrice: dish.minPrice,
      variants: dish.variants,
      dishId: dish.id,
      onAddToCart: (data) => setState(() => _cart.add(data)),
    );
  }

  Future<void> _openFilterSort(List<String> categories) async {
    final result = await FilterSortSheet.show(context, categories: categories, selectedCategory: _selectedCategory);
    if (result?.category != null) {
      setState(() => _selectedCategory = result!.category!);
    }
  }

  Future<void> _openAddCustomItem() async {
    final item = await AddCustomItemSheet.show(context);
    if (item != null) setState(() => _cart.add(item));
  }

  Future<void> _openCart() async {
    final updatedCart = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(builder: (context) => OrderCartScreen(title: widget.title, cart: _cart, tableId: widget.tableId)),
    );
    if (updatedCart != null) setState(() => _cart = updatedCart);
  }

  @override
  Widget build(BuildContext context) {
    final dishProvider = context.watch<DishProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final categoryNames = ['All Categories', ...categoryProvider.categories.map((c) => c.categoryName)];
    final catalogDishes = _adaptDishes(dishProvider.dishes, categoryProvider.categories);
    final filteredDishes = _filterDishes(catalogDishes);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (_isSearching) {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: _isSearching
            ? Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
            decoration: const InputDecoration(
              hintText: 'Search here',
              hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: (value) => setState(() {}),
          ),
        )
            : Text(
          widget.title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
        actions: _isSearching
            ? [
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.accent),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            },
          ),
          const SizedBox(width: 8),
        ]
            : [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.divider),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: AppTheme.textPrimary),
              onPressed: () => setState(() => _isSearching = true),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.divider),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textPrimary),
                  onPressed: _openCart,
                ),
                if (_cart.isNotEmpty)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppTheme.cancelled, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_cart.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton.icon(
              onPressed: () {
                QuickBillingActionsSheet.show(
                  context,
                  categoryPanelVisible: _categoryPanelVisible,
                  onCategoryPanelToggle: (value) {
                    setState(() => _categoryPanelVisible = value);
                  },
                  onAddCustomItem: _openAddCustomItem,
                  onCartTap: _openCart,
                );
              },
              icon: const Icon(Icons.more_horiz, color: Colors.white, size: 18),
              label: const Text(
                'More',
                style: TextStyle(color: Colors.white, decoration: TextDecoration.none),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _FilterChip(
                    icon: Icons.tune,
                    label: 'Filters',
                    isSelected: _selectedCategory != 'All Categories',
                    onTap: () => _openFilterSort(categoryNames),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    icon: Icons.star,
                    iconColor: Colors.amber,
                    label: 'Recommended',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recommended dishes coming soon')));
                    },
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Default Menuset',
                    trailingIcon: Icons.keyboard_arrow_down,
                    onTap: () {
                      MenuSetsSheet.show(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.divider),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_categoryPanelVisible) ...[
                    SizedBox(
                      width: 100,
                      child: ListView.builder(
                        itemCount: categoryNames.length,
                        itemBuilder: (context, index) {
                          final category = categoryNames[index];
                          final isSelected = category == _selectedCategory;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = category),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                              color: isSelected ? AppTheme.primary : AppTheme.background,
                              child: Text(
                                category == 'All Categories' ? 'All Catego...' : category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  fontSize: 13,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1, color: AppTheme.divider),
                  ],
                  Expanded(
                    child: dishProvider.status == LoadStatus.error && dishProvider.dishes.isEmpty
                        ? _DishLoadErrorState(
                            message: dishProvider.errorMessage ?? 'Something went wrong.',
                            onRetry: () => dishProvider.fetchDishes(),
                          )
                        : (dishProvider.status == LoadStatus.idle || dishProvider.status == LoadStatus.loading) && dishProvider.dishes.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                        : filteredDishes.isEmpty
                        ? const _NoDishEmptyState()
                        : Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              mainAxisExtent: 230,
                            ),
                            itemCount: filteredDishes.length,
                            itemBuilder: (context, index) {
                              final dish = filteredDishes[index];
                              return _DishCard(dish: dish, onAdd: () => _addDish(dish));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Total Dish : ${filteredDishes.length}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        if (widget.isSelectionMode)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                            decoration: const BoxDecoration(
                              color: AppTheme.surface,
                              border: Border(top: BorderSide(color: AppTheme.divider)),
                            ),
                            child: ElevatedButton(
                              onPressed: _cart.isEmpty ? null : () => Navigator.pop(context, _cart),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                _cart.isEmpty ? 'Add Item Details' : 'Add ${_cart.length} Item${_cart.length > 1 ? 's' : ''}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
                              ),
                            ),
                          )
                        else if (widget.showBottomActionBar)
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              12,
                              16,
                              12 + MediaQuery.of(context).padding.bottom,
                            ),
                            decoration: const BoxDecoration(
                              color: AppTheme.surface,
                              border: Border(top: BorderSide(color: AppTheme.divider)),
                            ),
                            child: Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    // TODO: Assign staff/customer
                                  },
                                  icon: const Icon(Icons.person_add_alt, color: AppTheme.accent, size: 18),
                                  label: const Text(
                                    'Assign',
                                    style: TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _cart.isEmpty ? null : _openCart,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.completed,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text(
                                      'Continue Order',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DishLoadErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DishLoadErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
              child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDishEmptyState extends StatelessWidget {
  const _NoDishEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 110,
            color: AppTheme.accent.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                decoration: TextDecoration.none,
              ),
              children: [
                TextSpan(text: 'No '),
                TextSpan(text: 'Dish', style: TextStyle(color: AppTheme.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final IconData? trailingIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    this.icon,
    this.iconColor,
    this.trailingIcon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor ?? (isSelected ? Colors.white : AppTheme.textPrimary)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontSize: 13,
                decoration: TextDecoration.none,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              Icon(trailingIcon, size: 18, color: isSelected ? Colors.white : AppTheme.textPrimary),
            ],
          ],
        ),
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback onAdd;

  const _DishCard({required this.dish, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 75,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Icon(dish.icon, size: 34, color: AppTheme.accent),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dish.priceLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onAdd,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 14, color: AppTheme.textPrimary),
                        SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          if (dish.optionsCount > 0)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  '${dish.optionsCount} Options',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.divider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}