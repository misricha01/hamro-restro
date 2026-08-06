import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/dish/dish_model.dart';
import '../../providers/dish_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/manage_list_controls.dart';

/// "Combo" item picker reached from the Add Combo Dish screen's
/// "Add Item Details" row, sourced live from [DishProvider] (backend:
/// `/api/dish`) — returns the selected dishes' real ids for
/// `CreateComboOfferDTO.dishIds`.
class SelectComboItemsScreen extends StatefulWidget {
  final List<String> initiallySelected;
  const SelectComboItemsScreen({super.key, this.initiallySelected = const []});

  @override
  State<SelectComboItemsScreen> createState() => _SelectComboItemsScreenState();
}

class _SelectComboItemsScreenState extends State<SelectComboItemsScreen> {
  late Set<String> _selected;
  final _searchController = TextEditingController();
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initiallySelected.toSet();
    final provider = context.read<DishProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchDishes());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Dish> _filtered(List<Dish> dishes) {
    if (_searchController.text.isEmpty) return dishes;
    final q = _searchController.text.toLowerCase();
    return dishes.where((d) => d.dishName.toLowerCase().contains(q)).toList();
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) _searchController.clear();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _returnSelection() => Navigator.pop(context, _selected.toList());

  @override
  Widget build(BuildContext context) {
    final dishProvider = context.watch<DishProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: _returnSelection,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Combo',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _toggleSearch,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 18, color: _searchVisible ? AppTheme.cancelled : AppTheme.textPrimary),
                    const SizedBox(width: 6),
                    Text(
                      'Search',
                      style: TextStyle(color: _searchVisible ? AppTheme.cancelled : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            Expanded(child: _buildBody(dishProvider)),
            Padding(
              padding: EdgeInsets.only(bottom: 14 + MediaQuery.of(context).padding.bottom),
              child: Text(
                'Total Dish : ${dishProvider.dishes.length}',
                style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(DishProvider provider) {
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
                  onPressed: () => provider.fetchDishes(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.dishes.isEmpty) {
          return const Center(child: Text('No Dishes created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)));
        }
        final filtered = _filtered(provider.dishes);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 160,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final dish = filtered[index];
            return _ComboDishCard(
              dish: dish,
              selected: _selected.contains(dish.id),
              onTap: () => _toggleSelected(dish.id),
            );
          },
        );
    }
  }
}

class _ComboDishCard extends StatelessWidget {
  final Dish dish;
  final bool selected;
  final VoidCallback onTap;

  const _ComboDishCard({required this.dish, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.cancelled : AppTheme.divider),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
                  child: const Icon(Icons.restaurant_menu, size: 32, color: AppTheme.accent),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        dish.dishName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dish.price == null ? '-' : 'Rs ${dish.price!.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.cancelled, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: selected ? AppTheme.cancelled : AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? AppTheme.cancelled : AppTheme.divider),
                ),
                child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
