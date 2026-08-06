import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/area/area_model.dart';
import '../../providers/area_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/confirm_delete_dialog.dart';
import '../../widgets/common/edit_delete_actions_sheet.dart';
import '../../widgets/common/manage_list_controls.dart';
import '../../widgets/common/setting_rows_card.dart';
import 'create_space_screen.dart';

/// Space list for the Manage screen, reached f
/// rom the "Table & Space"
/// section's "Space" row. Shows the same empty state as the reference
/// design until at least one space has been created.
class ManageSpaceScreen extends StatefulWidget {
  const ManageSpaceScreen({super.key});

  @override
  State<ManageSpaceScreen> createState() => _ManageSpaceScreenState();
}

class _ManageSpaceScreenState extends State<ManageSpaceScreen> {
  final _searchController = TextEditingController();
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AreaProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchAreas());
    }
  }

  List<Area> _filtered(List<Area> areas) {
    if (_searchController.text.isEmpty) return areas;
    final q = _searchController.text.toLowerCase();
    return areas.where((s) => s.areaName.toLowerCase().contains(q)).toList();
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

  Future<void> _createSpace() async {
    await Navigator.push<Area>(context, MaterialPageRoute(builder: (context) => const CreateSpaceScreen()));
  }

  Future<void> _openSpaceActions(Area area) async {
    final action = await EditDeleteActionsSheet.show(context, title: area.areaName);
    if (!mounted || action == null) return;

    if (action == 'edit') {
      await Navigator.push<Area>(context, MaterialPageRoute(builder: (context) => CreateSpaceScreen(editingArea: area)));
      return;
    }

    if (action == 'delete') {
      final confirmed = await confirmDelete(context, entityName: 'space');
      if (!mounted || !confirmed) return;

      final provider = context.read<AreaProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final success = await provider.deleteArea(area.id);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(success ? 'Space deleted' : (provider.deleteErrorMessage ?? 'Failed to delete space'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final areaProvider = context.watch<AreaProvider>();

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
          'Space',
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
            Expanded(child: _buildBody(areaProvider)),
            if (areaProvider.status == LoadStatus.loaded && areaProvider.areas.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Total Space : ${areaProvider.areas.length}',
                  style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _createSpace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Create New Space',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AreaProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(
          message: provider.errorMessage ?? 'Something went wrong.',
          onRetry: () => context.read<AreaProvider>().fetchAreas(),
        );
      case LoadStatus.loaded:
        if (provider.areas.isEmpty) {
          return _EmptyState(onCreate: _createSpace);
        }
        final filtered = _filtered(provider.areas);
        if (filtered.isEmpty) {
          return const Center(
            child: Text('No spaces found', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          );
        }
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => context.read<AreaProvider>().fetchAreas(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => SettingRowsCard(items: [
              SettingRowData(
                icon: Icons.layers_outlined,
                title: filtered[index].areaName,
                subtitle: (filtered[index].description?.isEmpty ?? true) ? 'No description' : filtered[index].description!,
                onTap: () => _openSpaceActions(filtered[index]),
              ),
            ]),
          ),
        );
    }
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
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
            const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 20),
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
            child: const Icon(Icons.layers_outlined, color: AppTheme.accent, size: 56),
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              children: [
                TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                TextSpan(text: 'Space', style: TextStyle(color: AppTheme.cancelled)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There is no space created till date. If you get confusion how does Space work in Hamro Restro. Following are tips about Space in Hamro Restro.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Create New Space',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Learn More',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 12),
          const _InfoRow(
            icon: Icons.crop_free,
            title: '1. Categorize Tables',
            description: 'As restaurant does have number of tables. Staff might get confused.',
          ),
          const SizedBox(height: 18),
          const _InfoRow(
            icon: Icons.smartphone_outlined,
            title: '2. Most Popular Place',
            description: 'Using space you will get data about how space are performing.',
          ),
          const SizedBox(height: 18),
          const _InfoRow(
            icon: Icons.description_outlined,
            title: '3. Order Management',
            description: 'Categorizing tables according to space, helps staffs to manage KOT',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _InfoRow({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5, decoration: TextDecoration.none)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
            ],
          ),
        ),
      ],
    );
  }
}
