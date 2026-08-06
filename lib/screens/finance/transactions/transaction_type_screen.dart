import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;

/// Generic single-list screen for transaction types that don't have a
/// dedicated screen elsewhere in the app (Payment In, Payment Out, Balance
/// Transfer). Reached from the Transactions Filter sheet's Type selection.
class TransactionTypeScreen extends StatelessWidget {
  final String entityName;
  const TransactionTypeScreen({super.key, required this.entityName});

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
        title: Text(
          entityName,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(child: InvoiceEmptyState(entityName: entityName)),
    );
  }
}
