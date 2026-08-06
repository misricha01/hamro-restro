import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/analytics_cards.dart';
import '../../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;
import 'payment_entry_screen.dart';

/// "Payments" screen reached from Manage > Finance > "4 more features" >
/// Payments. Lists Payment In / Payment Out entries with a date filter,
/// matching the reference design — reusing [AnalyticsFilterDropdown] and
/// [InvoiceEmptyState] instead of duplicating the Analytics module's filter
/// and empty-state UI.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _dateFilter = 'This Month';

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
          'Payments',
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
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  AnalyticsFilterDropdown(
                    label: _dateFilter,
                    options: kAnalyticsDateFilterOptions,
                    onSelected: (v) => setState(() => _dateFilter = v),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: InvoiceEmptyState(entityName: 'Payments'),
            ),
            _PaymentInOutBar(
              onPaymentIn: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentEntryScreen(isPaymentIn: true))),
              onPaymentOut: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentEntryScreen(isPaymentIn: false))),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom bar with the "Payment In" / "Payment Out" CTAs shown side by side,
/// matching the reference design's tinted green / red buttons — reusing the
/// same tinted-pill styling as [ClearFilterButton] rather than introducing a
/// new button treatment.
class _PaymentInOutBar extends StatelessWidget {
  final VoidCallback onPaymentIn;
  final VoidCallback onPaymentOut;
  const _PaymentInOutBar({required this.onPaymentIn, required this.onPaymentOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
      child: Row(
        children: [
          Expanded(
            child: _TintedActionButton(
              label: 'Payment In',
              icon: Icons.trending_up,
              color: AppTheme.completed,
              onTap: onPaymentIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TintedActionButton(
              label: 'Payment Out',
              icon: Icons.south_west,
              color: AppTheme.cancelled,
              onTap: onPaymentOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _TintedActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TintedActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}
