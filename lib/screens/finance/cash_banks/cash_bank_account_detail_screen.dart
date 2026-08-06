import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'cash_bank_models.dart';
import 'cash_bank_widgets.dart';

/// Single reusable account-detail screen for every Cash & Banks account mode
/// (Counter, Bank Account, Owner's Account, ...). Every account opens this
/// same layout — only the account passed in changes what's shown, so no
/// per-account-type screen is duplicated.
class CashBankAccountDetailScreen extends StatelessWidget {
  final CashBankAccount account;

  const CashBankAccountDetailScreen({super.key, required this.account});

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
          account.name,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
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
            CashBankSummaryCard(
              initials: account.initials,
              name: account.name,
              balance: account.balance,
              statLabel: 'Account Type',
              statValue: account.accountType,
            ),
            const SizedBox(height: 20),
            const Text('Active Modes :', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
            const SizedBox(height: 12),
            for (final modeLabel in account.modeLabels) ...[
              CashBankListRow(initials: cashBankModeCode(modeLabel), label: modeLabel),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
