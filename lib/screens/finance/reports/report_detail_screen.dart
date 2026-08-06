import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;

/// Single reusable report-detail screen for every entry in [ReportsScreen]
/// (Day Book, Balance Sheet, Account Summary, Profit Or Loss Statement,
/// Transaction List, Trial Balance, Sales Master Report, Charts of Accounts,
/// ...). Every report row opens this same layout — only the title passed in
/// changes what's shown, so none of the reports gets its own duplicated
/// screen.
class ReportDetailScreen extends StatelessWidget {
  final String title;

  const ReportDetailScreen({super.key, required this.title});

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
          title,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.print_outlined, color: AppTheme.textPrimary)),
        ],
      ),
      body: SafeArea(child: InvoiceEmptyState(entityName: title)),
    );
  }
}
