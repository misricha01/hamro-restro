import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/finance/finance_dashboard_model.dart';
import '../../providers/finance_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/analytics_cards.dart';
import '../../widgets/common/select_daybook_sheet.dart';
import 'finance_analytics_screen.dart';
import 'sales_analytics_screen.dart';

/// Finance dashboard content: filters, Sales/Purchase/Income/Expense stats,
/// Sales Summary and the staff/customer/payment/transaction breakdown lists.
/// Shared between the Analytics screen's "Finance" tab and the standalone
/// [FinanceScreen] reached from Manage > Services. Stats, Payment Methods and
/// Transaction History come live from [FinanceProvider] (backend:
/// `GET /api/dashboard/finance`); the staff/customer lists stay static
/// empty-state cards since the backend doesn't return item-level data for
/// them yet.
class FinanceOverview extends StatefulWidget {
  const FinanceOverview({super.key});

  @override
  State<FinanceOverview> createState() => _FinanceOverviewState();
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

String _rs(double v) => 'Rs ${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

class _FinanceOverviewState extends State<FinanceOverview> {
  String _dateFilter = 'Today';

  @override
  void initState() {
    super.initState();
    final provider = context.read<FinanceProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchDashboard());
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<FinanceProvider>();
    final dashboard = financeProvider.dashboard;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            AnalyticsFilterDropdown(
              label: _dateFilter,
              options: kAnalyticsDateFilterOptions,
              onSelected: (v) => setState(() => _dateFilter = v),
            ),
            const SizedBox(width: 12),
            AnalyticsFilterButton(label: 'Daybook: All', onTap: () => SelectDaybookSheet.show(context)),
          ],
        ),
        const SizedBox(height: 16),

        if (financeProvider.status == LoadStatus.error)
          _ErrorCard(
            message: financeProvider.errorMessage ?? 'Something went wrong.',
            onRetry: () => context.read<FinanceProvider>().fetchDashboard(),
          )
        else ...[
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              AnalyticsStatCard(
                title: 'Sales',
                value: dashboard == null ? '—' : _rs(dashboard.totalSales),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen())),
              ),
              AnalyticsStatCard(
                title: 'Purchase',
                value: dashboard == null ? '—' : _rs(dashboard.totalPurchase),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen(initialTabIndex: 1))),
              ),
              AnalyticsStatCard(
                title: 'Income',
                value: dashboard == null ? '—' : _rs(dashboard.totalIncome),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceAnalyticsScreen())),
              ),
              AnalyticsStatCard(
                title: 'Expense',
                value: dashboard == null ? '—' : _rs(dashboard.totalExpenses),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceAnalyticsScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),

          AnalyticsLegendCard(
            title: 'Sales Summary',
            rows: [
              AnalyticsLegendRowData(color: AppTheme.completed, label: 'Paid', value: dashboard == null ? '—' : _rs(dashboard.paid.totalAmount)),
              AnalyticsLegendRowData(color: AppTheme.cancelled, label: 'Unpaid Sales', value: dashboard == null ? '—' : _rs(dashboard.unpaid.totalAmount)),
            ],
            totalLabel: 'Total Sales :',
            totalValue: dashboard == null ? '—' : _rs(dashboard.paid.totalAmount + dashboard.unpaid.totalAmount),
          ),
        ],
        const SizedBox(height: 16),

        const AnalyticsEmptyListCard(title: 'Sales By Staff', emptyLabel: 'No Orders By Staffs Yet!'),
        const SizedBox(height: 16),

        const AnalyticsEmptyListCard(title: 'Top Customers By Spend', emptyLabel: 'No Customer Orders Yet!'),
        const SizedBox(height: 16),

        _PaymentMethodsCard(methods: dashboard?.topPaymentMethods ?? const []),
        const SizedBox(height: 16),

        _TransactionHistoryCard(payments: dashboard?.recentPayments ?? const []),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(
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
    );
  }
}

class _PaymentMethodsCard extends StatelessWidget {
  final List<PaymentMethodSummary> methods;
  const _PaymentMethodsCard({required this.methods});

  @override
  Widget build(BuildContext context) {
    if (methods.isEmpty) {
      return const AnalyticsEmptyListCard(title: 'Payment Methods', emptyLabel: 'No Payment Methods Used Yet!');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Methods', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          for (int i = 0; i < methods.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(methods[i].paymentMethodName, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                  ),
                  Text('${methods[i].totalTransactions} txns', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                  const SizedBox(width: 10),
                  Text(_rs(methods[i].totalAmount), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionHistoryCard extends StatelessWidget {
  final List<RecentPayment> payments;
  const _TransactionHistoryCard({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const AnalyticsEmptyListCard(title: 'Transaction History', emptyLabel: 'No Transaction found');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaction History', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          for (int i = 0; i < payments.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(payments[i].invoiceNumber, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                        Text(
                          [
                            if (payments[i].tableName != null) payments[i].tableName!,
                            payments[i].paymentMethodName,
                            _formatDate(payments[i].createdAt),
                          ].join(' • '),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                  ),
                  Text(_rs(payments[i].amount), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Standalone "Finance" screen reached from Manage > Services, wrapping
/// [FinanceOverview] with its own app bar so it can be pushed outside the
/// Analytics tab bar.
class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

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
          'Finance',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: const SafeArea(child: FinanceOverview()),
    );
  }
}
