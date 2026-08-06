import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/order_analytics_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/analytics_cards.dart';
import '../../widgets/common/select_daybook_sheet.dart';
import 'sales_analytics_screen.dart';
import 'top_selling_sub_menus_screen.dart';

/// Order dashboard content: filters, Live Order Status breakdown, Sales/Avg
/// Order/Order Served/KOT Taken stats, Sales by Sub Menu, and the top-selling
/// / guest-count breakdown lists. Used as the Analytics screen's "Order" tab.
/// Stats and status breakdown come live from [OrderAnalyticsProvider]
/// (backend: `GET /api/dashboard/order`); "Current number of guests", the
/// sub-menu/dish/table/ad-on/category breakdown lists stay static empty-state
/// cards since the backend doesn't return item-level data for them yet.
class OrderAnalyticsOverview extends StatefulWidget {
  const OrderAnalyticsOverview({super.key});

  @override
  State<OrderAnalyticsOverview> createState() => _OrderAnalyticsOverviewState();
}

class _OrderAnalyticsOverviewState extends State<OrderAnalyticsOverview> {
  String _dateFilter = 'Today';

  static String _rs(double v) => 'Rs ${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

  @override
  void initState() {
    super.initState();
    final provider = context.read<OrderAnalyticsProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchDashboard());
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAnalyticsProvider = context.watch<OrderAnalyticsProvider>();
    final dashboard = orderAnalyticsProvider.dashboard;

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

        if (orderAnalyticsProvider.status == LoadStatus.error)
          _ErrorCard(
            message: orderAnalyticsProvider.errorMessage ?? 'Something went wrong.',
            onRetry: () => context.read<OrderAnalyticsProvider>().fetchDashboard(),
          )
        else ...[
          AnalyticsLegendCard(
            title: 'Live Order Status',
            rows: [
              AnalyticsLegendRowData(
                color: AppTheme.completed,
                label: 'Completed order',
                value: dashboard == null ? '—' : '${dashboard.orderStatusBreakdown.completed}',
              ),
              AnalyticsLegendRowData(
                color: AppTheme.pending,
                label: 'Pending Order',
                value: dashboard == null ? '—' : '${dashboard.orderStatusBreakdown.pending}',
              ),
              AnalyticsLegendRowData(
                color: AppTheme.cancelled,
                label: 'Cancelled Order',
                value: dashboard == null ? '—' : '${dashboard.orderStatusBreakdown.cancelled}',
              ),
              const AnalyticsLegendRowData(label: 'Current number of guests', value: '0'),
            ],
          ),
          const SizedBox(height: 16),

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
              AnalyticsStatCard(title: 'Avg Order', value: dashboard == null ? '—' : _rs(dashboard.averageOrderAmount)),
              AnalyticsStatCard(title: 'Order Served', value: dashboard == null ? '—' : '${dashboard.ordersServed}'),
              AnalyticsStatCard(title: 'KOT Taken', value: dashboard == null ? '—' : '${dashboard.totalKot}'),
            ],
          ),
        ],
        const SizedBox(height: 16),

        _SalesBySubMenuCard(
          onViewAll: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TopSellingSubMenusScreen())),
        ),
        const SizedBox(height: 16),

        const AnalyticsEmptyListCard(title: 'Top Selling Dishes', emptyLabel: 'No Selling Dishes'),
        const SizedBox(height: 16),

        const AnalyticsEmptyListCard(title: 'Top Selling Table', emptyLabel: 'No Selling Tables'),
        const SizedBox(height: 16),

        const AnalyticsEmptyListCard(title: 'Guest Count Overview', emptyLabel: 'No guest count found'),
        const SizedBox(height: 16),

        const AnalyticsEmptyListCard(title: 'Top Selling Ad-Ons', emptyLabel: 'No Ad-Ons Sold Yet!'),
        const SizedBox(height: 16),

        const AnalyticsEmptyListCard(title: 'Top Selling Category', emptyLabel: 'No Categories Sold Yet!'),
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

// ---------------- Sales by Sub Menu ----------------

class _SalesBySubMenuCard extends StatelessWidget {
  final VoidCallback onViewAll;
  const _SalesBySubMenuCard({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Sales by Sub Menu',
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 18),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnalyticsFilterButton(label: 'View All', onTap: onViewAll),
            ],
          ),
          const SizedBox(height: 28),
          const Center(
            child: Text('No Sub Menu Sales Yet!', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
