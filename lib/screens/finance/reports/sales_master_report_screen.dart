import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;

/// "Sales Master" report reached from Reports > Sales Report, matching the
/// reference design's Net Sales / Discount / Round Off stat row above an
/// empty state (no sales master data exists yet).
class SalesMasterReportScreen extends StatelessWidget {
  const SalesMasterReportScreen({super.key});

  static const _stats = [
    _SalesStat('Net Sales', 'Rs 0', AppTheme.completed),
    _SalesStat('Discount', 'Rs 0', AppTheme.pending),
    _SalesStat('Loyalty Discount', 'Rs 0', AppTheme.cancelled),
    _SalesStat('Service Charge', 'Rs 0', AppTheme.accent),
    _SalesStat('Round Off/ Tips', 'Rs 0', AppTheme.completed),
    _SalesStat('Tax', 'Rs 0', AppTheme.cancelled),
  ];

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
          'Sales Master',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_alt_outlined, color: AppTheme.textPrimary)),
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
            SizedBox(
              height: 116,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                itemCount: _stats.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _SalesStatCard(stat: _stats[index]),
              ),
            ),
            const Expanded(child: InvoiceEmptyState(entityName: 'Sales Master')),
          ],
        ),
      ),
    );
  }
}

class _SalesStat {
  final String label;
  final String value;
  final Color color;
  const _SalesStat(this.label, this.value, this.color);
}

class _SalesStatCard extends StatelessWidget {
  final _SalesStat stat;
  const _SalesStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(stat.label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          const SizedBox(height: 6),
          Text(stat.value, style: TextStyle(color: stat.color, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}
