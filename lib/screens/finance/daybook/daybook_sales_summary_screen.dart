import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../analytics/sales_analytics_screen.dart' show SalesInvoiceTab, PurchaseBillsTab;

/// "Sales Summary" screen reached from the Daybook screen's top-right
/// button. Shows Sales Invoice / Purchase Bills tabs, reusing the same
/// [SalesInvoiceTab]/[PurchaseBillsTab] widgets (backed by
/// [SalesTransactionProvider]/[PurchaseBillProvider]) as the Analytics
/// "Sales & Purchase" screen.
class DaybookSalesSummaryScreen extends StatefulWidget {
  const DaybookSalesSummaryScreen({super.key});

  @override
  State<DaybookSalesSummaryScreen> createState() => _DaybookSalesSummaryScreenState();
}

class _DaybookSalesSummaryScreenState extends State<DaybookSalesSummaryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Sales Summary',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
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
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.accent,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.accent,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
              unselectedLabelStyle: const TextStyle(decoration: TextDecoration.none),
              tabs: const [Tab(text: 'Sales Invoice'), Tab(text: 'Purchase Bills')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  SalesInvoiceTab(),
                  PurchaseBillsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
