import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/order_provider.dart' show LoadStatus;
import '../../../providers/purchase_bill_provider.dart';
import '../../../providers/sales_transaction_provider.dart';
import '../../analytics/finance_analytics_screen.dart';
import '../../analytics/sales_analytics_screen.dart';
import 'transaction_type_screen.dart';
import 'transactions_filter_sheet.dart';

String _rs(double v) => 'Rs ${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

/// "Transactions" screen reached from Finance > Transactions. Shows the
/// Sales/Purchase summary, a Filter trigger + active-filter chips, and the
/// transaction list (currently always empty, matching the reference design).
/// Selecting a Type in the Filter sheet and applying it opens the matching
/// transaction-type screen.
///
/// The Sales/Purchase summary cards are backed by [SalesTransactionProvider]/
/// [PurchaseBillProvider] (the same data already powering the Analytics
/// "Sales Invoice"/"Purchase Bills" tabs); Income stays "Rs 0" since there's
/// no income endpoint yet.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionsFilter _filter = TransactionsFilter.initial();

  @override
  void initState() {
    super.initState();
    final salesProvider = context.read<SalesTransactionProvider>();
    final purchaseProvider = context.read<PurchaseBillProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (salesProvider.status == LoadStatus.idle) salesProvider.fetchTransactions();
      if (purchaseProvider.status == LoadStatus.idle) purchaseProvider.fetchBills();
    });
  }

  void _openFilter() {
    TransactionsFilterSheet.show(
      context,
      initial: _filter,
      onApply: (result) {
        setState(() => _filter = result);
        _navigateForType(result.type);
      },
    );
  }

  void _navigateForType(String type) {
    switch (type) {
      case 'Sales':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen()));
        break;
      case 'Sales Return':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen(initialTabIndex: 2)));
        break;
      case 'Purchase':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen(initialTabIndex: 1)));
        break;
      case 'Purchase Return':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen(initialTabIndex: 3)));
        break;
      case 'Income':
      case 'Expense':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceAnalyticsScreen()));
        break;
      case 'Payment In':
      case 'Payment Out':
      case 'Balance Transfer':
        Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionTypeScreen(entityName: type)));
        break;
      default:
        break;
    }
  }

  List<String> get _activeFilterChips {
    final chips = <String>[];
    if (_filter.type != 'All') chips.add(_filter.type);
    if (_filter.paymentStatus != 'All') chips.add(_filter.paymentStatus);
    if (_filter.paymentMode != 'All') chips.add(_filter.paymentMode);
    if (_filter.datePreset != 'This Year') chips.add(_filter.datePreset);
    return chips;
  }

  void _clearChip(String chip) {
    setState(() {
      if (chip == _filter.type) _filter = _filter.copyWith(type: 'All');
      if (chip == _filter.paymentStatus) _filter = _filter.copyWith(paymentStatus: 'All');
      if (chip == _filter.paymentMode) _filter = _filter.copyWith(paymentMode: 'All');
      if (chip == _filter.datePreset) {
        final d = TransactionsFilter.initial();
        _filter = _filter.copyWith(datePreset: d.datePreset, from: d.from, to: d.to);
      }
    });
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
          'Transactions',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppTheme.textPrimary),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _openFilter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune, color: AppTheme.textPrimary, size: 18),
                            SizedBox(width: 6),
                            Text('Filter', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 20),
                          ],
                        ),
                      ),
                    ),
                    for (final chip in _activeFilterChips) ...[
                      const SizedBox(width: 10),
                      _ActiveFilterChip(label: chip, onClear: () => _clearChip(chip)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Builder(builder: (context) {
              final salesTotal = context.watch<SalesTransactionProvider>().transactions.fold(0.0, (sum, t) => sum + t.totalAmount);
              final purchaseTotal = context.watch<PurchaseBillProvider>().bills.fold(0.0, (sum, b) => sum + b.amount);
              return SizedBox(
                height: 78,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _SummaryCard(label: 'Sales', value: _rs(salesTotal), color: AppTheme.completed),
                    const SizedBox(width: 12),
                    _SummaryCard(label: 'Purchase', value: _rs(purchaseTotal), color: AppTheme.cancelled),
                    const SizedBox(width: 12),
                    const _SummaryCard(label: 'Income', value: 'Rs 0', color: AppTheme.completed),
                  ],
                ),
              );
            }),
            const Expanded(child: InvoiceEmptyState(entityName: 'Transactions')),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, decoration: TextDecoration.none)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _ActiveFilterChip({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onClear,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cancelled.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.cancelled.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
            const SizedBox(width: 6),
            const Icon(Icons.close, color: AppTheme.cancelled, size: 15),
          ],
        ),
      ),
    );
  }
}
