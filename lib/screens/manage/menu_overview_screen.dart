import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/addon_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/dish_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/menu_sets_sheet.dart';
import '../../widgets/common/setting_rows_card.dart';
import '../create_dish/add_dish_screen.dart' show AddDishScreen, AddCategoryScreen, AddSubMenuScreen, SelectAddOnsSheet;
import '../create_dish/add_addon_screen.dart' show AddAddOnScreen;
import '../create_dish/add_combo_screen.dart' show AddComboScreen;
import 'manage_dishes_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_combo_offers_screen.dart';
import 'manage_menu_set_screen.dart';
import 'manage_sub_menu_screen.dart';

/// Full "Menu" overview reached from the Manage screen's Menu section
/// (its header "more" button and "View All" link both land here). Surfaces
/// quick-create shortcuts plus the Dish Setup / Menu Setup groups, reusing
/// the existing dish/category/add-on/sub-menu/menu-set screens wherever
/// they already exist. Dish/Category/Add-Ons counts are backed by
/// [DishProvider]/[CategoryProvider]/[AddOnProvider]; Menu Set and Sub Menu
/// stay hardcoded since neither has a backend entity yet.
class MenuOverviewScreen extends StatefulWidget {
  const MenuOverviewScreen({super.key});

  @override
  State<MenuOverviewScreen> createState() => _MenuOverviewScreenState();
}

class _MenuOverviewScreenState extends State<MenuOverviewScreen> {
  @override
  void initState() {
    super.initState();
    final dishProvider = context.read<DishProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final addOnProvider = context.read<AddOnProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dishProvider.status == LoadStatus.idle) dishProvider.fetchDishes();
      if (categoryProvider.status == LoadStatus.idle) categoryProvider.fetchCategories();
      if (addOnProvider.status == LoadStatus.idle) addOnProvider.fetchAddOns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dishCount = context.watch<DishProvider>().dishes.length;
    final categoryCount = context.watch<CategoryProvider>().categories.length;
    final addOnCount = context.watch<AddOnProvider>().addons.length;

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
          'Menu',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _SummaryCard(
              dishCount: dishCount,
              categoryCount: categoryCount,
              addOnCount: addOnCount,
              onAddDish: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDishScreen())),
              onAddCategory: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCategoryScreen())),
              onAddSubMenu: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSubMenuScreen())),
              onAddAddOn: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddOnScreen())),
              onAddMenuSet: () => MenuSetsSheet.show(context),
              onAddCombo: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddComboScreen())),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Dish Setup',
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
              ),
            ),
            SettingRowsCard(
              items: [
                SettingRowData(
                  icon: Icons.ramen_dining_outlined,
                  title: 'Dishes',
                  subtitle: 'Create & Manage all Dishes',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageDishesScreen())),
                ),
                SettingRowData(
                  icon: Icons.dashboard_outlined,
                  title: 'Category',
                  subtitle: 'Create & manage dishes with category',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen())),
                ),
                SettingRowData(
                  icon: Icons.local_offer_outlined,
                  title: 'Add-Ons or Extras',
                  subtitle: 'Sale more with better ad-ons suggestions',
                  onTap: () => SelectAddOnsSheet.show(context),
                ),
                SettingRowData(
                  icon: Icons.set_meal_outlined,
                  title: 'Combo Offer',
                  subtitle: 'Create & Manage all Combo Offer',
                  badge: 'New',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageComboOffersScreen())),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Menu Setup',
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
              ),
            ),
            SettingRowsCard(
              items: [
                SettingRowData(
                  icon: Icons.layers_outlined,
                  title: 'Menu Set',
                  subtitle: 'Have multiple sets of menu for ease',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageMenuSetScreen())),
                ),
                SettingRowData(
                  icon: Icons.menu_book_outlined,
                  title: 'Sub Menu',
                  subtitle: 'Create sub menu and make Menu more easy',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageSubMenuScreen())),
                ),
              ],
            ),
            const SizedBox(height: 24),

            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // TODO: Link to help/documentation once available.
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, color: AppTheme.textPrimary, size: 18),
                    SizedBox(width: 8),
                    Text('Learn More', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  // TODO: Link to support flow once available.
                },
                child: const Text(
                  'Need Help?',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int dishCount;
  final int categoryCount;
  final int addOnCount;
  final VoidCallback onAddDish;
  final VoidCallback onAddCategory;
  final VoidCallback onAddSubMenu;
  final VoidCallback onAddAddOn;
  final VoidCallback onAddMenuSet;
  final VoidCallback onAddCombo;

  const _SummaryCard({
    required this.dishCount,
    required this.categoryCount,
    required this.addOnCount,
    required this.onAddDish,
    required this.onAddCategory,
    required this.onAddSubMenu,
    required this.onAddAddOn,
    required this.onAddMenuSet,
    required this.onAddCombo,
  });

  static const int _dishLimit = 1000;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Dishes',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
              ),
              const Spacer(),
              Text(
                '$dishCount / $_dishLimit',
                style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 14, decoration: TextDecoration.none),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (dishCount / _dishLimit).clamp(0.02, 1.0),
              minHeight: 6,
              backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(child: _StatColumn(value: '1', label: 'Menu Set', color: AppTheme.textPrimary)),
              const Expanded(child: _StatColumn(value: '3', label: 'Sub Menu', color: AppTheme.completed)),
              Expanded(child: _StatColumn(value: '$categoryCount', label: 'Category', color: AppTheme.primary)),
              Expanded(child: _StatColumn(value: '$addOnCount', label: 'Add-Ons', color: AppTheme.accent)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: AppTheme.textPrimary, size: 16),
                        SizedBox(width: 4),
                        Text('Add', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 24, color: AppTheme.divider),
                  const SizedBox(width: 10),
                  _AddPill(label: 'Dish', onTap: onAddDish),
                  const SizedBox(width: 10),
                  _AddPill(label: 'Category', onTap: onAddCategory),
                  const SizedBox(width: 10),
                  _AddPill(label: 'Sub-Menu', onTap: onAddSubMenu),
                  const SizedBox(width: 10),
                  _AddPill(label: 'Add-Ons', onTap: onAddAddOn),
                  const SizedBox(width: 10),
                  _AddPill(label: 'Menu Set', onTap: onAddMenuSet),
                  const SizedBox(width: 10),
                  _AddPill(label: 'Combo Dish', onTap: onAddCombo),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatColumn({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20, decoration: TextDecoration.none)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none)),
      ],
    );
  }
}

class _AddPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
      ),
    );
  }
}

