import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/sales_purchase/purchase_bill_model.dart';
import '../../data/models/sales_purchase/sales_transaction_model.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/purchase_bill_provider.dart';
import '../../providers/sales_transaction_provider.dart';
import '../../widgets/common/analytics_cards.dart';
import '../../widgets/common/select_staffs_sheet.dart';
import '../finance/add_purchase_screen.dart';
import '../finance/add_sales_return_screen.dart';

/// "Sales & Purchase" screen reached by tapping the Overview tab's Sales /
/// Purchase cards. Shows the Sales Invoice / Purchase Bills / Sales Returns /
/// Purchase Returns breakdown with the same filter row (date range, type,
/// entry-by staff, clear filter) and empty-state layout on each tab, matching
/// the reference design. [initialTabIndex] lets callers land on a specific
/// tab (e.g. the Overview Purchase card opens straight to Purchase Bills).
class SalesAnalyticsScreen extends StatefulWidget {
  final int initialTabIndex;
  const SalesAnalyticsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = ['Sales Invoice', 'Purchase Bills', 'Sales Returns', 'Purchase Returns'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Sales & Purchase',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppTheme.textPrimary),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined, color: AppTheme.textPrimary),
          ),
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
            TabBar(
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  SalesInvoiceTab(),
                  PurchaseBillsTab(),
                  _SalesPurchaseTab(entityName: 'Sales Returns'),
                  _SalesPurchaseTab(entityName: 'Purchase Returns'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static Sales Returns / Purchase Returns tabs — the backend has no
/// endpoint for either yet, so these stay hardcoded empty states like the
/// Finance overview's staff/customer/payment/transaction lists.
class _SalesPurchaseTab extends StatefulWidget {
  final String entityName;
  const _SalesPurchaseTab({required this.entityName});

  @override
  State<_SalesPurchaseTab> createState() => _SalesPurchaseTabState();
}

class _SalesPurchaseTabState extends State<_SalesPurchaseTab> {
  static const _typeOptions = ['All', 'Paid', 'Unpaid', 'Partial'];
  static const _staffs = [StaffOption(name: 'Kritika Mishra', username: 'kritikamishra')];

  String _dateFilter = 'Today';
  String _typeFilter = 'All';
  List<String> _selectedStaffs = const [];

  void _clearFilters() {
    setState(() {
      _dateFilter = 'Today';
      _typeFilter = 'All';
      _selectedStaffs = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final entryByLabel = _selectedStaffs.isEmpty ? 'Entry By: All' : 'Entry By: ${_selectedStaffs.length}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AnalyticsFilterDropdown(
                  label: _dateFilter,
                  options: kAnalyticsDateFilterOptions,
                  onSelected: (v) => setState(() => _dateFilter = v),
                ),
                const SizedBox(width: 12),
                AnalyticsFilterDropdown(
                  label: 'Types: $_typeFilter',
                  options: _typeOptions,
                  onSelected: (v) => setState(() => _typeFilter = v),
                ),
                const SizedBox(width: 12),
                AnalyticsFilterButton(
                  label: entryByLabel,
                  onTap: () => SelectStaffsSheet.show(
                    context,
                    staffs: _staffs,
                    initialSelected: _selectedStaffs,
                    onApply: (selected) => setState(() => _selectedStaffs = selected),
                  ),
                ),
                const SizedBox(width: 12),
                ClearFilterButton(onTap: _clearFilters),
              ],
            ),
          ),
        ),
        Expanded(
          child: InvoiceEmptyState(entityName: widget.entityName),
        ),
        if (widget.entityName == 'Sales Returns')
          AddEntityBar(
            label: 'Add Sales Return',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSalesReturnScreen())),
          )
        else if (widget.entityName == 'Purchase Returns')
          AddEntityBar(
            label: 'Add Purchase Return',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPurchaseScreen(title: 'Add Purchase Return'))),
          ),
      ],
    );
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

String _rs(double v) => 'Rs ${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'completed':
      return AppTheme.completed;
    case 'partial':
      return AppTheme.pending;
    default:
      return AppTheme.cancelled;
  }
}

/// Small colored status pill (e.g. "Paid", "Partial", "Unpaid") shared by
/// the Sales Invoice and Purchase Bills record cards.
class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.isEmpty ? '—' : '${status[0].toUpperCase()}${status.substring(1)}',
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none),
      ),
    );
  }
}

