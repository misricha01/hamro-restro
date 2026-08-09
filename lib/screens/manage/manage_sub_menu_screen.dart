import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/dish/dish_model.dart';
import '../../data/models/type_of_menu/type_of_menu_model.dart';
import '../../providers/dish_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/type_of_menu_provider.dart';
import '../../widgets/common/manage_list_controls.dart';
import '../../widgets/common/menu_setup_widgets.dart';
import '../create_dish/add_dish_screen.dart' show AddSubMenuScreen;
import 'sub_menu_detail_screen.dart';

/// Sub Menu list for the Manage screen, reached from the Menu overview's
/// "Sub Menu" row, sourced live from [TypeOfMenuProvider] (backend:
/// `/api/type-of-menu`). Cards tap through to [SubMenuDetailScreen], which
/// hosts the Edit/Move To Trash actions — matches the reference, where the
/// grid itself has no per-card action icon.
class ManageSubMenuScreen extends StatefulWidget {
  const ManageSubMenuScreen({super.key});

  @override
  State<ManageSubMenuScreen> createState() => _ManageSubMenuScreenState();
}

class _ManageSubMenuScreenState extends State<ManageSubMenuScreen> {
  final _searchController = TextEditingController();
  bool _searchVisible = false;
  bool _filterVisible = false;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TypeOfMenuProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchTypeOfMenus());
    }
    final dishProvider = context.read<DishProvider>();
    if (dishProvider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => dishProvider.fetchDishes());
    }
  }

  Future<void> _openSubMenu(TypeOfMenu subMenu) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => SubMenuDetailScreen(subMenu: subMenu)));
  }

  List<TypeOfMenu> _filtered(List<TypeOfMenu> items) {
    var result = items;
    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      result = result.where((s) => s.name.toLowerCase().contains(q)).toList();
    }
    if (_statusFilter != null) {
      final wantActive = _statusFilter == 'Active';
      result = result.where((s) => s.status == wantActive).toList();
    }
    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) _searchController.clear();
    });
  }

  void _toggleFilter() {
    setState(() => _filterVisible = !_filterVisible);
  }

  Future<void> _pickStatus() async {
    final result = await SelectStatusSheet.show(context, initialStatus: _statusFilter);
    setState(() => _statusFilter = result);
  }

  Future<void> _createSubMenu() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSubMenuScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TypeOfMenuProvider>();

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
          'Sub Menu',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          ManageAppBarIconButton(icon: Icons.search, active: _searchVisible, onTap: _toggleSearch),
          ManageAppBarIconButton(
            icon: _filterVisible ? Icons.filter_alt : Icons.filter_alt_outlined,
            active: _filterVisible,
            onTap: _toggleFilter,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searchVisible)
              ManageSearchField(
                controller: _searchController,
                onClose: _toggleSearch,
                onChanged: (_) => setState(() {}),
              ),
            if (_filterVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ManageFilterChip(label: 'Status', value: _statusFilter, onTap: _pickStatus),
                ),
              ),
            Expanded(child: _buildBody(provider, context.watch<DishProvider>().dishes)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TypeOfMenuProvider provider, List<Dish> dishes) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => provider.fetchTypeOfMenus(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final filtered = _filtered(provider.types);
        return Column(
          children: [
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('No Sub-Menus created yet.', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                    )
                  : RefreshIndicator(
                      color: AppTheme.accent,
                      onRefresh: () => provider.fetchTypeOfMenus(),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 160,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final subMenu = filtered[index];
                          return MenuSetupSubMenuCard(
                            name: subMenu.name,
                            dishCount: dishes.where((d) => d.typeOfMenuId == subMenu.id).length,
                            onTap: () => _openSubMenu(subMenu),
                          );
                        },
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Total Sub Menu : ${provider.types.length}',
                style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _createSubMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Create Sub Menu',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _StatusOption {
  final String code;
  final String name;
  _StatusOption(this.code, this.name);
}

/// "Select Status" bottom sheet for the Sub Menu filter, matching the
/// AC/IN-style avatar rows already used by SelectKitchenTypeSheet.
class SelectStatusSheet extends StatefulWidget {
  final String? initialStatus;
  const SelectStatusSheet({super.key, this.initialStatus});

  static Future<String?> show(BuildContext context, {String? initialStatus}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectStatusSheet(initialStatus: initialStatus),
    );
  }

  @override
  State<SelectStatusSheet> createState() => _SelectStatusSheetState();
}

class _SelectStatusSheetState extends State<SelectStatusSheet> {
  final _searchController = TextEditingController();

  final List<_StatusOption> _items = [
    _StatusOption('AC', 'Active'),
    _StatusOption('IN', 'Inactive'),
  ];

  List<_StatusOption> get _filtered {
    if (_searchController.text.isEmpty) return _items;
    final q = _searchController.text.toLowerCase();
    return _items.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                      'Select Status',
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
                          final selected = item.name == widget.initialStatus;
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, item.name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                                    child: Text(
                                      item.code,
                                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    item.name,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
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
                        'Total : ${_items.length}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
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
