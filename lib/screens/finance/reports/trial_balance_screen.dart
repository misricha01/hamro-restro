import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'report_tree_widgets.dart';

/// "Trial Balance" report reached from Reports > Accounting, matching the
/// reference design's collapsible Accounts/Amount tree — every ledger
/// account grouped under Expense, Liability, Asset, Income and Equity, down
/// to the Difference total. All figures are placeholder "Rs 0 Dr." since no
/// ledger data exists yet — only the structure and styling need to match.
class TrialBalanceScreen extends StatelessWidget {
  const TrialBalanceScreen({super.key});

  static const _value = 'Rs 0 Dr.';

  static const _expense = ReportTreeNode('Expense', value: _value, children: [
    ReportTreeNode('Indirect Expenses', value: _value, children: [
      ReportTreeNode('Stationery and Printing Expenses', value: _value),
      ReportTreeNode('Adjustment', value: _value),
      ReportTreeNode('Round Off', value: _value),
      ReportTreeNode('Rent Expenses', value: _value),
      ReportTreeNode('Salary Expenses', value: _value),
      ReportTreeNode('Sanitation Expenses', value: _value),
    ]),
    ReportTreeNode('Direct Expenses', value: _value, children: [
      ReportTreeNode('Purchase', value: _value, children: [
        ReportTreeNode('Purchase', value: _value),
        ReportTreeNode('Purchase Return', value: _value),
      ]),
    ]),
  ]);

  static const _liability = ReportTreeNode('Liability', value: _value, children: [
    ReportTreeNode('Current Liability', value: _value, children: [
      ReportTreeNode('Staff Account', value: _value, children: [
        ReportTreeNode('kritika Mishra', value: _value),
      ]),
    ]),
  ]);

  static const _asset = ReportTreeNode('Asset', value: _value, children: [
    ReportTreeNode('Current Assets', value: _value, children: [
      ReportTreeNode('Cash and Bank', value: _value, children: [
        ReportTreeNode('Counter', value: _value),
        ReportTreeNode('Bank Account', value: _value),
        ReportTreeNode("Owner's Account", value: _value),
      ]),
      ReportTreeNode('Customer Receivables', value: _value, children: [
        ReportTreeNode('Cash Customer', value: _value),
        ReportTreeNode('Direct Order', value: _value),
        ReportTreeNode('Website', value: _value),
        ReportTreeNode('Pathao Food', value: _value),
        ReportTreeNode('FoodMandu', value: _value),
      ]),
      ReportTreeNode('Inventory', value: _value, children: [
        ReportTreeNode('Opening Stock', value: _value),
      ]),
    ]),
  ]);

  static const _income = ReportTreeNode('Income', value: _value, children: [
    ReportTreeNode('Direct Income', value: _value, children: [
      ReportTreeNode('Sales', value: _value, children: [
        ReportTreeNode('Gross Sales', value: _value),
        ReportTreeNode('Dish Discount', value: _value),
        ReportTreeNode('Loyalty Discount', value: _value),
        ReportTreeNode('Sales Discount', value: _value),
        ReportTreeNode('Sales Return', value: _value),
      ]),
    ]),
    ReportTreeNode('Indirect Income', value: _value, children: [
      ReportTreeNode('Other Income', value: _value, children: [
        ReportTreeNode('Service Charge', value: _value),
        ReportTreeNode('Tips', value: _value),
        ReportTreeNode('Rental Income', value: _value),
        ReportTreeNode('Sales Commission', value: _value),
        ReportTreeNode('Bank Interest Income', value: _value),
      ]),
    ]),
  ]);

  static const _equity = ReportTreeNode('Equity', value: _value, initiallyExpanded: false, children: [
    ReportTreeNode('Capital', value: _value),
    ReportTreeNode('Reserve and Surplus', value: _value, children: [
      ReportTreeNode('Accumulated Profit/Loss', value: _value),
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
          'Trial Balance',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_alt_outlined, color: AppTheme.textPrimary)),
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
          children: [
            const ReportParticularsHeader(leftLabel: 'Accounts', rightLabel: 'Amount', showSortIcons: true),
            const ReportTreeRow(node: _expense),
            const ReportTreeRow(node: _liability),
            const ReportTreeRow(node: _asset),
            const ReportTreeRow(node: _income),
            const ReportTreeRow(node: _equity),
            const ReportStatRow(label: 'Difference', value: 'Rs 0 Cr.'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
