import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/addon/addon_model.dart';
import '../../data/models/category/category_model.dart';
import '../../data/models/dish/dish_model.dart';
import '../../data/models/dish_type/dish_type_model.dart';
import '../../data/models/media/media_model.dart';
import '../../data/models/type_of_menu/type_of_menu_model.dart';
import '../../data/models/unit/unit_model.dart';
import '../../data/models/variant/variant_model.dart';
import '../../providers/addon_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/dish_provider.dart';
import '../../providers/dish_type_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/type_of_menu_provider.dart';
import '../../providers/unit_provider.dart';
import '../../providers/variant_provider.dart';
import '../../widgets/common/edit_delete_actions_sheet.dart';
import '../../widgets/common/media_upload_helper.dart';
import 'add_addon_screen.dart' show AddAddOnScreen;
import 'add_dish_type_screen.dart' show AddDishTypeScreen;

// ---------------- from select_sub_menu_sheet.dart ----------------

/// Picker for a [TypeOfMenu] ("Sub-Menu" in this app's UI language),
/// sourced live from [TypeOfMenuProvider] (backend: `/api/type-of-menu`).
class SelectSubMenuSheet extends StatefulWidget {
  const SelectSubMenuSheet({super.key});

  static Future<TypeOfMenu?> show(BuildContext context) {
    return showModalBottomSheet<TypeOfMenu>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectSubMenuSheet(),
    );
  }

  @override
  State<SelectSubMenuSheet> createState() => _SelectSubMenuSheetState();
}

class _SelectSubMenuSheetState extends State<SelectSubMenuSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<TypeOfMenuProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchTypeOfMenus());
    }
  }

  List<TypeOfMenu> _filtered(List<TypeOfMenu> items) {
    if (_searchController.text.isEmpty) return items;
    return items.where((i) => i.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TypeOfMenuProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Sub-Menu',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _buildBody(provider, scrollController)),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Total Sub Menu : ${provider.types.length}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push<TypeOfMenu>(
                            MaterialPageRoute(builder: (context) => const AddSubMenuScreen()),
                          );
                          if (result != null && context.mounted) {
                            Navigator.pop(context, result);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Add New Sub-Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildBody(TypeOfMenuProvider provider, ScrollController scrollController) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.read<TypeOfMenuProvider>().fetchTypeOfMenus(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.types.isEmpty) {
          return const Center(child: Text('No Sub-Menus created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)));
        }
        final filtered = _filtered(provider.types);
        return ListView.separated(
          controller: scrollController,
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = filtered[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_outlined, color: AppTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
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
}

// ---------------- from select_category_sheet.dart ----------------

class SelectCategorySheet extends StatefulWidget {
  const SelectCategorySheet({super.key});

  static Future<MenuCategory?> show(BuildContext context) {
    return showModalBottomSheet<MenuCategory>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectCategorySheet(),
    );
  }

  @override
  State<SelectCategorySheet> createState() => _SelectCategorySheetState();
}

class _SelectCategorySheetState extends State<SelectCategorySheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<CategoryProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchCategories());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final created = await Navigator.push<MenuCategory>(context, MaterialPageRoute(builder: (context) => const AddCategoryScreen()));
    if (created == null || !mounted) return;
    Navigator.pop(context, created);
  }

  List<MenuCategory> _filter(List<MenuCategory> categories) {
    if (_searchController.text.isEmpty) return categories;
    return categories.where((c) => c.categoryName.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Category',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _buildBody(categoryProvider, scrollController)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _addCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Add New Category',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildBody(CategoryProvider provider, ScrollController scrollController) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(
                  provider.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.read<CategoryProvider>().fetchCategories(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final filtered = _filter(provider.categories);
        if (provider.categories.isEmpty) {
          return Center(
            child: Text(
              'No Categories created yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context, item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.dashboard_outlined, color: AppTheme.accent, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item.categoryName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total Category : ${provider.categories.length}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        );
    }
  }
}

// ---------------- Select Measuring Unit sheet (Add Dish) ----------------
//
// GET /api/unit currently 404s on the backend, so this shows the fetched
// list when it succeeds and falls back to [kFallbackUnits] otherwise —
// selecting a fallback unit leaves `unitId` as null (see [Unit.id]).
// Distinct from `SelectUnitSheet` below, which is a purely-local stock
// consumption unit picker unrelated to this backend-backed one.

class SelectMeasuringUnitSheet extends StatefulWidget {
  const SelectMeasuringUnitSheet({super.key});

  static Future<Unit?> show(BuildContext context) {
    return showModalBottomSheet<Unit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectMeasuringUnitSheet(),
    );
  }

  @override
  State<SelectMeasuringUnitSheet> createState() => _SelectMeasuringUnitSheetState();
}

class _SelectMeasuringUnitSheetState extends State<SelectMeasuringUnitSheet> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<UnitProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchUnits());
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitProvider = context.watch<UnitProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Unit',
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildBody(unitProvider, scrollController)),
                    ],
                  ),
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

  Widget _buildBody(UnitProvider provider, ScrollController scrollController) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    final showingFallback = provider.useFallback || (provider.status == LoadStatus.loaded && provider.units.isEmpty);
    final items = showingFallback ? kFallbackUnits : provider.units;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showingFallback)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              provider.useFallback
                  ? 'Unit list isn\'t available from the server yet — showing common units. Selecting one won\'t be linked to a backend id until the endpoint is ready.'
                  : 'No units created yet — showing common units as a starting point.',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
            ),
          ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(context, item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Text(
                    item.name,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------- from select_dish_type_sheet.dart ----------------

/// Icons/colors for well-known dish type names — purely decorative, since
/// the backend only returns a name. Falls back to a generic icon for any
/// other name (e.g. custom types the restaurant adds).
const Map<String, ({IconData icon, Color color})> _kDishTypeStyles = {
  'veg': (icon: Icons.circle, color: Color(0xFF4CAF50)),
  'non-veg': (icon: Icons.circle, color: Color(0xFFDC3939)),
  'vegan': (icon: Icons.eco_outlined, color: Color(0xFF4CAF50)),
  'spicy': (icon: Icons.local_fire_department_outlined, color: Colors.deepOrange),
  'gluten free': (icon: Icons.grain_outlined, color: Colors.blueAccent),
  'sugar free': (icon: Icons.icecream_outlined, color: Colors.tealAccent),
};

class SelectDishTypeSheet extends StatefulWidget {
  const SelectDishTypeSheet({super.key});

  static Future<DishType?> show(BuildContext context) {
    return showModalBottomSheet<DishType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectDishTypeSheet(),
    );
  }

  @override
  State<SelectDishTypeSheet> createState() => _SelectDishTypeSheetState();
}

class _SelectDishTypeSheetState extends State<SelectDishTypeSheet> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<DishTypeProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchDishTypes());
    }
    if (provider.dishTypeCountsStatus == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchDishTypeCounts());
    }
  }

  Future<void> _addDishType() async {
    final created = await Navigator.push<DishType>(context, MaterialPageRoute(builder: (context) => const AddDishTypeScreen()));
    if (created == null || !mounted) return;
    Navigator.pop(context, created);
  }

  Future<void> _openActions(DishType dishType) async {
    final action = await EditDeleteActionsSheet.show(context, title: dishType.dishTypeName);
    if (!context.mounted) return;
    if (action == 'edit') {
      await Navigator.push<DishType>(context, MaterialPageRoute(builder: (context) => AddDishTypeScreen(existingDishType: dishType)));
    } else if (action == 'delete') {
      await _confirmDeleteDishType(dishType);
    }
  }

  Future<void> _confirmDeleteDishType(DishType dishType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Dish Type', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          'Remove "${dishType.dishTypeName}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<DishTypeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteDishType(dishType.id);
    if (!success && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to delete dish type')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dishTypeProvider = context.watch<DishTypeProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Select Dish Type',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addDishType,
                          icon: const Icon(Icons.add, color: AppTheme.accent, size: 18),
                          label: const Text('Add New', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                        ),
                      ],
                    ),
                    if (dishTypeProvider.dishTypeCountsStatus == LoadStatus.loaded && dishTypeProvider.dishTypeCounts != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${dishTypeProvider.dishTypeCounts!.total} total · ${dishTypeProvider.dishTypeCounts!.active} active',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Expanded(child: _buildBody(dishTypeProvider, scrollController)),
                  ],
                ),
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

  Widget _buildBody(DishTypeProvider provider, ScrollController scrollController) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(
                  provider.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.read<DishTypeProvider>().fetchDishTypes(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.dishTypes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No Dish Types created yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addDishType,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Create New Dish Type',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: provider.dishTypes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = provider.dishTypes[index];
            final style = _kDishTypeStyles[item.dishTypeName.toLowerCase()];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Icon(style?.icon ?? Icons.local_dining_outlined, color: style?.color ?? AppTheme.accent, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.dishTypeName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _openActions(item),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 18),
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
}

// ---------------- from select_kitchen_type_sheet.dart ----------------

class KitchenTypeItem {
  final String code;
  final String name;
  final String description;
  KitchenTypeItem({required this.code, required this.name, required this.description});
}

class SelectKitchenTypeSheet extends StatefulWidget {
  const SelectKitchenTypeSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectKitchenTypeSheet(),
    );
  }

  @override
  State<SelectKitchenTypeSheet> createState() => _SelectKitchenTypeSheetState();
}

