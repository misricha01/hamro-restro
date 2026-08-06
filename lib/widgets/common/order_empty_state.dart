import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'add_new_order_sheet.dart' show AddNewOrderSheet;

/// One "how orders get created" hint row shown below the Add New Order
/// button on the KOT tab's empty state (e.g. "Scan by Customer").
class OrderCreationHint {
  final IconData icon;
  final String title;
  final String description;
  const OrderCreationHint({required this.icon, required this.title, required this.description});
}

/// Shared "No Order/KOT Yet" empty state used by the Orders screen's Active
/// and KOT tabs — icon + colored headline + subtitle + "Add New Order"
/// button (opening the shared [AddNewOrderSheet]), with optional extra
/// content (creation hints, "View Saved Order" link, ...) appended below.
class OrderEmptyState extends StatelessWidget {
  final String accentTitle;
  final String titleSuffix;
  final String subtitle;
  final Future<void> Function() onRefresh;
  final List<Widget> extraContent;

  const OrderEmptyState({
    super.key,
    required this.accentTitle,
    this.titleSuffix = '',
    required this.subtitle,
    required this.onRefresh,
    this.extraContent = const [],
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 60),
          Icon(Icons.receipt_long_outlined, size: 120, color: AppTheme.accent.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none),
              children: [
                const TextSpan(text: 'No '),
                TextSpan(text: accentTitle, style: const TextStyle(color: AppTheme.accent)),
                TextSpan(text: titleSuffix),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => AddNewOrderSheet.show(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Add New Order', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  SizedBox(width: 8),
                  VerticalDivider(color: Colors.white54, thickness: 1),
                  SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...extraContent,
        ],
      ),
    );
  }
}

/// One row inside the KOT tab's "how to get orders in" hint list.
class OrderCreationHintRow extends StatelessWidget {
  final OrderCreationHint hint;
  const OrderCreationHintRow({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(hint.icon, color: AppTheme.textPrimary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hint.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5, decoration: TextDecoration.none)),
                const SizedBox(height: 3),
                Text(hint.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, height: 1.4, decoration: TextDecoration.none)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