/// Centered error card with a retry button, shared by the Sales Invoice and
/// Purchase Bills tabs.
class _RecordListErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _RecordListErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: AppTheme.textSecondary),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
              child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Sales Invoice" tab, backed by [SalesTransactionProvider]
/// (`GET /api/sales-transaction`). The "Types" filter maps to the
/// `checkoutStatus` query param; date range and entry-by-staff filters stay
/// local-only for now, matching the rest of the Analytics module. Public so
/// [DaybookSalesSummaryScreen] can reuse it too.
class SalesInvoiceTab extends StatefulWidget {
  const SalesInvoiceTab();

  @override
  State<SalesInvoiceTab> createState() => _SalesInvoiceTabState();
}

class _SalesInvoiceTabState extends State<SalesInvoiceTab> {
  static const _typeOptions = ['All', 'Paid', 'Unpaid', 'Partial'];
  static const _staffs = [StaffOption(name: 'Kritika Mishra', username: 'kritikamishra')];
  static const _statusByType = {'Paid': 'completed', 'Unpaid': 'pending', 'Partial': 'partial'};

  String _dateFilter = 'Today';
  String _typeFilter = 'All';
  List<String> _selectedStaffs = const [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<SalesTransactionProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchTransactions());
    }
  }

  void _fetch() => context.read<SalesTransactionProvider>().fetchTransactions(checkoutStatus: _statusByType[_typeFilter]);

  void _clearFilters() {
    setState(() {
      _dateFilter = 'Today';
      _typeFilter = 'All';
      _selectedStaffs = const [];
    });
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final entryByLabel = _selectedStaffs.isEmpty ? 'Entry By: All' : 'Entry By: ${_selectedStaffs.length}';
    final provider = context.watch<SalesTransactionProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AnalyticsFilterDropdown(
                  label: _dateFilter,
                  options: kAnalyticsDateFilterOptions,
                  onSelected: (v) => setState(() => _dateFilter = v),
                ),
                const SizedBox(width: 12),
                AnalyticsFilterDropdown(
                  label: 'Types: $_typeFilter',
                  options: _typeOptions,
                  onSelected: (v) {
                    setState(() => _typeFilter = v);
                    _fetch();
                  },
                ),
                const SizedBox(width: 12),
                AnalyticsFilterButton(
                  label: entryByLabel,
                  onTap: () => SelectStaffsSheet.show(
                    context,
                    staffs: _staffs,
                    initialSelected: _selectedStaffs,
                    onApply: (selected) => setState(() => _selectedStaffs = selected),
                  ),
                ),
                const SizedBox(width: 12),
                ClearFilterButton(onTap: _clearFilters),
              ],
            ),
          ),
        ),
        Expanded(child: _buildBody(provider)),
      ],
    );
  }

  Widget _buildBody(SalesTransactionProvider provider) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (provider.status == LoadStatus.error) {
      return _RecordListErrorCard(message: provider.errorMessage ?? 'Something went wrong.', onRetry: _fetch);
    }
    if (provider.transactions.isEmpty) {
      return const InvoiceEmptyState(entityName: 'Sales Invoice');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _SalesInvoiceCard(transaction: provider.transactions[index]),
    );
  }
}

class _SalesInvoiceCard extends StatelessWidget {
  final SalesTransaction transaction;
  const _SalesInvoiceCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction.invoiceNumber,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
                ),
              ),
              _StatusPill(status: transaction.checkoutStatus),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (transaction.tableName != null) transaction.tableName!,
              if (transaction.customerName != null) transaction.customerName!,
              _formatDate(transaction.createdAt),
            ].join(' • '),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${transaction.noOfGuests} Guest${transaction.noOfGuests == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
              Text(_rs(transaction.totalAmount), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
            ],
          ),
          if (transaction.dueAmount > 0) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Due: ${_rs(transaction.dueAmount)}', style: const TextStyle(color: AppTheme.cancelled, fontSize: 12.5, decoration: TextDecoration.none)),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Purchase Bills" tab, backed by [PurchaseBillProvider]
/// (`GET /api/purchase-bill`). The "Types" filter maps to the
/// `purchaseStatus` query param; date range and entry-by-staff filters stay
/// local-only for now, matching the rest of the Analytics module. Public so
/// [DaybookSalesSummaryScreen] can reuse it too.
class PurchaseBillsTab extends StatefulWidget {
  const PurchaseBillsTab();

