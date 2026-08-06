import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/analytics_cards.dart';
import 'report_tree_widgets.dart';

/// "Profit Or Loss Statement" report reached from Reports > Accounting,
/// matching the reference design's collapsible Particulars/Amounts tree
/// (Direct Income > Sales/COGS/Direct Expenses, Gross Profit summary, Net
/// Income from Operating/Investing/Financing, down to Profit or Loss after
/// Taxes). All figures are placeholder "-" / "0.00%" since no ledger data
/// exists yet — only the structure and styling need to match.
class ProfitLossStatementScreen extends StatefulWidget {
  const ProfitLossStatementScreen({super.key});

  @override
  State<ProfitLossStatementScreen> createState() => _ProfitLossStatementScreenState();
}

class _ProfitLossStatementScreenState extends State<ProfitLossStatementScreen> {
  String _dateFilter = 'This Year';

  static const _directIncome = ReportTreeNode('Direct Income', children: [
    ReportTreeNode('Sales', children: [
      ReportTreeNode('Gross Sales'),
      ReportTreeNode('Dish Discount'),
      ReportTreeNode('Loyalty Discount'),
      ReportTreeNode('Sales Discount'),
      ReportTreeNode('Sales Return'),
    ]),
    ReportTreeNode('Cost of Goods Sales [COGS]', children: [
      ReportTreeNode('Opening Stock'),
    ]),
    ReportTreeNode('Direct Expenses', children: [
      ReportTreeNode('Purchase', children: [
        ReportTreeNode('Purchase'),
        ReportTreeNode('Purchase Return'),
      ]),
      ReportTreeNode('Closing Stock'),
    ]),
  ]);

  static const _netIncomeOperating = ReportTreeNode('Net Income from Operating and Other [NIO]', children: [
    ReportTreeNode('Operating and Other Incomes', children: [
      ReportTreeNode('Other Income', children: [
        ReportTreeNode('Service Charge'),
        ReportTreeNode('Tips'),
        ReportTreeNode('Rental Income'),
        ReportTreeNode('Sales Commission'),
        ReportTreeNode('Bank Interest Income'),
      ]),
    ]),
    ReportTreeNode('Operating and Other Expenses', children: [
      ReportTreeNode('Stationery and Printing Expenses'),
      ReportTreeNode('Adjustment'),
      ReportTreeNode('Rent Expenses'),
      ReportTreeNode('Salary Expenses'),
      ReportTreeNode('Sanitation Expenses'),
    ]),
  ]);

  static const _netIncomeInvesting = ReportTreeNode('Net Income from Investing [NII]', children: [
    ReportTreeNode('Investing Incomes'),
    ReportTreeNode('Investing Expenses'),
  ]);

  static const _netIncomeFinancing = ReportTreeNode('Net Income from Financing [NIF]', children: [
    ReportTreeNode('Financing Incomes'),
    ReportTreeNode('Financing Expenses'),
  ]);

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
          'Profit Or Loss Statement',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnalyticsFilterDropdown(
              label: _dateFilter,
              options: kAnalyticsDateFilterOptions,
              onSelected: (v) => setState(() => _dateFilter = v),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const ReportParticularsHeader(),
            const ReportTreeRow(node: _directIncome),
            const ReportStatRow(label: 'Gross Profit or Loss', value: '-'),
            const ReportStatRow(label: 'Gross Margin', value: '0.00%'),
            const ReportTreeRow(node: _netIncomeOperating),
            const ReportStatRow(label: 'Operating Profit or Loss [OP]', value: '-'),
            const ReportTreeRow(node: _netIncomeInvesting),
            const ReportStatRow(label: 'Profit or Loss Before Financing & Taxes [PBFT]', value: '-'),
            const ReportTreeRow(node: _netIncomeFinancing),
            const ReportStatRow(label: 'Profit or Loss Before Taxes [PBT]', value: '-'),
            const ReportStatRow(label: 'Net Income from Taxes [NIT]', value: '-', highlighted: false),
            const ReportStatRow(label: 'Profit or Loss after Taxes [PAT]', value: '-'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
