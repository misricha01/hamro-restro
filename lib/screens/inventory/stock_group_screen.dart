import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock/stock_group_model.dart';
import '../../data/repositories/stock_group_repository.dart' show StockGroupStats;
import '../../providers/stock_group_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../finance/reports/report_tree_widgets.dart' show ReportParticularsHeader;
import 'add_stock_group_screen.dart';
import 'stock_group_detail_sheet.dart';

/// "Stock Group" screen reached from Inventory > Stock Group, sourced live
/// from [StockGroupProvider] (backend: `/api/stock-group`), mirroring the
/// loading/error/empty/loaded pattern used by [ManageCategoriesScreen].
/// "No of Item" per row is derived from [StockProvider]'s own list rather
/// than a dedicated endpoint.
class StockGroupScreen extends StatefulWidget {
  const StockGroupScreen({super.key});

  @override
  State<StockGroupScreen> createState() => _StockGroupScreenState();
}

class _StockGroupScreenState extends State<StockGroupScreen> {
  @override
  void initState() {
    super.initState();
    final groupProvider = context.read<StockGroupProvider>();
    final stockProvider = context.read<StockProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (groupProvider.status == LoadStatus.idle) groupProvider.fetchStockGroups();
      if (stockProvider.status == LoadStatus.idle) stockProvider.fetchStocks();
      if (groupProvider.stockGroupStatsStatus == LoadStatus.idle) groupProvider.fetchStockGroupStats();
    });
  }

  Future<void> _addStockGroup() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddStockGroupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<StockGroupProvider>();

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
          'Stock Group',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (groupProvider.stockGroupStatsStatus == LoadStatus.loaded && groupProvider.stockGroupStats != null)
              _StatsSummary(stats: groupProvider.stockGroupStats!),
            const ReportParticularsHeader(leftLabel: 'Group Name', rightLabel: 'No of Item'),
            Expanded(child: _buildBody(groupProvider)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _addStockGroup,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Add New Stock Group', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(StockGroupProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(message: provider.errorMessage ?? 'Something went wrong.', onRetry: () => provider.fetchStockGroups());
      case LoadStatus.loaded:
        if (provider.groups.isEmpty) {
          return _EmptyState(onCreate: _addStockGroup);
        }
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => provider.fetchStockGroups(),
          child: Consumer<StockProvider>(
            builder: (context, stockProvider, _) {
              return ListView.separated(
                itemCount: provider.groups.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.divider),
                itemBuilder: (context, index) {
                  final group = provider.groups[index];
                  final itemCount = stockProvider.stocks.where((s) => s.stockGroupId == group.id).length;
                  return _StockGroupRow(
                    group: group,
                    itemCount: itemCount,
                    onTap: () => StockGroupDetailSheet.show(context, group: group, itemCount: itemCount),
                  );
                },
              );
            },
          ),
        );
    }
  }
}

class _StatsSummary extends StatelessWidget {
  final StockGroupStats stats;
  const _StatsSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    final parts = <String>['Total Stock: ${stats.totalGroupStock}'];
    if (stats.highestStockValue != null) parts.add('Highest Value: Rs ${stats.highestStockValue}');
    if (stats.groupWithMostItemName != null) parts.add('Most Items: ${stats.groupWithMostItemName}');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppTheme.surface,
      child: Text(
        parts.join('   |   '),
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
      ),
    );
  }
}

class _StockGroupRow extends StatelessWidget {
  final StockGroup group;
  final int itemCount;
  final VoidCallback onTap;
  const _StockGroupRow({required this.group, required this.itemCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.groupName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15.5, decoration: TextDecoration.none)),
                  if ((group.groupDescription ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(group.groupDescription!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('$itemCount', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
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
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
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
            child: const Icon(Icons.category_outlined, color: AppTheme.accent, size: 56),
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              children: [
                TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                TextSpan(text: 'Stock Group', style: TextStyle(color: AppTheme.cancelled)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There is no stock group created till date. Stock groups help you categorize your inventory.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Create New Stock Group', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
            ),
          ),
        ],
      ),
    );
  }
}
