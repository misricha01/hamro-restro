import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/category/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/dish_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/type_of_menu_provider.dart';
import '../../providers/variant_provider.dart';
import '../../widgets/common/dish_quick_view_sheet.dart';
import '../../widgets/common/manage_list_controls.dart';
import '../../widgets/common/menu_item_actions_menu.dart';
import '../../widgets/common/menu_setup_widgets.dart';
import '../create_dish/add_dish_screen.dart' show SelectCategorySheet;
import '../create_dish/add_menu_set_screen.dart' show AddMenuSetScreen;
import 'manage_menu_set_screen.dart' show MenuSetItem;
import 'sub_menu_detail_screen.dart';

/// "Default Menuset" detail — opened from [ManageMenuSetScreen]'s card.
/// Menu Set itself has no backend entity (see ManageMenuSetScreen), but its
/// three tabs are the real thing: Dishes/Sub Menu/Category are backed by
/// [DishProvider]/[TypeOfMenuProvider]/[CategoryProvider], same providers
/// already used by the rest of the Menu module. [onRenamed]/[onDeleted] let
/// Edit/Move To Trash update the parent list screen's local state.
class DefaultMenuSetScreen extends StatefulWidget {
  final MenuSetItem menuSet;
  final ValueChanged<String> onRenamed;
  final VoidCallback onDeleted;

  const DefaultMenuSetScreen({super.key, required this.menuSet, required this.onRenamed, required this.onDeleted});

  @override
  State<DefaultMenuSetScreen> createState() => _DefaultMenuSetScreenState();
}

class _DefaultMenuSetScreenState extends State<DefaultMenuSetScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this)..addListener(() => setState(() {}));
  final _searchController = TextEditingController();
  bool _searchVisible = false;
  bool _filterVisible = false;
  MenuCategory? _categoryFilter;

  @override
  void initState() {
    super.initState();
    final dishProvider = context.read<DishProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final typeOfMenuProvider = context.read<TypeOfMenuProvider>();
    final variantProvider = context.read<VariantProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dishProvider.status == LoadStatus.idle) dishProvider.fetchDishes();
      if (categoryProvider.status == LoadStatus.idle) categoryProvider.fetchCategories();
      if (typeOfMenuProvider.status == LoadStatus.idle) typeOfMenuProvider.fetchTypeOfMenus();
      if (variantProvider.status == LoadStatus.idle) variantProvider.fetchVariants();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) _searchController.clear();
    });
  }

  void _toggleFilter() => setState(() => _filterVisible = !_filterVisible);

  Future<void> _pickCategoryFilter() async {
    final result = await SelectCategorySheet.show(context);
    if (result != null) setState(() => _categoryFilter = result);
  }

  Future<void> _edit() async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => AddMenuSetScreen(existingName: widget.menuSet.name)));
    if (result != null && result.isNotEmpty && mounted) {
      widget.onRenamed(result);
      setState(() {});
    }
  }

  Future<void> _moveToTrash() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Move To Trash', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          'Remove "${widget.menuSet.name}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Move To Trash', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.onDeleted();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final showFilter = _tabController.index == 0;

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
        title: Text(
          widget.menuSet.name,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          ManageAppBarIconButton(icon: Icons.search, active: _searchVisible, onTap: _toggleSearch),
          if (showFilter)
            ManageAppBarIconButton(
              icon: _filterVisible ? Icons.filter_alt : Icons.filter_alt_outlined,
              active: _filterVisible,
              onTap: _toggleFilter,
            ),
          MenuItemActionsMenu(onEdit: _edit, onMoveToTrash: _moveToTrash),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
          unselectedLabelStyle: const TextStyle(decoration: TextDecoration.none),
          tabs: const [Tab(text: 'Dishes'), Tab(text: 'Sub Menu'), Tab(text: 'Category')],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searchVisible)
              ManageSearchField(controller: _searchController, onClose: _toggleSearch, onChanged: (_) => setState(() {})),
            if (showFilter && _filterVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ManageFilterChip(label: 'Category', value: _categoryFilter?.categoryName, onTap: _pickCategoryFilter),
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DishesTab(query: _searchController.text, categoryFilterId: _categoryFilter?.id),
                  const _SubMenuTab(),
                  _CategoryTab(query: _searchController.text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DishesTab extends StatelessWidget {
  final String query;
  final String? categoryFilterId;
  const _DishesTab({required this.query, required this.categoryFilterId});

  @override
  Widget build(BuildContext context) {
    final dishProvider = context.watch<DishProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final variantProvider = context.watch<VariantProvider>();

    if (dishProvider.status == LoadStatus.idle || dishProvider.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (dishProvider.status == LoadStatus.error) {
      return _ErrorState(message: dishProvider.errorMessage, onRetry: () => dishProvider.fetchDishes());
    }

    var dishes = dishProvider.dishes;
    if (categoryFilterId != null) {
      dishes = dishes.where((d) => d.menuCategoryId == categoryFilterId).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      dishes = dishes.where((d) => d.dishName.toLowerCase().contains(q)).toList();
    }
    if (dishes.isEmpty) return const MenuSetupNoDishState();

    final categoryNames = {for (final c in categoryProvider.categories) c.id: c.categoryName};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final dish in dishes)
          MenuSetupDishRow(
            dish: dish,
            categoryName: categoryNames[dish.menuCategoryId] ?? '',
            priceLabel: dishPriceLabel(dish, variantProvider.variants),
            onTap: () => DishQuickViewSheet.show(context, dishId: dish.id),
          ),
        const SizedBox(height: 8),
        Center(
          child: Text('Total Dishes : ${dishes.length}', style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        ),
      ],
    );
  }
}

class _SubMenuTab extends StatelessWidget {
  const _SubMenuTab();

  @override
  Widget build(BuildContext context) {
    final typeOfMenuProvider = context.watch<TypeOfMenuProvider>();
    final dishes = context.watch<DishProvider>().dishes;

    if (typeOfMenuProvider.status == LoadStatus.idle || typeOfMenuProvider.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (typeOfMenuProvider.status == LoadStatus.error) {
      return _ErrorState(message: typeOfMenuProvider.errorMessage, onRetry: () => typeOfMenuProvider.fetchTypeOfMenus());
    }

    final types = typeOfMenuProvider.types;
    if (types.isEmpty) {
      return const Center(child: Text('No Sub-Menus created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 160,
          ),
          itemCount: types.length,
          itemBuilder: (context, index) {
            final subMenu = types[index];
            return MenuSetupSubMenuCard(
              name: subMenu.name,
              dishCount: dishes.where((d) => d.typeOfMenuId == subMenu.id).length,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubMenuDetailScreen(subMenu: subMenu))),
            );
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: Text('Total Sub Menu : ${types.length}', style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        ),
      ],
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String query;
  const _CategoryTab({required this.query});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final dishes = context.watch<DishProvider>().dishes;

    if (categoryProvider.status == LoadStatus.idle || categoryProvider.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (categoryProvider.status == LoadStatus.error) {
      return _ErrorState(message: categoryProvider.errorMessage, onRetry: () => categoryProvider.fetchCategories());
    }

    var categories = categoryProvider.categories;
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      categories = categories.where((c) => c.categoryName.toLowerCase().contains(q)).toList();
    }
    if (categories.isEmpty) {
      return const Center(child: Text('No Category created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 140,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return MenuSetupCategoryCard(
              name: category.categoryName,
              dishCount: dishes.where((d) => d.menuCategoryId == category.id).length,
            );
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: Text('Total Category : ${categories.length}', style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(message ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
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