class _SelectKitchenTypeSheetState extends State<SelectKitchenTypeSheet> {
  final TextEditingController _searchController = TextEditingController();

  final List<KitchenTypeItem> _items = [
    KitchenTypeItem(code: 'KO', name: 'KOT', description: 'Kitchen Order Ticket'),
    KitchenTypeItem(code: 'BO', name: 'BOT', description: 'Bar Order Ticket'),
  ];

  List<KitchenTypeItem> get _filtered {
    if (_searchController.text.isEmpty) return _items;
    return _items
        .where((i) => i.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Kitchen Type',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, item.name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.divider),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.surface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.code,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      Text(
                                        item.description,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Total KOT Type : ${_items.length}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to Add New KOT Type flow
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Add New KOT Type',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

// ---------------- from select_addons_sheet.dart ----------------

class SelectAddOnsSheet extends StatefulWidget {
  final List<String> initiallySelected;

  const SelectAddOnsSheet({super.key, this.initiallySelected = const []});

  static Future<List<String>?> show(BuildContext context, {List<String> initiallySelected = const []}) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectAddOnsSheet(initiallySelected: initiallySelected),
    );
  }

  @override
  State<SelectAddOnsSheet> createState() => _SelectAddOnsSheetState();
}

class _SelectAddOnsSheetState extends State<SelectAddOnsSheet> {
  final TextEditingController _searchController = TextEditingController();
  late Set<String> _selectedNames;

