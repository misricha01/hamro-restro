import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/analytics_cards.dart';
import 'report_tree_widgets.dart';

/// "Balance Sheet" report reached from Reports > Accounting, matching the
/// reference design's collapsible Particulars/Amounts tree (Assets >
/// Current/Non Current, Liability > Current/Non Current, Equity, down to
/// the Difference total). All figures are placeholder "Rs 0" / "0" since no
/// ledger data exists yet — only the structure and styling need to match.
class BalanceSheetScreen extends StatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  State<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends State<BalanceSheetScreen> {
  String _dateFilter = 'This Year';

  static const _assets = ReportTreeNode('Assets', value: 'Rs 0', children: [
    ReportTreeNode('Current Assets', value: 'Rs 0', children: [
      ReportTreeNode('Cash and Bank', value: '0', children: [
        ReportTreeNode('Counter', value: '0'),
        ReportTreeNode('Bank Account', value: '0'),
        ReportTreeNode("Owner's Account", value: '0'),
      ]),
      ReportTreeNode('Customer Receivables', value: '0', children: [
        ReportTreeNode('Cash Customer', value: '0'),
        ReportTreeNode('Direct Order', value: '0'),
        ReportTreeNode('Website', value: '0'),
        ReportTreeNode('Pathao Food', value: '0'),
        ReportTreeNode('FoodMandu', value: '0'),
      ]),
    ]),
    ReportTreeNode('Non Current Assets', value: 'Rs 0'),
  ]);

  static const _liability = ReportTreeNode('Liability', value: 'Rs 0', children: [
    ReportTreeNode('Current Liability', value: 'Rs 0', children: [
      ReportTreeNode('Staff Account', value: '0', children: [
        ReportTreeNode('kritika Mishra', value: '0'),
      ]),
    ]),
    ReportTreeNode('Non Current Liability', value: 'Rs 0'),
  ]);

  static const _equity = ReportTreeNode('Equity', value: 'Rs 0', children: [
    ReportTreeNode('Capital', value: 'Rs 0'),
    ReportTreeNode('Reserve and Surplus', value: 'Rs 0', children: [
      ReportTreeNode('Accumulated Profit/Loss', value: '0'),
    ]),
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
          'Balance Sheet',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
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
            const ReportTreeRow(node: _assets),
            const ReportTreeRow(node: _liability),
            const ReportTreeRow(node: _equity),
            const ReportStatRow(label: 'Difference', value: '0'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
