import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/setting_rows_card.dart';
import '../analytics/finance_analytics_screen.dart';
import '../analytics/sales_analytics_screen.dart';
import 'cash_banks/cash_banks_screen.dart';
import 'daybook/daybook_screen.dart';
import 'payments/payments_screen.dart';
import 'reports/reports_screen.dart';
import 'transactions/transactions_screen.dart';

/// "Finance" feature list reached from Manage's Finance section "4 more
/// features" link. Lists every Finance module (Daybook, Transactions, Sales
/// & Purchase, Income & Expenses, Payments, Cash & Banks, Reports) as a
/// single bordered card of rows, matching the reference design.
class FinanceFeaturesScreen extends StatelessWidget {
  const FinanceFeaturesScreen({super.key});

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
          'Finance',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            SettingRowsCard(
              items: [
                SettingRowData(
                  icon: Icons.menu_book_outlined,
                  title: 'Daybook',
                  subtitle: 'Manage daily finances',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaybookScreen())),
                ),
                SettingRowData(
                  icon: Icons.show_chart,
                  title: 'Transactions',
                  subtitle: 'All financial transaction of business',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen())),
                ),
                SettingRowData(
                  icon: Icons.bar_chart_outlined,
                  title: 'Sales & Purchase',
                  subtitle: 'Manage all sales and purchase effortlessly',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen())),
                ),
                SettingRowData(
                  icon: Icons.attach_money,
                  title: 'Income & Expenses',
                  subtitle: 'Manage and add income and expenses',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceAnalyticsScreen())),
                ),
                SettingRowData(
                  icon: Icons.sync_alt,
                  title: 'Payments',
                  subtitle: 'All payments in and outs',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentsScreen())),
                ),
                SettingRowData(
                  icon: Icons.credit_card_outlined,
                  title: 'Cash & Banks',
                  subtitle: 'Manage cash and bank accounts',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CashBanksScreen())),
                ),
                SettingRowData(
                  icon: Icons.description_outlined,
                  title: 'Reports',
                  subtitle: 'All summary report of finance',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
