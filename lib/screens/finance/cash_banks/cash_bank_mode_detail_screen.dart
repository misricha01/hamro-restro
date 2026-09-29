import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/payment_method/payment_method_model.dart';
import '../../../providers/payment_method_provider.dart';
import 'add_payment_mode_screen.dart';
import 'cash_bank_models.dart';
import 'cash_bank_widgets.dart';

enum _ModeMenuAction { edit, delete }

/// Payment mode detail screen for every Cash & Banks Modes tab row
/// (backend: `/api/payment-method`). The "..." menu's Edit/Delete actions
/// call [PaymentMethodProvider.updatePaymentMethod]/[deletePaymentMethod].
class CashBankModeDetailScreen extends StatefulWidget {
  final PaymentMode mode;

  const CashBankModeDetailScreen({super.key, required this.mode});

  @override
  State<CashBankModeDetailScreen> createState() => _CashBankModeDetailScreenState();
}

class _CashBankModeDetailScreenState extends State<CashBankModeDetailScreen> {
  late PaymentMode _mode = widget.mode;

  Future<void> _edit() async {
    final updated = await Navigator.push<PaymentMode>(context, MaterialPageRoute(builder: (context) => AddPaymentModeScreen(initial: _mode)));
    if (updated != null) setState(() => _mode = updated);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Payment Mode', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          'Delete "${_mode.name}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<PaymentMethodProvider>();
    final ok = await provider.deletePaymentMethod(_mode.id);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  void _handleMenuAction(_ModeMenuAction action) {
    switch (action) {
      case _ModeMenuAction.edit:
        _edit();
      case _ModeMenuAction.delete:
        _confirmDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeleting = context.watch<PaymentMethodProvider>().isDeleting;

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
        title: Text(
          _mode.name,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: isDeleting
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
                  )
                : PopupMenuButton<_ModeMenuAction>(
                    onSelected: _handleMenuAction,
                    color: AppTheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: _ModeMenuAction.edit, child: _MenuRow(icon: Icons.edit_outlined, label: 'Edit Mode')),
                      PopupMenuItem(value: _ModeMenuAction.delete, child: _MenuRow(icon: Icons.delete_outline, label: 'Delete Mode', color: AppTheme.cancelled)),
                    ],
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            CashBankSummaryCard(
              initials: cashBankModeCode(_mode.name),
              name: _mode.name,
              balance: 0,
              statLabel: 'Txn Quantity',
              statValue: '0',
            ),
            if ((_mode.remarks ?? '').isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Remarks', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
              const SizedBox(height: 8),
              Text(_mode.remarks!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuRow({required this.icon, required this.label, this.color = AppTheme.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
      ],
    );
  }
}
