import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/sales_purchase/sales_transaction_model.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/sales_transaction_provider.dart';
import '../../widgets/common/setting_empty_state.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

String _rs(double v) => 'Rs ${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'completed':
      return AppTheme.completed;
    case 'partial':
      return AppTheme.pending;
    default:
      return AppTheme.cancelled;
  }
}

/// "Recent Transactions" reached from Orders' 3-dot Actions menu, backed by
/// [SalesTransactionProvider] (`GET /api/sales-transaction`) — the same data
/// already powering the Analytics screen's "Sales Invoice" tab.
class RecentTransactionsScreen extends StatefulWidget {
  const RecentTransactionsScreen({super.key});

  @override
  State<RecentTransactionsScreen> createState() => _RecentTransactionsScreenState();
}

class _RecentTransactionsScreenState extends State<RecentTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<SalesTransactionProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchTransactions());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesTransactionProvider>();

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
        title: const Text('Recent Transactions', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppTheme.textPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_alt_outlined, color: AppTheme.textPrimary), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(SalesTransactionProvider provider) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (provider.status == LoadStatus.error) {
      return _ErrorState(
        message: provider.errorMessage ?? 'Something went wrong.',
        onRetry: () => context.read<SalesTransactionProvider>().fetchTransactions(),
      );
    }
    if (provider.transactions.isEmpty) {
      return const SettingEmptyState(title: 'Transactions', subtitle: 'No Recent Transactions found. Payments taken on orders will show up here.');
    }
    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: () => context.read<SalesTransactionProvider>().fetchTransactions(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _TransactionCard(transaction: provider.transactions[index]),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: AppTheme.textSecondary),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
            const SizedBox(height: 12),
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

class _TransactionCard extends StatelessWidget {
  final SalesTransaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(transaction.checkoutStatus);
    final status = transaction.checkoutStatus;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction.invoiceNumber,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  status.isEmpty ? '—' : '${status[0].toUpperCase()}${status.substring(1)}',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (transaction.tableName != null) transaction.tableName!,
              if (transaction.customerName != null) transaction.customerName!,
              _formatDate(transaction.createdAt),
            ].join(' • '),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${transaction.noOfGuests} Guest${transaction.noOfGuests == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
              Text(_rs(transaction.totalAmount), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
            ],
          ),
          if (transaction.dueAmount > 0) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Due: ${_rs(transaction.dueAmount)}', style: const TextStyle(color: AppTheme.cancelled, fontSize: 12.5, decoration: TextDecoration.none)),
            ),
          ],
        ],
      ),
    );
  }
}
