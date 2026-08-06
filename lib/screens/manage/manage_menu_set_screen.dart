import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/manage_list_controls.dart';
import '../create_dish/add_menu_set_screen.dart' show AddMenuSetScreen;

/// Menu Set list for the Manage screen, reached from the Menu overview's
/// "Menu Set" row. Shows the configured menu sets with search, matching the
/// reference design's "Default Menuset" card + "Add New Menu Set" action.
class MenuSetItem {
  final String name;
  final String initials;
  final List<String> services;
  final int subMenuCount;
  final bool active;

  MenuSetItem({
    required this.name,
    required this.initials,
    required this.services,
    required this.subMenuCount,
    this.active = true,
  });
}

class ManageMenuSetScreen extends StatefulWidget {
  const ManageMenuSetScreen({super.key});

  @override
  State<ManageMenuSetScreen> createState() => _ManageMenuSetScreenState();
}

class _ManageMenuSetScreenState extends State<ManageMenuSetScreen> {
  final List<MenuSetItem> _menuSets = [
    MenuSetItem(
      name: 'Default Menuset',
      initials: 'DM',
      services: const ['Dine In Service', 'Delivery Services', 'Pickup Services', 'Reservation Services', 'Takeaway Services'],
      subMenuCount: 3,
    ),
  ];
  final _searchController = TextEditingController();
  bool _searchVisible = false;

  List<MenuSetItem> get _filtered {
    if (_searchController.text.isEmpty) return _menuSets;
    final q = _searchController.text.toLowerCase();
    return _menuSets.where((m) => m.name.toLowerCase().contains(q)).toList();
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

  Future<void> _createMenuSet() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const AddMenuSetScreen()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _menuSets.add(MenuSetItem(
            name: result,
            initials: result.trim().isEmpty ? '?' : result.trim().substring(0, 1).toUpperCase(),
            services: const [],
            subMenuCount: 0,
          )));
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
        title: const Text(
          'Menu Set',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          ManageAppBarIconButton(icon: Icons.search, active: _searchVisible, onTap: _toggleSearch),
          ManageAppBarIconButton(icon: Icons.more_horiz, bordered: true, onTap: () {}),
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final menuSet in _filtered) ...[
                    _MenuSetCard(menuSet: menuSet),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Total Menu Set : ${_menuSets.length}',
                      style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _createMenuSet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Add New Menu Set',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSetCard extends StatelessWidget {
  final MenuSetItem menuSet;
  const _MenuSetCard({required this.menuSet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
            child: Text(
              menuSet.initials,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuSet.name,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
                ),
                if (menuSet.services.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Services: ${menuSet.services.join(', ')}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Sub Menu: ${menuSet.subMenuCount}',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: (menuSet.active ? AppTheme.completed : AppTheme.textSecondary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  menuSet.active ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: menuSet.active ? AppTheme.completed : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