  @override
  void initState() {
    super.initState();
    _selectedNames = Set.of(widget.initiallySelected);
    final provider = context.read<AddOnProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchAddOns());
    }
    if (provider.addOnStatsStatus == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchAddOnStats());
    }
  }

  List<AddOn> _filtered(List<AddOn> addons) {
    if (_searchController.text.isEmpty) return addons;
    final q = _searchController.text.toLowerCase();
    return addons.where((a) => a.addonName.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addAddOn() async {
    final created = await Navigator.push<AddOn>(context, MaterialPageRoute(builder: (context) => const AddAddOnScreen()));
    if (created == null || !mounted) return;
    setState(() => _selectedNames.add(created.addonName));
  }

  Future<void> _openActions(AddOn addon) async {
    final action = await EditDeleteActionsSheet.show(context, title: addon.addonName);
    if (!context.mounted) return;
    if (action == 'edit') {
      final oldName = addon.addonName;
      final updated = await Navigator.push<AddOn>(context, MaterialPageRoute(builder: (context) => AddAddOnScreen(existingAddOn: addon)));
      if (updated != null && mounted && _selectedNames.remove(oldName)) {
        setState(() => _selectedNames.add(updated.addonName));
      }
    } else if (action == 'delete') {
      await _confirmDeleteAddOn(addon);
    }
  }

  Future<void> _confirmDeleteAddOn(AddOn addon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Add-On', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          'Remove "${addon.addonName}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<AddOnProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteAddOn(addon.id);
    if (success) {
      setState(() => _selectedNames.remove(addon.addonName));
    } else if (context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to delete add-on')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final addOnProvider = context.watch<AddOnProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Select Add-Ons',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addAddOn,
                          icon: const Icon(Icons.add, color: AppTheme.accent, size: 18),
                          label: const Text('Add New', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add-Ons / Extras',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (addOnProvider.addOnStatsStatus == LoadStatus.loaded && addOnProvider.addOnStats?.mostUsedName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Most used: ${addOnProvider.addOnStats!.mostUsedName}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Expanded(child: _buildBody(addOnProvider, scrollController)),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Total Add-Ons / Extras : ${addOnProvider.addons.length}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, _selectedNames.toList()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildBody(AddOnProvider provider, ScrollController scrollController) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(
                  provider.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.read<AddOnProvider>().fetchAddOns(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.addons.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No Add-Ons / Extras created yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addAddOn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Create New Add-On',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final filtered = _filtered(provider.addons);
        return ListView.separated(
          controller: scrollController,
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = filtered[index];
            final selected = _selectedNames.contains(item.addonName);
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                if (selected) {
                  _selectedNames.remove(item.addonName);
                } else {
                  _selectedNames.add(item.addonName);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.accent : AppTheme.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: selected,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setState(() {
                        if (v ?? false) {
                          _selectedNames.add(item.addonName);
                        } else {
                          _selectedNames.remove(item.addonName);
                        }
                      }),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_offer_outlined, color: AppTheme.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.addonName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            'Used In: ${item.dishCount} Dishes',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs ${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    InkWell(
                      onTap: () => _openActions(item),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 18),
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
}

// ---------------- from image_source_sheet.dart ----------------

class ImageSourceOption {
  final IconData icon;
  final String label;
  final String value;
  ImageSourceOption({required this.icon, required this.label, required this.value});
}

class ImageSourceSheet extends StatelessWidget {
  final bool includeLibrary;

  const ImageSourceSheet({super.key, this.includeLibrary = true});

  static Future<String?> show(BuildContext context, {bool includeLibrary = true}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceSheet(includeLibrary: includeLibrary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      if (includeLibrary)
        ImageSourceOption(icon: Icons.photo_library_outlined, label: "Open Hamro Restro's Library", value: 'library'),
      ImageSourceOption(icon: Icons.camera_alt_outlined, label: 'Take a Photo', value: 'camera'),
      ImageSourceOption(icon: Icons.upload_outlined, label: 'Upload from Gallery', value: 'gallery'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, option.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                child: Row(
                  children: [
                    Icon(option.icon, color: AppTheme.textPrimary, size: 22),
                    const SizedBox(width: 16),
                    Text(
                      option.label,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------- from select_stock_consumption_sheet.dart ----------------

class StockItem {
  final String name;
  final String unit;
  final double availableQty;
  final IconData icon;

  StockItem({
    required this.name,
    required this.unit,
    this.availableQty = 0,
    this.icon = Icons.inventory_2_outlined,
  });
}

class StockConsumptionEntry {
  final String stockItemName;
  final String unit;
  double quantity;

  StockConsumptionEntry({
    required this.stockItemName,
    required this.unit,
    this.quantity = 0,
  });
}

class _ConsumptionRow {
  StockItem? stock;
  String? unit;
  _ConsumptionRow({this.stock, this.unit});
}

class _EmptyStateIllustration extends StatelessWidget {
  const _EmptyStateIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
      child: const Icon(Icons.inventory_2_outlined, color: AppTheme.accent, size: 42),
    );
  }
}

class SelectStockConsumptionSheet extends StatefulWidget {
  final List<StockConsumptionEntry> initiallySelected;

  const SelectStockConsumptionSheet({super.key, this.initiallySelected = const []});

  static Future<List<StockConsumptionEntry>?> show(
    BuildContext context, {
    List<StockConsumptionEntry> initiallySelected = const [],
  }) {
    return Navigator.of(context).push<List<StockConsumptionEntry>>(
      MaterialPageRoute(
        builder: (context) => SelectStockConsumptionSheet(initiallySelected: initiallySelected),
      ),
    );
  }

  @override
  State<SelectStockConsumptionSheet> createState() => _SelectStockConsumptionSheetState();
}

class _SelectStockConsumptionSheetState extends State<SelectStockConsumptionSheet> {
  final List<StockItem> _availableStock = [];
  late List<_ConsumptionRow> _rows;

  @override
  void initState() {
    super.initState();
    if (widget.initiallySelected.isEmpty) {
      _rows = [_ConsumptionRow()];
    } else {
      _rows = widget.initiallySelected.map((entry) {
        final stock = StockItem(name: entry.stockItemName, unit: entry.unit);
        _availableStock.add(stock);
        return _ConsumptionRow(stock: stock, unit: entry.unit);
      }).toList();
    }
  }

  void _addRow() {
    setState(() => _rows.add(_ConsumptionRow()));
  }

  void _removeRow(int index) {
    setState(() => _rows.removeAt(index));
  }

  Future<void> _pickStock(int index) async {
    final result = await SelectStockSheet.show(context, availableStock: _availableStock);
    if (result != null) {
      setState(() {
        _rows[index].stock = result;
        _rows[index].unit = null;
      });
    }
  }

  Future<void> _pickUnit(int index) async {
    final hasStock = _rows[index].stock != null;
    final result = await SelectUnitSheet.show(context, hasStockSelected: hasStock);
    if (result != null) {
      setState(() => _rows[index].unit = result);
    }
  }

  void _save() {
    final result = _rows
        .where((r) => r.stock != null && r.unit != null)
        .map((r) => StockConsumptionEntry(stockItemName: r.stock!.name, unit: r.unit!, quantity: 1))
        .toList();
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Stock Used or Reduced after Sales',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          for (int i = 0; i < _rows.length; i++) ...[
            _StockConsumptionRowCard(
              row: _rows[i],
              onPickStock: () => _pickStock(i),
              onPickUnit: () => _pickUnit(i),
              onRemove: () => _removeRow(i),
            ),
            const SizedBox(height: 14),
          ],
          OutlinedButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, color: AppTheme.primary),
            label: const Text(
              'Add Another Stock',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockConsumptionRowCard extends StatelessWidget {
  final _ConsumptionRow row;
  final VoidCallback onPickStock;
  final VoidCallback onPickUnit;
  final VoidCallback onRemove;

  const _StockConsumptionRowCard({
    required this.row,
    required this.onPickStock,
    required this.onPickUnit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(Icons.delete_outline, color: AppTheme.cancelled, size: 20),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Stocks', required: true),
                    const SizedBox(height: 8),
                    _SelectField(hint: 'Select Stock', value: row.stock?.name, onTap: onPickStock),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Unit', required: true),
                    const SizedBox(height: 8),
                    _SelectField(hint: 'Select Unit', value: row.unit, onTap: onPickUnit),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- Select Stock sheet ----------------

class SelectStockSheet extends StatefulWidget {
  final List<StockItem> availableStock;

  const SelectStockSheet({super.key, required this.availableStock});

  static Future<StockItem?> show(BuildContext context, {required List<StockItem> availableStock}) {
    return showModalBottomSheet<StockItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectStockSheet(availableStock: availableStock),
    );
  }

  @override
  State<SelectStockSheet> createState() => _SelectStockSheetState();
}

class _SelectStockSheetState extends State<SelectStockSheet> {
  final TextEditingController _searchController = TextEditingController();

  List<StockItem> get _filtered {
    if (_searchController.text.isEmpty) return widget.availableStock;
    return widget.availableStock
        .where((i) => i.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createNewStock() async {
    final result = await Navigator.of(context).push<StockItem>(
      MaterialPageRoute(builder: (context) => const AddStockItemScreen()),
    );
    if (result != null && mounted) {
      setState(() => widget.availableStock.add(result));
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasStock = widget.availableStock.isNotEmpty;
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Stock',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                    ),
                    if (hasStock) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Search here',
                            hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                            prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Expanded(
                      child: !hasStock
                          ? _buildEmptyState('No Stock found. Needs to create the Stock!')
                          : (_filtered.isEmpty
                              ? _buildEmptyState('No matching stock found.')
                              : ListView.separated(
                                  controller: scrollController,
                                  itemCount: _filtered.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = _filtered[index];
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => Navigator.pop(context, item),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.card,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppTheme.divider),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                                              child: Icon(item.icon, color: AppTheme.accent, size: 22),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                                  Text('Available: ${item.availableQty.toStringAsFixed(0)} ${item.unit}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )),
                    ),
                    if (hasStock) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Total Stock : ${widget.availableStock.length}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _createNewStock,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Create New Stock', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                    ),
                    if (!hasStock) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigate to help / learn more content
                          },
                          child: const Text('Learn More', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                        ),
                      ),
                    ],
                  ],
                ),
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _EmptyStateIllustration(),
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              children: [
                TextSpan(text: 'No '),
                TextSpan(text: 'Stock', style: TextStyle(color: AppTheme.cancelled)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}

// ---------------- Select Unit sheet ----------------

class _UnitOption {
  final String code;
  final String name;
  _UnitOption(this.code, this.name);
}

class SelectUnitSheet extends StatefulWidget {
  final bool hasStockSelected;

  const SelectUnitSheet({super.key, this.hasStockSelected = true});

  static Future<String?> show(BuildContext context, {bool hasStockSelected = true}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectUnitSheet(hasStockSelected: hasStockSelected),
    );
  }

  @override
  State<SelectUnitSheet> createState() => _SelectUnitSheetState();
}

class _SelectUnitSheetState extends State<SelectUnitSheet> {
  final TextEditingController _searchController = TextEditingController();

  final List<_UnitOption> _items = [
    _UnitOption('g', 'Gram'),
    _UnitOption('kg', 'Kilogram'),
    _UnitOption('lb', 'Pound'),
    _UnitOption('ltr', 'Litre'),
    _UnitOption('ml', 'Mililitre'),
    _UnitOption('oz', 'Ounce'),
  ];

  List<_UnitOption> get _filtered {
    if (_searchController.text.isEmpty) return _items;
    final q = _searchController.text.toLowerCase();
    return _items.where((i) => i.name.toLowerCase().contains(q) || i.code.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Unit',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: !widget.hasStockSelected
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  _EmptyStateIllustration(),
                                  SizedBox(height: 20),
                                  Text('No Stock selected', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: _filtered.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _filtered[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.pop(context, item.code),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.code, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                        Text(item.name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (widget.hasStockSelected) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to Create Measuring Unit flow
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Create Measuring Unit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        ),
                      ),
                    ],
                  ],
                ),
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

// ---------------- Select Stock Group sheet ----------------

class SelectStockGroupSheet extends StatefulWidget {
  const SelectStockGroupSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectStockGroupSheet(),
    );
  }

  @override
  State<SelectStockGroupSheet> createState() => _SelectStockGroupSheetState();
}

class _SelectStockGroupSheetState extends State<SelectStockGroupSheet> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _items = ['Drinks', 'Groceries', 'Meat', 'Others', 'Vegetable'];

  List<String> get _filtered {
    if (_searchController.text.isEmpty) return _items;
    return _items.where((i) => i.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Stock Group',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                              child: Text(item, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Total Stock Group : ${_items.length}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to Create Group flow
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Create Group', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                    ),
                  ],
                ),
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

// ---------------- Add Stock Item screen ----------------

class AddStockItemScreen extends StatefulWidget {
  const AddStockItemScreen({super.key});

  @override
  State<AddStockItemScreen> createState() => _AddStockItemScreenState();
}

class _AddStockItemScreenState extends State<AddStockItemScreen> {
  final _itemNameController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _openingQtyController = TextEditingController();
  final _openingRateController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _reorderQtyController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _multipleUnit = false;
  bool _showAdditionalDetails = false;
  String? _selectedUnit;
  String? _selectedGroup;

  double get _openingValue {
    final qty = double.tryParse(_openingQtyController.text) ?? 0;
    final rate = double.tryParse(_openingRateController.text) ?? 0;
    return qty * rate;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _purchasePriceController.dispose();
    _openingQtyController.dispose();
    _openingRateController.dispose();
    _reorderLevelController.dispose();
    _reorderQtyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickUnit() async {
    final result = await SelectUnitSheet.show(context, hasStockSelected: true);
    if (result != null) setState(() => _selectedUnit = result);
  }

  Future<void> _pickGroup() async {
    final result = await SelectStockGroupSheet.show(context);
    if (result != null) setState(() => _selectedGroup = result);
  }

  void _save() {
    final result = StockItem(
      name: _itemNameController.text,
      unit: _selectedUnit ?? '',
      availableQty: double.tryParse(_openingQtyController.text) ?? 0,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Add Stock Item',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _FieldLabel(label: 'Item Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(controller: _itemNameController, hint: 'Enter Item Name'),
          const SizedBox(height: 20),

          Row(
            children: [
              _FieldLabel(label: 'Measuring Unit', required: true),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _multipleUnit = !_multipleUnit),
                child: Row(
                  children: [
                    Checkbox(
                      value: _multipleUnit,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setState(() => _multipleUnit = v ?? false),
                    ),
                    const Text('Multiple Unit', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SelectField(hint: 'Select Measuring Unit of the Item', value: _selectedUnit, onTap: _pickUnit),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Purchase Price', required: false),
          const SizedBox(height: 8),
          _AppTextField(controller: _purchasePriceController, hint: '00.00', prefix: 'Rs', keyboardType: TextInputType.number),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Group', required: false),
          const SizedBox(height: 8),
          _SelectField(hint: 'Select Group for Item', value: _selectedGroup, onTap: _pickGroup),
          const SizedBox(height: 20),

          const Text('Opening Stock', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quantity', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                      const SizedBox(height: 8),
                      _AppTextField(controller: _openingQtyController, hint: '0.00', keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rate', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                      const SizedBox(height: 8),
                      _AppTextField(controller: _openingRateController, hint: '0.00', prefix: 'Rs', keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Value', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                        child: Text('Rs ${_openingValue.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: () => setState(() => _showAdditionalDetails = !_showAdditionalDetails),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _showAdditionalDetails ? 'Hide Additional Details' : 'Additional Details',
                  style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
                Icon(_showAdditionalDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.accent),
              ],
            ),
          ),
          if (_showAdditionalDetails) ...[
            const SizedBox(height: 16),
            const _FieldLabel(label: 'Reorder Level', required: false),
            const SizedBox(height: 8),
            _AppTextField(controller: _reorderLevelController, hint: 'Enter Reorder Level', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            const _FieldLabel(label: 'Reorder QTY', required: false),
            const SizedBox(height: 8),
            _AppTextField(controller: _reorderQtyController, hint: 'Enter Reorder QTY', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            const _FieldLabel(label: 'Description', required: false),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
              decoration: InputDecoration(
                hintText: 'Enter Description',
                hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                filled: true,
                fillColor: AppTheme.card,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _showAdditionalDetails = false),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Hide Additional Details', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  Icon(Icons.keyboard_arrow_up, color: AppTheme.accent),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Save Stock Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- from edit_variant_screen.dart ----------------

/// Local view of a [Variant] within the Edit Variant form. [id] is null
/// until the variant has actually been created against `POST /api/variant`
/// (see [EditVariantScreen._save]) — [AddDishScreen] only sends variants
/// with a real [id] as `variantIds`.
class DishVariant {
  String? id;
  String name;
  double actualPrice;
  double discount;
  double cogs;
  String? unitId;
  String? unitLabel;

  DishVariant({
    this.id,
    this.name = '',
    this.actualPrice = 0,
    this.discount = 0,
    this.cogs = 0,
    this.unitId,
    this.unitLabel,
  });

  double get listedPrice {
    final result = actualPrice - discount;
    return result < 0 ? 0 : result;
  }
}

class EditVariantScreen extends StatefulWidget {
  final List<DishVariant>? initialVariants;

  const EditVariantScreen({super.key, this.initialVariants});

  @override
  State<EditVariantScreen> createState() => _EditVariantScreenState();
}

class _EditVariantScreenState extends State<EditVariantScreen> {
  late List<_VariantFormData> _variants;

  @override
  void initState() {
    super.initState();
    if (widget.initialVariants != null && widget.initialVariants!.isNotEmpty) {
      _variants = widget.initialVariants!.map((v) => _VariantFormData.fromVariant(v)).toList();
    } else {
      _variants = [_VariantFormData()];
    }
  }

  @override
  void dispose() {
    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  void _addVariant() {
    setState(() => _variants.add(_VariantFormData()));
  }

  void _removeVariant(int index) {
    if (_variants.length <= 1) return;
    setState(() {
      _variants[index].dispose();
      _variants.removeAt(index);
    });
  }

  /// Permanently deletes an already-saved variant from the backend
  /// (`DELETE /api/variant/{id}`) — distinct from [_removeVariant], which
  /// only detaches a variant from *this* dish. Variants are a standalone,
  /// reusable resource that other dishes may also reference, so this warns
  /// explicitly before calling [VariantProvider.deleteVariant].
  Future<void> _deleteVariant(int index) async {
    final id = _variants[index].id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Variant', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: const Text(
          'This permanently deletes the variant, not just from this dish. If any other dish also uses it, it will disappear there too. This cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<VariantProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteVariant(id);
    if (!mounted) return;

    if (success) {
      setState(() {
        _variants[index].dispose();
        _variants.removeAt(index);
        if (_variants.isEmpty) _variants.add(_VariantFormData());
      });
    } else {
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to delete variant')));
    }
  }

  void _reset() {
    setState(() {
      for (final v in _variants) {
        v.dispose();
      }
      _variants = [_VariantFormData()];
    });
  }

  bool _isSaving = false;
  String? _saveError;

  Future<void> _save() async {
    final hasEmptyName = _variants.any((v) => v.nameController.text.trim().isEmpty);
    final hasEmptyPrice = _variants.any((v) => double.tryParse(v.priceController.text.trim()) == null);
    final hasEmptyCogs = _variants.any((v) => double.tryParse(v.cogsController.text.trim()) == null);
    if (hasEmptyName || hasEmptyPrice || hasEmptyCogs) {
      setState(() => _saveError = 'Fill in Name, Actual Price and COGS for every variant.');
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final provider = context.read<VariantProvider>();
    final result = <DishVariant>[];
    for (final v in _variants) {
      final name = v.nameController.text.trim();
      final actualPrice = double.parse(v.priceController.text.trim());
      final discount = double.tryParse(v.discountController.text.trim()) ?? 0;
      final cogs = double.parse(v.cogsController.text.trim());

      final saved = v.id == null
          ? await provider.createVariant(variantName: name, unitId: v.unitId, actualPrice: actualPrice, discount: discount, cogs: cogs)
          : await provider.updateVariant(id: v.id!, variantName: name, unitId: v.unitId, actualPrice: actualPrice, discount: discount, cogs: cogs);

      if (saved == null) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _saveError = provider.saveErrorMessage ?? 'Something went wrong. Please try again.';
        });
        return;
      }
      result.add(DishVariant(id: saved.id, name: saved.variantName, actualPrice: saved.actualPrice, discount: saved.discount, cogs: saved.cogs, unitId: saved.unitId, unitLabel: v.unitLabel));
    }

    if (!mounted) return;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Edit Variant',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (_saveError != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.cancelled.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(_saveError!, style: const TextStyle(color: AppTheme.cancelled, fontSize: 13, decoration: TextDecoration.none)),
            ),
            const SizedBox(height: 16),
          ],
          for (int i = 0; i < _variants.length; i++) ...[
            _VariantCard(
              data: _variants[i],
              onChanged: () => setState(() {}),
              onRemove: _variants.length > 1 ? () => _removeVariant(i) : null,
              onDelete: _variants[i].id != null ? () => _deleteVariant(i) : null,
            ),
            const SizedBox(height: 16),
          ],
          OutlinedButton.icon(
            onPressed: _addVariant,
            icon: const Icon(Icons.add, color: AppTheme.primary),
            label: const Text(
              'Add Variant',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              '** Hold and Drag to change UP and Down.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isSaving ? null : _reset,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text(
                  'Reset',
                  style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text(
                        'Save Variants',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantFormData {
  String? id;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController discountController;
  final TextEditingController cogsController;
  String? unitId;
  String? unitLabel;

  _VariantFormData()
      : nameController = TextEditingController(),
        priceController = TextEditingController(),
        discountController = TextEditingController(),
        cogsController = TextEditingController();

  factory _VariantFormData.fromVariant(DishVariant v) {
    final data = _VariantFormData();
    data.id = v.id;
    data.nameController.text = v.name;
    data.priceController.text = v.actualPrice == 0 ? '' : v.actualPrice.toStringAsFixed(0);
    data.discountController.text = v.discount == 0 ? '' : v.discount.toStringAsFixed(0);
    data.cogsController.text = v.cogs == 0 ? '' : v.cogs.toStringAsFixed(0);
    data.unitId = v.unitId;
    data.unitLabel = v.unitLabel;
    return data;
  }

  double get listedPrice {
    final actual = double.tryParse(priceController.text) ?? 0;
    final discount = double.tryParse(discountController.text) ?? 0;
    final result = actual - discount;
    return result < 0 ? 0 : result;
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    discountController.dispose();
    cogsController.dispose();
  }
}

class _VariantCard extends StatelessWidget {
  final _VariantFormData data;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;
  final VoidCallback? onDelete;

  const _VariantCard({required this.data, required this.onChanged, this.onRemove, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
                        children: [
                          TextSpan(text: 'Variant Name'),
                          TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _VariantTextField(controller: data.nameController, hint: 'e.g. Large', onChanged: onChanged),
                  ],
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 28),
                    child: Icon(Icons.delete_outline, color: AppTheme.cancelled, size: 20),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
                        children: [
                          TextSpan(text: 'Actual Price'),
                          TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _VariantTextField(
                      controller: data.priceController,
                      hint: 'Rs.',
                      keyboardType: TextInputType.number,
                      onChanged: onChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discount',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 8),
                    _VariantTextField(
                      controller: data.discountController,
                      hint: 'Rs.',
                      keyboardType: TextInputType.number,
                      onChanged: onChanged,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
                        children: [
                          TextSpan(text: 'COGS'),
                          TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _VariantTextField(
                      controller: data.cogsController,
                      hint: 'Rs.',
                      keyboardType: TextInputType.number,
                      onChanged: onChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unit',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final unit = await SelectMeasuringUnitSheet.show(context);
                        if (unit != null) {
                          data.unitId = unit.id;
                          data.unitLabel = unit.name;
                          onChanged();
                        }
                      },
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                data.unitLabel ?? 'Optional',
                                style: TextStyle(color: data.unitLabel != null ? AppTheme.textPrimary : AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Listed Price: Rs ${data.listedPrice.toStringAsFixed(0)}',
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_forever_outlined, size: 15, color: AppTheme.cancelled),
                      SizedBox(width: 4),
                      Text('Delete Variant', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VariantTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final VoidCallback onChanged;

  const _VariantTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged(),
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
      ),
    );
  }
}

// ---------------- from add_dish_screen.dart ----------------

class AddDishScreen extends StatefulWidget {
  final Dish? existingDish;

  const AddDishScreen({super.key, this.existingDish});

  bool get isEditing => existingDish != null;

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _dishNameController = TextEditingController();
  final _actualPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _hsCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  TypeOfMenu? _selectedSubMenu;
  MenuCategory? _selectedCategory;
  DishType? _selectedDishType;
  String? _selectedKitchen;
  Unit? _selectedUnit;
  bool _multiplePrice = false;

  List<DishVariant> _variants = [];
  List<String> _selectedAddOns = [];
  List<StockConsumptionEntry> _stockConsumption = [];
  UploadedMedia? _uploadedPhoto;

  // Only relevant when editing: resolves the dish's plain ids (category,
  // dish type, sub-menu, unit, addons, variants) into the picker display
  // objects the rest of this form already works with. The provider lists
  // are lazy-loaded per-picker on this screen, so editing kicks off a fetch
  // for each and resolution runs once, after they've all loaded.
  bool _prefillApplied = false;

  static String _trimNum(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  void _kickOffPrefillFetches() {
    final categoryProvider = context.read<CategoryProvider>();
    if (categoryProvider.status == LoadStatus.idle) categoryProvider.fetchCategories();
    final dishTypeProvider = context.read<DishTypeProvider>();
    if (dishTypeProvider.status == LoadStatus.idle) dishTypeProvider.fetchDishTypes();
    final typeOfMenuProvider = context.read<TypeOfMenuProvider>();
    if (typeOfMenuProvider.status == LoadStatus.idle) typeOfMenuProvider.fetchTypeOfMenus();
    final unitProvider = context.read<UnitProvider>();
    if (unitProvider.status == LoadStatus.idle) unitProvider.fetchUnits();
    final addOnProvider = context.read<AddOnProvider>();
    if (addOnProvider.status == LoadStatus.idle) addOnProvider.fetchAddOns();
    final variantProvider = context.read<VariantProvider>();
    if (variantProvider.status == LoadStatus.idle) variantProvider.fetchVariants();
  }

  double get _listedPrice {
    final actual = double.tryParse(_actualPriceController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final result = actual - discount;
    return result < 0 ? 0 : result;
  }

  double get _grossProfit => _listedPrice; // placeholder calc — adjust when cost price is added

  @override
  void initState() {
    super.initState();
    final dish = widget.existingDish;
    if (dish != null) {
      _dishNameController.text = dish.dishName;
      _hsCodeController.text = dish.hsCode ?? '';
      _descriptionController.text = dish.description ?? '';
      if (dish.price != null) _actualPriceController.text = _trimNum(dish.price!);
      if (dish.discount != null) _discountController.text = _trimNum(dish.discount!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _kickOffPrefillFetches();
      });
    }
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    _actualPriceController.dispose();
    _discountController.dispose();
    _hsCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickSubMenu() async {
    final result = await SelectSubMenuSheet.show(context);
    if (result != null) setState(() => _selectedSubMenu = result);
  }

  Future<void> _pickCategory() async {
    final result = await SelectCategorySheet.show(context);
    if (result != null) setState(() => _selectedCategory = result);
  }

  Future<void> _pickDishType() async {
    final result = await SelectDishTypeSheet.show(context);
    if (result != null) setState(() => _selectedDishType = result);
  }

  Future<void> _pickKitchen() async {
    final result = await SelectKitchenTypeSheet.show(context);
    if (result != null) setState(() => _selectedKitchen = result);
  }

  Future<void> _pickUnit() async {
    final result = await SelectMeasuringUnitSheet.show(context);
    if (result != null) setState(() => _selectedUnit = result);
  }

  Future<void> _pickAddOns() async {
    final result = await SelectAddOnsSheet.show(context, initiallySelected: _selectedAddOns);
    if (result != null) setState(() => _selectedAddOns = result);
  }

  Future<void> _openStockConsumption() async {
    final result = await SelectStockConsumptionSheet.show(context, initiallySelected: _stockConsumption);
    if (result != null) setState(() => _stockConsumption = result);
  }

  Future<void> _pickImageSource() async {
    final media = await pickAndUploadImage(context);
    if (media != null) setState(() => _uploadedPhoto = media);
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final dishName = _dishNameController.text.trim();

    if (dishName.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Dish Name is required')));
      return;
    }
    if (_selectedCategory == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Please select a Category')));
      return;
    }
    if (_selectedDishType == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Please select a Dish Type')));
      return;
    }

    final price = double.tryParse(_actualPriceController.text.trim());
    final discount = double.tryParse(_discountController.text.trim());

    // AddOns are picked by name (no id-based picker yet) — resolve against
    // the already-fetched AddOnProvider list to get real addonIds.
    final addOnsByName = {for (final a in context.read<AddOnProvider>().addons) a.addonName: a.id};
    final addonIds = _selectedAddOns.map((name) => addOnsByName[name]).whereType<String>().toList();

    final provider = context.read<DishProvider>();
    final hsCode = _hsCodeController.text.trim().isEmpty ? null : _hsCodeController.text.trim();
    final description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();
    final priceAfterDiscount = price == null ? null : _listedPrice;
    final unitId = _selectedUnit?.id;
    final typeOfMenuId = _selectedSubMenu?.id;
    final variantIds = _variants.map((v) => v.id).whereType<String>().toList();

    final dish = widget.isEditing
        ? await provider.updateDish(
            id: widget.existingDish!.id,
            dishName: dishName,
            hsCode: hsCode,
            // A newly-uploaded photo wins; otherwise keep whatever the dish
            // already had rather than clearing it.
            dishPhoto: _uploadedPhoto?.id ?? widget.existingDish!.dishPhoto,
            description: description,
            price: price,
            discountType: discount == null ? null : 'amount',
            discount: discount,
            priceAfterDiscount: priceAfterDiscount,
            addonIds: addonIds,
            dishTypeId: _selectedDishType!.id,
            menuCategoryId: _selectedCategory!.id,
            unitId: unitId,
            typeOfMenuId: typeOfMenuId,
            variantIds: variantIds,
            // No availability toggle in this form yet — preserve whatever
            // the dish already had rather than silently resetting it.
            available: widget.existingDish!.available,
          )
        : await provider.createDish(
            dishName: dishName,
            hsCode: hsCode,
            dishPhoto: _uploadedPhoto?.id,
            description: description,
            price: price,
            discountType: discount == null ? null : 'amount',
            discount: discount,
            priceAfterDiscount: priceAfterDiscount,
            addonIds: addonIds,
            dishTypeId: _selectedDishType!.id,
            menuCategoryId: _selectedCategory!.id,
            // Optional — null unless a real (non-fallback) unit was picked, since
            // GET /api/unit isn't live yet. See SelectMeasuringUnitSheet.
            unitId: unitId,
            typeOfMenuId: typeOfMenuId,
            variantIds: variantIds,
          );
    if (!mounted) return;

    if (dish != null) {
      messenger.showSnackBar(SnackBar(content: Text(widget.isEditing ? 'Dish updated successfully' : 'Dish created successfully')));
      Navigator.pop(context, dish);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      messenger.showSnackBar(SnackBar(content: Text(message ?? 'Failed to save dish')));
    }
  }

  Future<void> _openVariants() async {
    final result = await Navigator.push<List<DishVariant>>(
      context,
      MaterialPageRoute(builder: (context) => EditVariantScreen(initialVariants: _variants)),
    );
    if (result != null) {
      setState(() {
        _variants = result;
        _multiplePrice = result.isNotEmpty;
      });
    }
  }

  /// Resolves the editing dish's plain ids into picker display objects once
  /// every relevant provider list has loaded. Runs at most once (guarded by
  /// [_prefillApplied]); the actual field mutation is deferred to after this
  /// frame since it isn't safe to call `setState` mid-build.
  void _tryApplyPrefill(BuildContext context) {
    final dish = widget.existingDish;
    if (dish == null || _prefillApplied) return;

    final categoryProvider = context.watch<CategoryProvider>();
    final dishTypeProvider = context.watch<DishTypeProvider>();
    final typeOfMenuProvider = context.watch<TypeOfMenuProvider>();
    final unitProvider = context.watch<UnitProvider>();
    final addOnProvider = context.watch<AddOnProvider>();
    final variantProvider = context.watch<VariantProvider>();

    final allLoaded = categoryProvider.status == LoadStatus.loaded &&
        dishTypeProvider.status == LoadStatus.loaded &&
        typeOfMenuProvider.status == LoadStatus.loaded &&
        unitProvider.status == LoadStatus.loaded &&
        addOnProvider.status == LoadStatus.loaded &&
        variantProvider.status == LoadStatus.loaded;
    if (!allLoaded) return;

    _prefillApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedCategory = categoryProvider.categories.where((c) => c.id == dish.menuCategoryId).firstOrNull;
        _selectedDishType = dishTypeProvider.dishTypes.where((t) => t.id == dish.dishTypeId).firstOrNull;
        _selectedSubMenu = dish.typeOfMenuId == null
            ? null
            : typeOfMenuProvider.types.where((m) => m.id == dish.typeOfMenuId).firstOrNull;
        _selectedUnit = dish.unitId == null ? null : unitProvider.units.where((u) => u.id == dish.unitId).firstOrNull;
        _selectedAddOns = addOnProvider.addons.where((a) => dish.addonIds.contains(a.id)).map((a) => a.addonName).toList();
        _variants = variantProvider.variants
            .where((v) => dish.variantIds.contains(v.id))
            .map((v) => DishVariant(id: v.id, name: v.variantName, actualPrice: v.actualPrice, discount: v.discount, cogs: v.cogs, unitId: v.unitId))
            .toList();
        _multiplePrice = _variants.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _tryApplyPrefill(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: Text(
          widget.isEditing ? 'Edit Dish' : 'Add Dish',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _FieldLabel(label: 'Dish Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _dishNameController,
            hint: 'Enter Dish Name',
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Sub-Menu', required: true),
                    const SizedBox(height: 8),
                    _SelectField(
                      hint: 'Select Sub-Menu',
                      value: _selectedSubMenu?.name,
                      onTap: _pickSubMenu,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Category', required: true),
                    const SizedBox(height: 8),
                    _SelectField(
                      hint: 'Select Category',
                      value: _selectedCategory?.categoryName,
                      onTap: _pickCategory,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Actual Price', required: true),
                    const SizedBox(height: 8),
                    _AppTextField(
                      controller: _actualPriceController,
                      hint: 'Rs.',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Discount', required: false),
                    const SizedBox(height: 8),
                    _AppTextField(
                      controller: _discountController,
                      hint: 'Rs.',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            'Listed Price: Rs ${_listedPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gross Profit: Rs ${_grossProfit.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppTheme.completed,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _openStockConsumption,
              icon: const Icon(Icons.edit, size: 16, color: AppTheme.textPrimary),
              label: Text(
                _stockConsumption.isEmpty
                    ? 'Setup Stock Consumption'
                    : '${_stockConsumption.length} Stock Item(s) Configured',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Switch(
                      value: _multiplePrice,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppTheme.accent,
                      onChanged: (val) => setState(() => _multiplePrice = val),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Multiple Price?',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _openVariants,
                  child: Row(
                    children: [
                      Text(
                        _variants.isEmpty ? 'Add Variants' : '${_variants.length} Variant(s)',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.chevron_right, color: AppTheme.textPrimary, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const _SectionHeader(title: 'Image'),
          const SizedBox(height: 12),
          const _FieldLabel(label: 'Dish Photo', required: false),
          const SizedBox(height: 8),
          _UploadBox(
            label: _uploadedPhoto != null
                ? 'Photo uploaded'
                : (widget.existingDish?.dishPhotoUrl != null ? 'Tap to change photo' : 'Tap here to select or upload photos'),
            previewUrl: _uploadedPhoto?.url != null
                ? '${ApiClient.mediaBaseUrl}${_uploadedPhoto!.url}'
                : (widget.existingDish?.dishPhotoUrl != null ? '${ApiClient.mediaBaseUrl}${widget.existingDish!.dishPhotoUrl}' : null),
            onTap: _pickImageSource,
          ),
          const SizedBox(height: 24),

          const _SectionHeader(title: 'Other Details'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Dish Type', required: true),
                    const SizedBox(height: 8),
                    _SelectField(
                      hint: 'Select type',
                      value: _selectedDishType?.dishTypeName,
                      onTap: _pickDishType,
                      leadingDot: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Kitchen', required: false),
                    const SizedBox(height: 8),
                    _SelectField(
                      hint: 'Select',
                      value: _selectedKitchen,
                      onTap: _pickKitchen,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            'Add-Ons or Extras',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickAddOns,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedAddOns.isEmpty
                        ? 'Add-Ons - Click Here'
                        : '${_selectedAddOns.length} Add-On(s) selected',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_right, color: AppTheme.textPrimary, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'H.S Code', required: false),
                    const SizedBox(height: 8),
                    _AppTextField(
                      controller: _hsCodeController,
                      hint: 'Enter HS Code eg. 20.5...',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Preparation Time', required: false),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _AppTextField(hint: '0', suffix: 'hr', keyboardType: TextInputType.number),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text(':', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, decoration: TextDecoration.none)),
                        ),
                        Expanded(
                          child: _AppTextField(hint: '00', suffix: 'm', keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _FieldLabel(label: 'Unit', required: false),
          const SizedBox(height: 8),
          _SelectField(hint: 'Select Unit (optional)', value: _selectedUnit?.name, onTap: _pickUnit),
          const SizedBox(height: 24),

          const _SectionHeader(title: 'Description'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.undo, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      const Icon(Icons.format_align_left, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      const Icon(Icons.format_align_center, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      const Icon(Icons.format_align_right, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      Row(
                        children: const [
                          Text('Normal', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
                          Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary, size: 18),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.format_list_numbered, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      const Icon(Icons.format_list_bulleted, size: 18, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.divider),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write a description...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Consumer<DishProvider>(
                builder: (context, provider, _) {
                  final isSaving = widget.isEditing ? provider.isUpdating : provider.isCreating;
                  return ElevatedButton(
                    onPressed: isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            widget.isEditing ? 'Update' : 'Save',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppTheme.divider)),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          decoration: TextDecoration.none,
        ),
        children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final String? suffix;
  final String? prefix;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    this.controller,
    required this.hint,
    this.suffix,
    this.prefix,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        prefixText: prefix == null ? null : '$prefix   ',
        prefixStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        errorText: errorText,
        errorStyle: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.cancelled),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.cancelled),
        ),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;
  final bool leadingDot;

  const _SelectField({
    required this.hint,
    required this.value,
    required this.onTap,
    this.leadingDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            if (leadingDot && value == null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  color: value != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? previewUrl;

  const _UploadBox({required this.label, required this.onTap, this.previewUrl});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            if (previewUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  previewUrl!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.upload_outlined, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              const Icon(Icons.upload_outlined, color: AppTheme.textSecondary),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppTheme.textSecondary,
                    decoration: TextDecoration.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Add Category screen ----------------

class AddCategoryScreen extends StatefulWidget {
  final MenuCategory? existingCategory;

  const AddCategoryScreen({super.key, this.existingCategory});

  bool get isEditing => existingCategory != null;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  UploadedMedia? _uploadedPhoto;
  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    final category = widget.existingCategory;
    if (category != null) _nameController.text = category.categoryName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImageSource() async {
    final media = await pickAndUploadImage(context);
    if (media != null) setState(() => _uploadedPhoto = media);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    setState(() => _nameError = name.isEmpty);
    if (_nameError) return;

    final provider = context.read<CategoryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final category = widget.isEditing
        ? await provider.updateCategory(
            id: widget.existingCategory!.id,
            categoryName: name,
            // A newly-uploaded photo wins; otherwise keep whatever the
            // category already had rather than clearing it.
            image: _uploadedPhoto?.id ?? widget.existingCategory!.image,
          )
        : await provider.createCategory(categoryName: name, image: _uploadedPhoto?.id);
    if (!mounted) return;

    if (category != null) {
      messenger.showSnackBar(SnackBar(content: Text(widget.isEditing ? 'Category updated successfully' : 'Category created successfully')));
      Navigator.pop(context, category);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      messenger.showSnackBar(SnackBar(content: Text(message ?? 'Failed to save category')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: Text(
          widget.isEditing ? 'Edit Category' : 'Add Category',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _FieldLabel(label: 'Category Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Enter Category Name',
            errorText: _nameError ? 'Required' : null,
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),
          const _FieldLabel(label: 'Category Photo', required: false),
          const SizedBox(height: 8),
          _UploadBox(
            label: _uploadedPhoto != null
                ? 'Photo uploaded'
                : (widget.existingCategory?.imageUrl != null ? 'Tap to change photo' : 'Tap here to select or upload photos'),
            previewUrl: _uploadedPhoto?.url != null
                ? '${ApiClient.mediaBaseUrl}${_uploadedPhoto!.url}'
                : (widget.existingCategory?.imageUrl != null ? '${ApiClient.mediaBaseUrl}${widget.existingCategory!.imageUrl}' : null),
            onTap: _pickImageSource,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text(
                  'Back',
                  style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  final isSaving = widget.isEditing ? provider.isUpdating : provider.isCreating;
                  return ElevatedButton(
                  onPressed: isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          widget.isEditing ? 'Update Category' : 'Save Category',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Create Sub Menu screen ----------------

/// "Create Sub Menu" form, backed by [TypeOfMenuProvider.createTypeOfMenu]
/// (`POST /api/type-of-menu`, which requires `name`+`description`+`status`).
/// "Sub Menu Photo" from the original design has no backend field and no
/// upload flow anywhere in this app yet, so it's dropped.
class AddSubMenuScreen extends StatefulWidget {
  final TypeOfMenu? existingTypeOfMenu;

  const AddSubMenuScreen({super.key, this.existingTypeOfMenu});

  bool get isEditing => existingTypeOfMenu != null;

  @override
  State<AddSubMenuScreen> createState() => _AddSubMenuScreenState();
}

class _AddSubMenuScreenState extends State<AddSubMenuScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _nameError = false;
  bool _descriptionError = false;

  @override
  void initState() {
    super.initState();
    final type = widget.existingTypeOfMenu;
    if (type != null) {
      _nameController.text = type.name;
      _descriptionController.text = type.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    setState(() {
      _nameError = name.isEmpty;
      _descriptionError = description.isEmpty;
    });
    if (_nameError || _descriptionError) return;

    final provider = context.read<TypeOfMenuProvider>();
    final result = widget.isEditing
        ? await provider.updateTypeOfMenu(id: widget.existingTypeOfMenu!.id, name: name, description: description, status: widget.existingTypeOfMenu!.status)
        : await provider.createTypeOfMenu(name: name, description: description, status: true);
    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context, result);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TypeOfMenuProvider>();
    final isSaving = widget.isEditing ? provider.isUpdating : provider.isCreating;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: Text(
          widget.isEditing ? 'Edit Sub Menu' : 'Create Sub Menu',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _FieldLabel(label: 'Sub Menu Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Enter Sub Menu Name',
            errorText: _nameError ? 'Required' : null,
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),
          _FieldLabel(label: 'Description', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _descriptionController,
            hint: 'Enter Description',
            errorText: _descriptionError ? 'Required' : null,
            onChanged: (v) {
              if (_descriptionError && v.trim().isNotEmpty) setState(() => _descriptionError = false);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text(
                  'Back',
                  style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        widget.isEditing ? 'Update Sub Menu' : 'Save Sub Menu',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}