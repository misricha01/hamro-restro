import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../add_income_screen.dart';

/// "Chart of Accounts" screen reached from Reports > Settings, matching the
/// reference design's flat list of every account head with its Parent/Group
/// classification, plus an "Add New Account Head" action that opens
/// [AddAccountHeadScreen] in full-form mode (Parent, Group, Sub Group,
/// Opening Balance, Is Credit).
class ChartOfAccountsScreen extends StatefulWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  State<ChartOfAccountsScreen> createState() => _ChartOfAccountsScreenState();
}

class _ChartOfAccountsScreenState extends State<ChartOfAccountsScreen> {
  final List<_ChartAccount> _accounts = List.of(_seedAccounts);

  static const _seedAccounts = [
    _ChartAccount('Stationery and Printing Expenses', parent: 'Expense', group: 'Indirect Expenses'),
    _ChartAccount('kritika Mishra', parent: 'Liability', group: 'Current Liability', subGroup: 'Staff Account'),
    _ChartAccount('Counter', parent: 'Asset', group: 'Current Assets', subGroup: 'Cash and Bank'),
    _ChartAccount('Bank Account', parent: 'Asset', group: 'Current Assets', subGroup: 'Cash and Bank'),
    _ChartAccount("Owner's Account", parent: 'Asset', group: 'Current Assets', subGroup: 'Cash and Bank'),
    _ChartAccount('Cash Customer', parent: 'Asset', group: 'Current Assets', subGroup: 'Customer Receivables'),
    _ChartAccount('Adjustment', parent: 'Expense', group: 'Indirect Expenses'),
    _ChartAccount('Gross Sales', parent: 'Income', group: 'Direct Income', subGroup: 'Sales'),
    _ChartAccount('Dish Discount', parent: 'Income', group: 'Direct Income', subGroup: 'Sales'),
    _ChartAccount('Loyalty Discount', parent: 'Income', group: 'Direct Income', subGroup: 'Sales'),
    _ChartAccount('Sales Discount', parent: 'Income', group: 'Direct Income', subGroup: 'Sales'),
    _ChartAccount('Sales Return', parent: 'Income', group: 'Direct Income', subGroup: 'Sales'),
    _ChartAccount('Service Charge', parent: 'Income', group: 'Indirect Income', subGroup: 'Other Income'),
    _ChartAccount('Tips', parent: 'Income', group: 'Indirect Income', subGroup: 'Other Income'),
    _ChartAccount('Round Off', parent: 'Expense', group: 'Indirect Expenses'),
    _ChartAccount('Rental Income', parent: 'Income', group: 'Indirect Income', subGroup: 'Other Income'),
    _ChartAccount('Sales Commission', parent: 'Income', group: 'Indirect Income', subGroup: 'Other Income'),
    _ChartAccount('Bank Interest Income', parent: 'Income', group: 'Indirect Income', subGroup: 'Other Income'),
    _ChartAccount('Purchase', parent: 'Expense', group: 'Direct Expenses', subGroup: 'Purchase'),
    _ChartAccount('Purchase Return', parent: 'Expense', group: 'Direct Expenses', subGroup: 'Purchase'),
    _ChartAccount('Rent Expenses', parent: 'Expense', group: 'Indirect Expenses'),
    _ChartAccount('Salary Expenses', parent: 'Expense', group: 'Indirect Expenses'),
    _ChartAccount('Sanitation Expenses', parent: 'Expense', group: 'Indirect Expenses'),
    _ChartAccount('Direct Order', parent: 'Asset', group: 'Current Assets'),
    _ChartAccount('Website', parent: 'Asset', group: 'Current Assets'),
    _ChartAccount('Pathao Food', parent: 'Asset', group: 'Current Assets'),
    _ChartAccount('FoodMandu', parent: 'Asset', group: 'Current Assets'),
  ];

  Future<void> _addAccountHead() async {
    final result = await Navigator.push<AccountHeadFormResult>(
      context,
      MaterialPageRoute(builder: (context) => const AddAccountHeadScreen(fullForm: true)),
    );
    if (result != null && result.parent != null && result.group != null) {
      setState(() {
        _accounts.add(_ChartAccount(result.name, parent: result.parent!, group: result.group!, subGroup: result.subGroup));
      });
    }
  }

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
          'Chart of Accounts',
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
                itemBuilder: (context, index) => _ChartAccountCard(account: _accounts[index]),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
              child: Text(
                'Total Account Head : ${_accounts.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
              color: AppTheme.surface,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _addAccountHead,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Add New Account Head', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartAccount {
  final String name;
  final String parent;
  final String group;
  final String? subGroup;
  const _ChartAccount(this.name, {required this.parent, required this.group, this.subGroup});
}

class _ChartAccountCard extends StatelessWidget {
  final _ChartAccount account;
  const _ChartAccountCard({required this.account});

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
                if (account.subGroup != null) ...[
                  const SizedBox(height: 4),
                  Text(account.subGroup!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _LabelValue(label: 'Parent: ', value: account.parent),
              const SizedBox(height: 6),
              _LabelValue(label: 'Group: ', value: account.group),
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
