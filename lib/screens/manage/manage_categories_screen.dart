import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/category/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/edit_delete_actions_sheet.dart';
import '../create_dish/add_dish_screen.dart' show AddCategoryScreen;

/// Category list for the Manage screen. Sourced live from [CategoryProvider]
/// (backend: `menu-category`), mirroring the loading/error/empty/loaded
/// pattern used by [ManageSpaceScreen] for Space.
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<CategoryProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchCategories());
    }
    if (provider.categoryStatsStatus == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchCategoryStats());
    }
  }

  Future<void> _addCategory() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCategoryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

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
          'Category',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _addCategory,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.divider),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: AppTheme.accent),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(categoryProvider)),
            if (categoryProvider.status == LoadStatus.loaded && categoryProvider.categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Category : ${categoryProvider.categories.length}',
                      style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none),
                    ),
                    if (categoryProvider.categoryStatsStatus == LoadStatus.loaded &&
                        categoryProvider.categoryStats != null &&
                        categoryProvider.categoryStats!.topSoldName != null)
                      Text(
                        'Top Sold: ${categoryProvider.categoryStats!.topSoldName} (${categoryProvider.categoryStats!.topSoldOrders ?? 0} orders)',
                        style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CategoryProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(
          message: provider.errorMessage ?? 'Something went wrong.',
          onRetry: () => context.read<CategoryProvider>().fetchCategories(),
        );
      case LoadStatus.loaded:
        if (provider.categories.isEmpty) {
          return _EmptyState(onCreate: _addCategory);
        }
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => context.read<CategoryProvider>().fetchCategories(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _CategoryRow(category: provider.categories[index]),
          ),
        );
    }
  }
}

class _CategoryRow extends StatelessWidget {
  final MenuCategory category;
  const _CategoryRow({required this.category});

  Future<void> _openActions(BuildContext context) async {
    final action = await EditDeleteActionsSheet.show(context, title: category.categoryName);
    if (!context.mounted) return;
    if (action == 'edit') {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => AddCategoryScreen(existingCategory: category)));
    } else if (action == 'delete') {
      await _confirmDelete(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Category', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          'Remove "${category.categoryName}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<CategoryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteCategory(category.id);
    if (!success && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to delete category')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openActions(context),
      borderRadius: BorderRadius.circular(12),
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
              child: const Icon(Icons.dashboard_outlined, color: AppTheme.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.categoryName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none),
              ),
            ),
            const Icon(Icons.more_vert, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
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
            child: const Icon(Icons.dashboard_outlined, color: AppTheme.accent, size: 56),
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              children: [
                TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                TextSpan(text: 'Category', style: TextStyle(color: AppTheme.cancelled)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There is no category created till date. Categories help you group dishes on the menu.',
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
                'Create New Category',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
