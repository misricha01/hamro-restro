import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Shared building blocks for the Analytics module (Overview and Finance
/// tabs, plus the standalone Finance screen reached from Manage/Services),
/// so both surfaces render identical cards instead of duplicate UI.

const List<String> kAnalyticsDateFilterOptions = [
  'Life Time',
  'Today',
  'Yesterday',
  'This Week',
  'This Month',
  'Last Month',
  'This Year',
  'Custom Range',
];

class AnalyticsFilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const AnalyticsFilterButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class AnalyticsFilterDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const AnalyticsFilterDropdown({super.key, required this.label, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
      onSelected: onSelected,
      itemBuilder: (context) => options
          .map((o) => PopupMenuItem<String>(
                value: o,
                child: Text(o, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ))
          .toList(),
      child: IgnorePointer(
        child: AnalyticsFilterButton(label: label, onTap: () {}),
      ),
    );
  }
}

class AnalyticsStatCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;
  const AnalyticsStatCard({super.key, required this.title, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none)),
            Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 22, decoration: TextDecoration.none)),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 12, decoration: TextDecoration.none),
                children: [
                  TextSpan(text: '0 % ', style: TextStyle(color: AppTheme.completed, fontWeight: FontWeight.w600)),
                  TextSpan(text: 'More Than Yesterday', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsLegendRowData {
  final Color? color;
  final String label;
  final String value;
  const AnalyticsLegendRowData({this.color, required this.label, required this.value});
}

class AnalyticsLegendCard extends StatelessWidget {
  final String title;
  final List<AnalyticsLegendRowData> rows;
  final String? totalLabel;
  final String? totalValue;

  const AnalyticsLegendCard({super.key, required this.title, required this.rows, this.totalLabel, this.totalValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  rows[i].color != null
                      ? Container(width: 18, height: 18, decoration: BoxDecoration(color: rows[i].color, borderRadius: BorderRadius.circular(4)))
                      : const SizedBox(width: 18, height: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(rows[i].label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                  ),
                  Text(rows[i].value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ],
          if (totalLabel != null) ...[
            const Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Expanded(child: Text(totalLabel!, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5, decoration: TextDecoration.none))),
                  Text(totalValue!, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AnalyticsEmptyListCard extends StatelessWidget {
  final String title;
  final String emptyLabel;
  const AnalyticsEmptyListCard({super.key, required this.title, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          const SizedBox(height: 28),
          Center(
            child: Text(emptyLabel, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
