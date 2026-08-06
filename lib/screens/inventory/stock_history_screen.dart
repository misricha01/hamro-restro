import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock/stock_model.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/stock_provider.dart';
import '../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;
import 'stock_history_filter_sheet.dart';

/// "Stock History" screen reached from Inventory > Stock History, sourced
/// live from [StockProvider.fetchStockHistory] (backend:
/// `GET /api/stock/history`). The "Type" filter has no matching query
/// param on this backend — it's applied client-side against the fetched
/// list instead (see [StockHistoryFilter]).
class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  StockHistoryFilter? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  void _fetch() {
    context.read<StockProvider>().fetchStockHistory(
      startDate: _filter?.startDate,
      endDate: _filter?.endDate,
      staffId: _filter?.staff?.id,
      stockId: _filter?.stock?.id,
      stockGroupId: _filter?.stockGroup?.id,
    );
  }

  Future<void> _openFilter() async {
    final result = await StockHistoryFilterSheet.show(context, initial: _filter);
    if (result != null) {
      setState(() => _filter = result);
      _fetch();
    }
  }

  List<StockTransaction> _applyTypeFilter(List<StockTransaction> history) {
    final type = _filter?.type;
    if (type == null || type == 'All') return history;
    return history.where((t) => t.type.toLowerCase() == type.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();

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
          'Stock History',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: _openFilter,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune, color: AppTheme.textPrimary, size: 18),
                        SizedBox(width: 8),
                        Text('Filter', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        SizedBox(width: 6),
                        Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(StockProvider provider) {
    switch (provider.historyStatus) {
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
                Text(
                  provider.historyErrorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _fetch,
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final entries = _applyTypeFilter(provider.history);
        if (entries.isEmpty) {
          return const InvoiceEmptyState(entityName: 'Stock History');
        }
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () async => _fetch(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _HistoryRow(transaction: entries[index]),
          ),
        );
    }
  }
}

class _HistoryRow extends StatelessWidget {
  final StockTransaction transaction;
  const _HistoryRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isReduce = transaction.type.toLowerCase() == 'reduce';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          Icon(isReduce ? Icons.arrow_downward : Icons.arrow_upward, color: isReduce ? AppTheme.cancelled : AppTheme.completed, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.type, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                if ((transaction.remark ?? '').isNotEmpty)
                  Text(transaction.remark!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${transaction.quantity}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              Text('Rs ${transaction.rate.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
            ],
          ),
        ],
      ),
    );
  }
}
