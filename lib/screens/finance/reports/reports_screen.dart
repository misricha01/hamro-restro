import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../daybook/daybook_screen.dart';
import '../transactions/transactions_screen.dart';
import 'account_summary_screen.dart';
import 'balance_sheet_screen.dart';
import 'chart_of_accounts_screen.dart';
import 'profit_loss_statement_screen.dart';
import 'report_detail_screen.dart';
import 'sales_master_report_screen.dart';
import 'trial_balance_screen.dart';

/// "Reports" screen reached from Manage > Finance > "4 more features" >
/// Reports, matching the reference design's Accounting / Sales Report /
/// Settings sections, each a two-column bulleted list of report names. Most
/// entries open the same reusable [ReportDetailScreen] — only the title
/// differs — but "Day Book" and "Transaction List" instead reopen the exact
/// same [DaybookScreen] / [TransactionsScreen] already used by Finance's
/// Daybook and Transactions rows, so those two stay a single implementation
/// shared between both modules rather than a separate Reports copy.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static void _openReport(BuildContext context, String title) {
    final Widget screen = switch (title) {
      'Day Book' => const DaybookScreen(),
      'Transaction List' => const TransactionsScreen(),
      'Profit Or Loss Statement' => const ProfitLossStatementScreen(),
      'Balance Sheet' => const BalanceSheetScreen(),
      'Account Summary' => const AccountSummaryScreen(),
      'Trial Balance' => const TrialBalanceScreen(),
      'Sales Master Report' => const SalesMasterReportScreen(),
      'Charts of Accounts' => const ChartOfAccountsScreen(),
      _ => ReportDetailScreen(title: title),
    };
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  static const _sections = [
    (
      'Accounting',
      ['Day Book', 'Profit Or Loss Statement', 'Balance Sheet', 'Transaction List', 'Account Summary', 'Trial Balance'],
    ),
    ('Sales Report', ['Sales Master Report']),
    ('Settings', ['Charts of Accounts']),
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
          'Reports',
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            for (final section in _sections) ...[
              _ReportSectionCard(title: section.$1, items: section.$2),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportSectionCard extends StatelessWidget {
  final String title;
  final List<String> items;
  const _ReportSectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(color: AppTheme.surface, border: Border.all(color: AppTheme.divider)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.cancelled.withValues(alpha: 0.12),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppTheme.cancelled, shape: BoxShape.circle),
                    child: const Icon(Icons.folder_outlined, color: Colors.white, size: 13),
                  ),
                  const SizedBox(width: 10),
                  Text(title, style: const TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.bold, fontSize: 15.5, decoration: TextDecoration.none)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final itemWidth = (constraints.maxWidth - spacing) / 2;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: 14,
                    children: items.map((item) {
                      return SizedBox(
                        width: itemWidth,
                        child: InkWell(
                          onTap: () => ReportsScreen._openReport(context, item),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(Icons.circle, color: AppTheme.textSecondary, size: 5),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(item, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
