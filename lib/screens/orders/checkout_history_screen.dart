import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/checkout_history/checkout_history_model.dart';
import '../../providers/checkout_history_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
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

/// "Checkout History" reached from Orders' 3-dot Actions menu, backed by
/// [CheckoutHistoryProvider] (`GET /api/checkout-history`) — a fuller
/// checkout audit trail (adds `tableCharge` on top of the usual bill
/// fields) than the plain `checkout` list, previously unused anywhere in
/// the app.
class CheckoutHistoryScreen extends StatefulWidget {
  const CheckoutHistoryScreen({super.key});

  @override
  State<CheckoutHistoryScreen> createState() => _CheckoutHistoryScreenState();
}

class _CheckoutHistoryScreenState extends State<CheckoutHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<CheckoutHistoryProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchHistory());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutHistoryProvider>();

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
        title: const Text('Checkout History', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(CheckoutHistoryProvider provider) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (provider.status == LoadStatus.error) {
      return _ErrorState(message: provider.errorMessage ?? 'Something went wrong.', onRetry: () => context.read<CheckoutHistoryProvider>().fetchHistory());
    }
    if (provider.history.isEmpty) {
      return const SettingEmptyState(title: 'Checkout History', subtitle: 'No checkout history found. Completed checkouts will show up here.');
    }
    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: () => context.read<CheckoutHistoryProvider>().fetchHistory(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.history.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _HistoryCard(entry: provider.history[index]),
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

class _HistoryCard extends StatelessWidget {
  final CheckoutHistoryEntry entry;
  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(entry.checkoutStatus);
    final status = entry.checkoutStatus;

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
                  entry.invoiceNumber ?? 'Checkout #${entry.checkoutId ?? entry.id}',
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
              if (entry.tableName != null) entry.tableName!,
              if (entry.customerName != null) entry.customerName!,
              _formatDate(entry.createdAt),
            ].join(' • '),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (entry.tableCharge > 0)
                Text('Table Charge: ${_rs(entry.tableCharge)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none))
              else
                const SizedBox.shrink(),
              Text(_rs(entry.totalAmount), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
            ],
          ),
        ],
      ),
    );
  }
}
