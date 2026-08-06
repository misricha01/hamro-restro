import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Result of [FilterSortSheet] — only [category] is wired to real dish
/// filtering (it maps onto [QuickBillingScreen]'s existing category list).
/// Combo / sub-menu / dish-type are collected for a faithful match to the
/// reference UI but aren't backed by dish data yet, so they're not applied.
class FilterSortResult {
  final String? category;
  final bool combosOnly;
  final String? subMenu;
  final Set<String> dishTypes;

  const FilterSortResult({this.category, this.combosOnly = false, this.subMenu, this.dishTypes = const {}});
}

class FilterSortSheet extends StatefulWidget {
  final List<String> categories;
  final String selectedCategory;

  const FilterSortSheet({super.key, required this.categories, required this.selectedCategory});

  static Future<FilterSortResult?> show(BuildContext context, {required List<String> categories, required String selectedCategory}) {
    return showModalBottomSheet<FilterSortResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSortSheet(categories: categories, selectedCategory: selectedCategory),
    );
  }

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

enum _FilterTab { combo, subMenu, dishType, category }

class _FilterSortSheetState extends State<FilterSortSheet> {
  _FilterTab _tab = _FilterTab.category;
  bool _combosOnly = false;
  String? _subMenu;
  final Set<String> _dishTypes = {};
  late String _category = widget.selectedCategory;

  static const _dishTypeOptions = [
    ('Veg', Icons.circle, AppTheme.completed),
    ('Non-Veg', Icons.circle, AppTheme.cancelled),
    ('Vegan', Icons.eco_outlined, AppTheme.completed),
    ('Spicy', Icons.local_fire_department_outlined, AppTheme.pending),
    ('Gluten Free', Icons.grain_outlined, AppTheme.accent),
  ];

  void _clearAll() {
    setState(() {
      _combosOnly = false;
      _subMenu = null;
      _dishTypes.clear();
      _category = 'All Categories';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Filter & Sort', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: AppTheme.textPrimary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 92,
                        child: ListView(
                          controller: scrollController,
                          children: [
                            _TabRow(icon: Icons.inventory_2_outlined, label: 'Combo', selected: _tab == _FilterTab.combo, onTap: () => setState(() => _tab = _FilterTab.combo)),
                            _TabRow(icon: Icons.menu_book_outlined, label: 'Sub Menu', selected: _tab == _FilterTab.subMenu, onTap: () => setState(() => _tab = _FilterTab.subMenu)),
                            _TabRow(icon: Icons.ramen_dining_outlined, label: 'Dish Type', selected: _tab == _FilterTab.dishType, onTap: () => setState(() => _tab = _FilterTab.dishType)),
                            _TabRow(icon: Icons.dashboard_outlined, label: 'Category', selected: _tab == _FilterTab.category, onTap: () => setState(() => _tab = _FilterTab.category)),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 1, color: AppTheme.divider),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildTabContent(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.divider))),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _clearAll,
                        child: const Text('Clear All', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 180,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(
                            context,
                            FilterSortResult(category: _category, combosOnly: _combosOnly, subMenu: _subMenu, dishTypes: _dishTypes),
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.completed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text('Apply Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case _FilterTab.combo:
        return _SectionBox(
          title: 'Combo',
          child: Row(
            children: [
              const Expanded(child: Text('Combos Only', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none))),
              Switch(
                value: _combosOnly,
                activeThumbColor: Colors.white,
                activeTrackColor: AppTheme.completed,
                onChanged: (v) => setState(() => _combosOnly = v),
              ),
            ],
          ),
        );
      case _FilterTab.subMenu:
        return _SectionBox(
          title: 'Sub Menu',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ['Food Menu', 'Cafe Menu'].map((s) {
              final selected = _subMenu == s;
              return _Chip(label: s, selected: selected, onTap: () => setState(() => _subMenu = selected ? null : s));
            }).toList(),
          ),
        );
      case _FilterTab.dishType:
        return _SectionBox(
          title: 'Dish Type',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _dishTypeOptions.map((opt) {
              final (label, icon, color) = opt;
              final selected = _dishTypes.contains(label);
              return _Chip(
                label: label,
                icon: icon,
                iconColor: color,
                selected: selected,
                onTap: () => setState(() => selected ? _dishTypes.remove(label) : _dishTypes.add(label)),
              );
            }).toList(),
          ),
        );
      case _FilterTab.category:
        return _SectionBox(
          title: 'Category',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.categories.map((c) {
              final selected = _category == c;
              return _Chip(label: c == 'All Categories' ? 'All Categories' : c, selected: selected, onTap: () => setState(() => _category = c));
            }).toList(),
          ),
        );
    }
  }
}

class _TabRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabRow({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppTheme.cancelled.withValues(alpha: 0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 22, color: selected ? AppTheme.cancelled : AppTheme.textSecondary),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: selected ? AppTheme.cancelled : AppTheme.textSecondary, fontWeight: selected ? FontWeight.w700 : FontWeight.normal, decoration: TextDecoration.none),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, this.icon, this.iconColor, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cancelled.withValues(alpha: 0.12) : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.cancelled : AppTheme.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor ?? AppTheme.textPrimary),
              const SizedBox(width: 6),
            ],
            Text(label, style: TextStyle(color: selected ? AppTheme.cancelled : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}
