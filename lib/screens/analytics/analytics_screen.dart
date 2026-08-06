import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/analytics_cards.dart';
import '../../widgets/common/select_daybook_sheet.dart';
import '../notification/notification_screen.dart';
import 'finance_analytics_screen.dart';
import 'finance_screen.dart';
import 'order_analytics_screen.dart';
import 'sales_analytics_screen.dart';

/// Analytics tab: Overview / Finance / Order breakdown of the restaurant's
/// performance. The Overview tab mirrors the reference design's summary
/// cards, sales chart and breakdown lists; Finance reuses [FinanceOverview]
/// (shared with the standalone Finance screen reached from Manage/Services);
/// Order reuses [OrderAnalyticsOverview] for the Live Order Status, order
/// stats and top-selling breakdown cards.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Analytics',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.notifications_none_outlined, color: AppTheme.textPrimary, size: 26),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: AppTheme.accent,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.accent,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
              unselectedLabelStyle: const TextStyle(decoration: TextDecoration.none),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Finance'),
                Tab(text: 'Order'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const _OverviewTab(),
                  const FinanceOverview(),
                  const OrderAnalyticsOverview(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Overview tab ----------------

/// Backed by [DashboardProvider] (`GET /api/dashboard`) for the
/// Sales/Purchase/Income stat cards; Expense stays static since the backend
/// doesn't return an expense figure yet, and the sales chart / breakdown
/// lists stay static empty-state cards since the backend doesn't return
/// item-level data for them yet.
class _OverviewTab extends StatefulWidget {
  const _OverviewTab();

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  String _dateFilter = 'Today';

  static String _rs(double v) => 'Rs ${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

  @override
  void initState() {
    super.initState();
    final provider = context.read<DashboardProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchOverview());
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final overview = dashboardProvider.overview;

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

        if (dashboardProvider.status == LoadStatus.error)
          _ErrorCard(
            message: dashboardProvider.errorMessage ?? 'Something went wrong.',
            onRetry: () => context.read<DashboardProvider>().fetchOverview(),
          )
        else
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
                value: overview == null ? '—' : _rs(overview.totalRevenue),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen())),
              ),
              AnalyticsStatCard(
                title: 'Purchase',
                value: overview == null ? '—' : _rs(overview.totalPurchase),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen(initialTabIndex: 1))),
              ),
              AnalyticsStatCard(
                title: 'Income',
                value: overview == null ? '—' : _rs(overview.totalIncome),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceAnalyticsScreen())),
              ),
              AnalyticsStatCard(
                title: 'Expense',
                value: 'Rs 0',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceAnalyticsScreen())),
              ),
            ],
          ),
        const SizedBox(height: 16),

        const _SalesOverviewCard(),
        const SizedBox(height: 16),

        const AnalyticsLegendCard(
          title: 'Sales Summary',
          rows: [
            AnalyticsLegendRowData(color: AppTheme.completed, label: 'Paid', value: 'Rs 0'),
            AnalyticsLegendRowData(color: AppTheme.cancelled, label: 'Unpaid Sales', value: 'Rs 0'),
          ],
          totalLabel: 'Total Sales :',
          totalValue: 'Rs 0',
        ),
        const SizedBox(height: 16),

        const AnalyticsLegendCard(
          title: 'Checkout Breakdown',
          rows: [
            AnalyticsLegendRowData(color: Color(0xFF7B68EE), label: 'Discount', value: 'Rs 0'),
            AnalyticsLegendRowData(color: Color(0xFF1A3FA0), label: 'Dish Discount', value: 'Rs 0'),
            AnalyticsLegendRowData(color: AppTheme.accent, label: 'Loyalty Discount', value: 'Rs 0'),
            AnalyticsLegendRowData(color: Color(0xFFA8C8FF), label: 'Service Charge', value: 'Rs 0'),
          ],
        ),
        const SizedBox(height: 16),

        _OrderServiceOverviewCard(onPrint: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing print...')));
        }),
        const SizedBox(height: 16),

        const AnalyticsEmptyListCard(title: 'Top Selling Dishes', emptyLabel: 'No Selling Dishes'),
        const SizedBox(height: 16),

        const AnalyticsEmptyListCard(title: 'Top Selling Table', emptyLabel: 'No Selling Tables'),
        const SizedBox(height: 16),

        const _DeliveryPlatformCard(),
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

// ---------------- Sales overview chart ----------------

class _SalesOverviewCard extends StatelessWidget {
  const _SalesOverviewCard();

  static const _yLabels = ['1.2', '1', '0.8', '0.6', '0.4', '0.2', '0'];
  static const _xLabels = ['0:00 AM', '4:00 AM', '8:00 AM', '12:00 PM', '4:00 PM', '8:00 PM'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('Sales Overview', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
              SizedBox(width: 6),
              Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _yLabels
                      .map((t) => Text(t, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, decoration: TextDecoration.none)))
                      .toList(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: CustomPaint(painter: _FlatLineChartPainter(), size: Size.infinite),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _xLabels
                  .map((t) => Text(t, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10.5, decoration: TextDecoration.none)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlatLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.divider
      ..strokeWidth = 1;

    const gridCount = 6;
    for (int i = 0; i < gridCount; i++) {
      final x = size.width * i / (gridCount - 1);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final axisPaint = Paint()
      ..color = AppTheme.divider
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 1), Offset(size.width, size.height - 1), axisPaint);

    final linePaint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height - 2)
      ..lineTo(size.width, size.height - 2);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------- Order Service Overview ----------------

class _OrderServiceOverviewCard extends StatelessWidget {
  final VoidCallback onPrint;
  const _OrderServiceOverviewCard({required this.onPrint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          const Expanded(
            child: Text('Order Service Overview', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          ),
          OutlinedButton.icon(
            onPressed: onPrint,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.divider),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.print_outlined, color: AppTheme.textPrimary, size: 18),
            label: const Text('Print', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
  }
}

// ---------------- Delivery Platform ----------------

class _DeliveryPlatformCard extends StatelessWidget {
  const _DeliveryPlatformCard();

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
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.moped_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery Platform', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15.5, decoration: TextDecoration.none)),
                    SizedBox(height: 2),
                    Text('Delivery Platform Summary', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'No delivery platform data available.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}
