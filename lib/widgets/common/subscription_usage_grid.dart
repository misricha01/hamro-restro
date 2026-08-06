import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// One metric row in a [SubscriptionUsageGrid] (e.g. "Staff: 1/24").
class UsageMetric {
  final String label;
  final IconData icon;
  final Color color;
  final int used;
  final int total;
  const UsageMetric({required this.label, required this.icon, required this.color, required this.used, required this.total});
}

/// Restrox's standard subscription-usage metrics (Staff/Table/Customer/
/// Dish/Supplier/Addon/Space/Menuset), shared by Billing & Subscription and
/// the Reset/Delete Restaurant confirmation screens so the plan-usage
/// snapshot always looks identical wherever it appears.
const List<UsageMetric> kSubscriptionUsageMetrics = [
  UsageMetric(label: 'Staff', icon: Icons.manage_accounts_outlined, color: AppTheme.cancelled, used: 1, total: 24),
  UsageMetric(label: 'Table', icon: Icons.table_restaurant_outlined, color: Color(0xFF8E63CE), used: 3, total: 50),
  UsageMetric(label: 'Customer', icon: Icons.person_pin_outlined, color: AppTheme.cancelled, used: 0, total: 500),
  UsageMetric(label: 'Dish', icon: Icons.restaurant_outlined, color: AppTheme.accent, used: 6, total: 1000),
  UsageMetric(label: 'Supplier', icon: Icons.local_shipping_outlined, color: AppTheme.completed, used: 0, total: 500),
  UsageMetric(label: 'Addon', icon: Icons.card_giftcard_outlined, color: AppTheme.pending, used: 5, total: 250),
  UsageMetric(label: 'Space', icon: Icons.layers_outlined, color: AppTheme.accent, used: 0, total: 10),
  UsageMetric(label: 'Menuset', icon: Icons.menu_book_outlined, color: Color(0xFF8E63CE), used: 1, total: 5),
];

/// Two-column grid of usage metrics (icon + label, "used / total", progress
/// bar), reused by the Billing & Subscription hub and the Reset/Delete
/// Restaurant screens instead of each duplicating the layout.
class SubscriptionUsageGrid extends StatelessWidget {
  final List<UsageMetric> metrics;
  const SubscriptionUsageGrid({super.key, this.metrics = kSubscriptionUsageMetrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final cellWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: 18,
          children: metrics.map((m) {
            final ratio = m.total == 0 ? 0.0 : (m.used / m.total).clamp(0.0, 1.0);
            return SizedBox(
              width: cellWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: m.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Icon(m.icon, color: m.color, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(m.label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${m.used} / ${m.total}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: ratio, minHeight: 5, backgroundColor: AppTheme.divider, valueColor: AlwaysStoppedAnimation(m.color)),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
