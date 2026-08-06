import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// "Account Summary" report reached from Reports > Accounting, matching the
/// reference design's flat list of every ledger account with its Group and
/// Parent classification and current balance. All balances are placeholder
/// "Rs 0" since no ledger data exists yet — only the structure and styling
/// need to match.
class AccountSummaryScreen extends StatelessWidget {
  const AccountSummaryScreen({super.key});

  static const _accounts = [
    _LedgerAccount('Stationery and Printing Expenses', group: 'Indirect Expenses', parent: 'Expense'),
    _LedgerAccount('kritika Mishra', group: 'Current Liability', parent: 'Liability'),
    _LedgerAccount('Counter', group: 'Current Assets', parent: 'Asset'),
    _LedgerAccount('Bank Account', group: 'Current Assets', parent: 'Asset'),
    _LedgerAccount("Owner's Account", group: 'Current Assets', parent: 'Asset'),
    _LedgerAccount('Cash Customer', group: 'Current Assets', parent: 'Asset'),
    _LedgerAccount('Adjustment', group: 'Indirect Expenses', parent: 'Expense'),
    _LedgerAccount('Gross Sales', group: 'Direct Income', parent: 'Income'),
    _LedgerAccount('Dish Discount', group: 'Direct Income', parent: 'Income'),
    _LedgerAccount('Loyalty Discount', group: 'Direct Income', parent: 'Income'),
    _LedgerAccount('Sales Discount', group: 'Direct Income', parent: 'Income'),
    _LedgerAccount('Sales Return', group: 'Direct Income', parent: 'Income'),
    _LedgerAccount('Service Charge', group: 'Indirect Income', parent: 'Income'),
    _LedgerAccount('Tips', group: 'Indirect Income', parent: 'Income'),
    _LedgerAccount('Round Off', group: 'Indirect Expenses', parent: 'Expense'),
    _LedgerAccount('Rental Income', group: 'Indirect Income', parent: 'Income'),
    _LedgerAccount('Sales Commission', group: 'Indirect Income', parent: 'Income'),
    _LedgerAccount('Bank Interest Income', group: 'Indirect Income', parent: 'Income'),
    _LedgerAccount('Purchase', group: 'Direct Expenses', parent: 'Expense'),
    _LedgerAccount('Purchase Return', group: 'Direct Expenses', parent: 'Expense'),
    _LedgerAccount('Rent Expenses', group: 'Indirect Expenses', parent: 'Expense'),
    _LedgerAccount('Salary Expenses', group: 'Indirect Expenses', parent: 'Expense'),
    _LedgerAccount('Sanitation Expenses', group: 'Indirect Expenses', parent: 'Expense'),
    _LedgerAccount('Direct Order', group: 'Current Assets', parent: 'Asset'),
    _LedgerAccount('Website', group: 'Current Assets', parent: 'Asset'),
    _LedgerAccount('Pathao Food', group: 'Current Assets', parent: 'Asset'),
    _LedgerAccount('FoodMandu', group: 'Current Assets', parent: 'Asset'),
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
          'Account Summary',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppTheme.textPrimary)),
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
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _accounts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _AccountSummaryCard(account: _accounts[index]),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
              child: Text(
                'Total Account Summary : ${_accounts.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerAccount {
  final String name;
  final String group;
  final String parent;
  const _LedgerAccount(this.name, {required this.group, required this.parent});
}

class _AccountSummaryCard extends StatelessWidget {
  final _LedgerAccount account;
  const _AccountSummaryCard({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15.5, decoration: TextDecoration.none)),
                const SizedBox(height: 4),
                Text('Group: ${account.group}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _LabelValue(label: 'Balance: ', value: 'Rs 0 Cr.'),
              const SizedBox(height: 6),
              _LabelValue(label: 'Parent: ', value: account.parent),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
        children: [
          TextSpan(text: label),
          TextSpan(text: value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
