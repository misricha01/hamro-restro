import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/expense/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../finance/add_expense_screen.dart';
import '../finance/add_income_screen.dart';
import 'sales_analytics_screen.dart' show InvoiceEmptyState;

/// "Income & Expenses" screen reached by tapping the Overview tab's Income /
/// Expense cards. Shows real expenses from [ExpenseProvider] (backend:
/// `/api/expenses`) — there's no backend concept of "Income" as a
/// persisted record, so the Income side stays entry-only via the "Add
/// Income" CTA, matching the reference design's shared "Add Income" / "Add
/// Expense" bar.
class FinanceAnalyticsScreen extends StatefulWidget {
  const FinanceAnalyticsScreen({super.key});

  @override
  State<FinanceAnalyticsScreen> createState() => _FinanceAnalyticsScreenState();
}

class _FinanceAnalyticsScreenState extends State<FinanceAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<ExpenseProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchExpenses());
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _addExpense() async {
    final result = await Navigator.push<Expense>(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
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
          'Income & Expenses',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(provider)),
            _FinanceAddButtonsBar(
              onAddIncome: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddIncomeScreen())),
              onAddExpense: _addExpense,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ExpenseProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => provider.fetchExpenses(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.expenses.isEmpty) {
          return const InvoiceEmptyState(entityName: 'Transactions');
        }
        return RefreshIndicator(
          onRefresh: provider.fetchExpenses,
          color: AppTheme.accent,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.expenses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_upward, color: AppTheme.cancelled, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(expense.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                          Text(
                            '${expense.categoryName ?? 'Uncategorized'} • ${_formatDate(expense.expenseDate)}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rs ${expense.amount.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        Text(
                          expense.paymentStatus.isEmpty ? '' : expense.paymentStatus[0].toUpperCase() + expense.paymentStatus.substring(1),
                          style: TextStyle(color: expense.paymentStatus.toLowerCase() == 'paid' ? AppTheme.completed : AppTheme.pending, fontSize: 12, decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
    }
  }
}

/// Bottom bar with the two Finance entry-point CTAs shown side by side,
/// matching the reference design's green "Add Income" / blue "Add Expense"
/// buttons — reusing [AppTheme.completed] and [AppTheme.accent] rather than
/// introducing new colors.
class _FinanceAddButtonsBar extends StatelessWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  const _FinanceAddButtonsBar({required this.onAddIncome, required this.onAddExpense});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
      child: Row(
        children: [
          Expanded(child: _FinanceCtaButton(label: 'Add Income', color: AppTheme.completed, onTap: onAddIncome)),
          const SizedBox(width: 12),
          Expanded(child: _FinanceCtaButton(label: 'Add Expense', color: AppTheme.accent, onTap: onAddExpense)),
        ],
      ),
    );
  }
}

class _FinanceCtaButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FinanceCtaButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}
