import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/payment_method/payment_method_model.dart';
import '../../../providers/order_provider.dart' show LoadStatus;
import '../../../providers/payment_method_provider.dart';
import 'add_cash_bank_account_screen.dart';
import 'add_payment_mode_screen.dart';
import 'cash_bank_account_detail_screen.dart';
import 'cash_bank_mode_detail_screen.dart';
import 'cash_bank_models.dart';
import 'transfer_balance_screen.dart';

/// "Cash & Banks" screen reached from Manage > Finance > "4 more features" >
/// Cash & Banks, matching the reference design's Account / Modes / Balance
/// Transfer tabs. Every account row opens the same
/// [CashBankAccountDetailScreen] regardless of type (Counter, Bank Account,
/// Owner's Account, ...) — only the account passed in differs.
///
/// The Modes tab is sourced live from [PaymentMethodProvider] (backend:
/// `/api/payment-method`); Account and Balance Transfer stay local-only —
/// there's no backend for either yet.
class CashBanksScreen extends StatefulWidget {
  const CashBanksScreen({super.key});

  @override
  State<CashBanksScreen> createState() => _CashBanksScreenState();
}

class _CashBanksScreenState extends State<CashBanksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<CashBankAccount> _accounts = List.of(cashBankAccounts);

  static const _tabs = ['Account', 'Modes', 'Balance Transfer'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    final modeProvider = context.read<PaymentMethodProvider>();
    if (modeProvider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => modeProvider.fetchPaymentMethods());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addAccount() async {
    final name = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const AddCashBankAccountScreen()));
    if (name != null) {
      setState(() => _accounts.add(CashBankAccount(initials: name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase(), name: name, accountType: 'Cash', balance: 0, modeLabels: const [])));
    }
  }

  Future<void> _addMode() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPaymentModeScreen()));
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
          'Cash & Banks',
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
          unselectedLabelStyle: const TextStyle(decoration: TextDecoration.none),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _AccountTab(accounts: _accounts, onAddAccount: _addAccount),
            _ModesTab(onAddMode: _addMode),
            const _BalanceTransferTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Account tab ----------------

class _AccountTab extends StatelessWidget {
  final List<CashBankAccount> accounts;
  final VoidCallback onAddAccount;
  const _AccountTab({required this.accounts, required this.onAddAccount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: [
              for (final account in accounts) ...[
                _AccountCard(
                  account: account,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CashBankAccountDetailScreen(account: account))),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              Center(
                child: Text('Total Accounts : ${accounts.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
          child: ElevatedButton(
            onPressed: onAddAccount,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Add New Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final CashBankAccount account;
  final VoidCallback onTap;
  const _AccountCard({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
              child: Text(account.initials, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15.5, decoration: TextDecoration.none)),
                  const SizedBox(height: 2),
                  Text('Modes: ${account.modeLabels.join(', ')}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Balance: Rs ${account.balance.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                const SizedBox(height: 6),
                if (account.active) const _ActivePill(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Modes tab ----------------

class _ModesTab extends StatelessWidget {
  final VoidCallback onAddMode;
  const _ModesTab({required this.onAddMode});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentMethodProvider>();

    return Column(
      children: [
        Expanded(child: _buildBody(context, provider)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
          child: ElevatedButton(
            onPressed: onAddMode,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Add New Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, PaymentMethodProvider provider) {
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
                const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => provider.fetchPaymentMethods(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.methods.isEmpty) {
          return Center(
            child: Text('No payment modes created yet.', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
          );
        }
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => provider.fetchPaymentMethods(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: [
              for (final mode in provider.methods) ...[
                _ModeCard(
                  mode: mode,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CashBankModeDetailScreen(mode: mode))),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              Center(
                child: Text('Total Modes : ${provider.methods.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
              ),
            ],
          ),
        );
    }
  }
}

class _ModeCard extends StatelessWidget {
  final PaymentMode mode;
  final VoidCallback onTap;
  const _ModeCard({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
              child: Text(cashBankModeCode(mode.name), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15.5, decoration: TextDecoration.none)),
                  if ((mode.remarks ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(mode.remarks!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.completed.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: const Text('Active', style: TextStyle(color: AppTheme.completed, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none)),
    );
  }
}

// ---------------- Balance Transfer tab ----------------

class _BalanceTransferTab extends StatefulWidget {
  const _BalanceTransferTab();

  @override
  State<_BalanceTransferTab> createState() => _BalanceTransferTabState();
}

class _BalanceTransferTabState extends State<_BalanceTransferTab> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              PopupMenuButton<String>(
                color: AppTheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
                onSelected: (v) => setState(() => _filter = v),
                itemBuilder: (context) => ['All', 'Today', 'This Week', 'This Month']
                    .map((o) => PopupMenuItem<String>(value: o, child: Text(o, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none))))
                    .toList(),
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.tune, color: AppTheme.textPrimary, size: 16),
                        SizedBox(width: 6),
                        Text('Filter', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle, border: Border.all(color: AppTheme.divider)),
                          child: const Icon(Icons.sync_alt, color: AppTheme.accent, size: 56),
                        ),
                        const SizedBox(height: 24),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                            children: [
                              TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                              TextSpan(text: 'Balance Transfer', style: TextStyle(color: AppTheme.accent)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No Balance Transfer found. Needs to create the Balance Transfer!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferBalanceScreen())),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: const Text('Create New Balance Transfer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Learn More', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