  @override
  State<PurchaseBillsTab> createState() => _PurchaseBillsTabState();
}

class _PurchaseBillsTabState extends State<PurchaseBillsTab> {
  static const _typeOptions = ['All', 'Paid', 'Unpaid', 'Partial'];
  static const _staffs = [StaffOption(name: 'Kritika Mishra', username: 'kritikamishra')];
  static const _statusByType = {'Paid': 'paid', 'Unpaid': 'unpaid', 'Partial': 'partial'};

  String _dateFilter = 'Today';
  String _typeFilter = 'All';
  List<String> _selectedStaffs = const [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<PurchaseBillProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchBills());
    }
  }

  void _fetch() => context.read<PurchaseBillProvider>().fetchBills(purchaseStatus: _statusByType[_typeFilter]);

  void _clearFilters() {
    setState(() {
      _dateFilter = 'Today';
      _typeFilter = 'All';
      _selectedStaffs = const [];
    });
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final entryByLabel = _selectedStaffs.isEmpty ? 'Entry By: All' : 'Entry By: ${_selectedStaffs.length}';
    final provider = context.watch<PurchaseBillProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AnalyticsFilterDropdown(
                  label: _dateFilter,
                  options: kAnalyticsDateFilterOptions,
                  onSelected: (v) => setState(() => _dateFilter = v),
                ),
                const SizedBox(width: 12),
                AnalyticsFilterDropdown(
                  label: 'Types: $_typeFilter',
                  options: _typeOptions,
                  onSelected: (v) {
                    setState(() => _typeFilter = v);
                    _fetch();
                  },
                ),
                const SizedBox(width: 12),
                AnalyticsFilterButton(
                  label: entryByLabel,
                  onTap: () => SelectStaffsSheet.show(
                    context,
                    staffs: _staffs,
                    initialSelected: _selectedStaffs,
                    onApply: (selected) => setState(() => _selectedStaffs = selected),
                  ),
                ),
                const SizedBox(width: 12),
                ClearFilterButton(onTap: _clearFilters),
              ],
            ),
          ),
        ),
        Expanded(child: _buildBody(provider)),
        AddEntityBar(
          label: 'Add Purchase Bill',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPurchaseScreen())),
        ),
      ],
    );
  }

  Widget _buildBody(PurchaseBillProvider provider) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (provider.status == LoadStatus.error) {
      return _RecordListErrorCard(message: provider.errorMessage ?? 'Something went wrong.', onRetry: _fetch);
    }
    if (provider.bills.isEmpty) {
      return const InvoiceEmptyState(entityName: 'Purchase Bills');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.bills.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _PurchaseBillCard(bill: provider.bills[index]),
    );
  }
}

class _PurchaseBillCard extends StatelessWidget {
  final PurchaseBill bill;
  const _PurchaseBillCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bill.billNo,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
                ),
              ),
              _StatusPill(status: bill.purchaseStatus),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (bill.supplier != null) bill.supplier!.supplierName,
              _formatDate(bill.date),
            ].join(' • '),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bill.paymentType.isEmpty ? '—' : bill.paymentType,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
              Text(_rs(bill.amount), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Full-width primary-colored bottom action bar ("Add Purchase Bill", "Add
/// Income", etc.) shared by [SalesAnalyticsScreen] and [FinanceAnalyticsScreen]
/// so every Analytics record-list screen gets the same bottom CTA styling.
class AddEntityBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const AddEntityBar({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
        ),
      ),
    );
  }
}

/// "Clear Filter" chip shared by [SalesAnalyticsScreen] and
/// [FinanceAnalyticsScreen] filter rows.
class ClearFilterButton extends StatelessWidget {
  final VoidCallback onTap;
  const ClearFilterButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cancelled.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.cancelled.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: AppTheme.cancelled, size: 18),
            SizedBox(width: 6),
            Text('Clear Filter', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

/// Generic "No {entity} found" empty state shared by [SalesAnalyticsScreen]
/// and [FinanceAnalyticsScreen] record-list tabs.
class InvoiceEmptyState extends StatelessWidget {
  final String entityName;
  const InvoiceEmptyState({super.key, required this.entityName});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                    child: const Icon(Icons.receipt_long_outlined, color: AppTheme.accent, size: 56),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                      children: [
                        const TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                        TextSpan(text: entityName, style: const TextStyle(color: AppTheme.accent)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No $entityName found. Needs to create the $entityName!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Learn More',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
