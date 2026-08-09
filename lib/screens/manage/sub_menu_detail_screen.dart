import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/type_of_menu/type_of_menu_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/dish_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/type_of_menu_provider.dart';
import '../../providers/variant_provider.dart';
import '../../widgets/common/dish_quick_view_sheet.dart';
import '../../widgets/common/manage_list_controls.dart';
import '../../widgets/common/menu_item_actions_menu.dart';
import '../../widgets/common/menu_setup_widgets.dart';
import '../create_dish/add_dish_screen.dart' show AddSubMenuScreen;

/// "Food Menu" / "Bar Menu" / "Cafe Menu" detail — opened from a Sub Menu
/// card on either [ManageSubMenuScreen] or [DefaultMenuSetScreen]'s Sub Menu
/// tab. Dishes are the real [DishProvider] list filtered by
/// `dish.typeOfMenuId`; Category shows the same full [CategoryProvider]
/// list the Default Menu Set does (confirmed against the reference: Bar
/// Menu's Category tab still lists every category, not just ones with
/// dishes assigned to this sub-menu). Edit/Move To Trash operate on the
/// real `/api/type-of-menu` resource via [TypeOfMenuProvider].
class SubMenuDetailScreen extends StatefulWidget {
  final TypeOfMenu subMenu;
  const SubMenuDetailScreen({super.key, required this.subMenu});

  @override
  State<SubMenuDetailScreen> createState() => _SubMenuDetailScreenState();
}

class _SubMenuDetailScreenState extends State<SubMenuDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  late TypeOfMenu _subMenu = widget.subMenu;
  final _searchController = TextEditingController();
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    final dishProvider = context.read<DishProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final variantProvider = context.read<VariantProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dishProvider.status == LoadStatus.idle) dishProvider.fetchDishes();
      if (categoryProvider.status == LoadStatus.idle) categoryProvider.fetchCategories();
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

  Future<void> _edit() async {
    final updated = await Navigator.push<TypeOfMenu>(context, MaterialPageRoute(builder: (context) => AddSubMenuScreen(existingTypeOfMenu: _subMenu)));
    if (updated != null && mounted) setState(() => _subMenu = updated);
  }

  Future<void> _moveToTrash() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Move To Trash', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          'Remove "${_subMenu.name}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Move To Trash', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<TypeOfMenuProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteTypeOfMenu(_subMenu.id);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to move to trash')));
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
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: Text(
          _subMenu.name,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          ManageAppBarIconButton(icon: Icons.search, active: _searchVisible, onTap: _toggleSearch),
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
          tabs: const [Tab(text: 'Dishes'), Tab(text: 'Category')],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searchVisible)
              ManageSearchField(controller: _searchController, onClose: _toggleSearch, onChanged: (_) => setState(() {})),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DishesTab(subMenuId: _subMenu.id, query: _searchController.text),
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
  final String subMenuId;
  final String query;
  const _DishesTab({required this.subMenuId, required this.query});

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

    var dishes = dishProvider.dishes.where((d) => d.typeOfMenuId == subMenuId).toList();
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

class _CategoryTab extends StatelessWidget {
  final String query;
  const _CategoryTab({required this.query});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final dishProvider = context.watch<DishProvider>();

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
        for (final category in categories)
          MenuSetupCategoryRow(
            name: category.categoryName,
            dishCount: dishProvider.dishes.where((d) => d.menuCategoryId == category.id).length,
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
