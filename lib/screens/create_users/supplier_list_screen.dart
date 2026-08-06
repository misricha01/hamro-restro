import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/supplier/supplier_model.dart';
import '../../data/models/supplier/supplier_transaction_model.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/supplier_transaction_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import 'add_supplier_screen.dart';
import 'add_supplier_transaction_screen.dart';

/// "Supplier" list reached from Manage > Inventory > Suppliers, backed by
/// [SupplierProvider] (`GET /api/supplier`). Tapping a row opens
/// [SupplierDetailScreen]; the "+" action reuses [AddSupplierScreen] — since
/// [SupplierProvider] is a shared singleton, a supplier created there
/// already shows up here without an explicit refresh.
class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SupplierProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchSuppliers());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Supplier> _filter(List<Supplier> suppliers) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return suppliers;
    return suppliers.where((s) => s.supplierName.toLowerCase().contains(query) || s.phoneNumber.contains(query)).toList();
  }

  Future<void> _openAddSupplier() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSupplierScreen()));
  }

  Future<void> _openSupplierDetail(Supplier supplier) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => SupplierDetailScreen(supplier: supplier)));
  }

  @override
  Widget build(BuildContext context) {
    final supplierProvider = context.watch<SupplierProvider>();
    final filtered = _filter(supplierProvider.suppliers);

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
          'Suppliers',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => setState(() => _searching = !_searching),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(_searching ? Icons.close : Icons.search, color: AppTheme.textPrimary, size: 22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _openAddSupplier,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: AppTheme.accent),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                    decoration: const InputDecoration(
                      hintText: 'Search supplier',
                      hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            Expanded(child: _buildBody(supplierProvider, filtered)),
            if (supplierProvider.suppliers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('Total Supplier : ${supplierProvider.suppliers.length}', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SupplierProvider provider, List<Supplier> filtered) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => provider.fetchSuppliers(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (filtered.isEmpty) return const _SupplierEmptyState();
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final supplier = filtered[index];
            return _SupplierListTile(supplier: supplier, onTap: () => _openSupplierDetail(supplier));
          },
        );
    }
  }
}

class _SupplierEmptyState extends StatelessWidget {
  const _SupplierEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'No suppliers yet',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add your first supplier.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierListTile extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;

  const _SupplierListTile({required this.supplier, required this.onTap});

  String get _initials {
    final parts = supplier.supplierName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
              child: Text(_initials, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(supplier.supplierName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                  const SizedBox(height: 2),
                  Text(supplier.phoneNumber, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Supplier detail screen reached by tapping a row in [SupplierListScreen].
/// Info card plus a real Transactions ledger backed by
/// [SupplierTransactionProvider] (`/api/supplier-transaction`) — the
/// backend has no per-supplier filter, so the provider fetches every
/// transaction once and this screen filters by `supplierId`.
class SupplierDetailScreen extends StatefulWidget {
  final Supplier supplier;
  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SupplierTransactionProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchTransactions());
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _addTransaction() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddSupplierTransactionScreen(supplierId: widget.supplier.id)));
  }

  Future<void> _deleteTransaction(SupplierTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Transaction', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: const Text('This transaction will be permanently removed.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<SupplierTransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteSupplierTransaction(transaction.id);
    if (!success && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to delete transaction')));
    }
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Remove Supplier', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          "Remove ${widget.supplier.supplierName} from your supplier list?",
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final provider = context.read<SupplierProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteSupplier(widget.supplier.id);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isDeleting = false);
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to remove supplier')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplier = widget.supplier;
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
          supplier.supplierName,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isDeleting
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.accent)),
                  )
                : GestureDetector(
                    onTap: _confirmRemove,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.delete_outline, color: AppTheme.cancelled, size: 20),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
              child: Column(
                children: [
                  _DetailRow(label: 'Contact', value: supplier.phoneNumber),
                  if (supplier.address != null) _DetailRow(label: 'Address', value: supplier.address!),
                  _DetailRow(label: 'Remarks', value: supplier.remarks ?? '-', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Transactions', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addTransaction,
                  icon: const Icon(Icons.add, color: AppTheme.accent, size: 18),
                  label: const Text('Add Transaction', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTransactions(context, supplier.id),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions(BuildContext context, String supplierId) {
    final provider = context.watch<SupplierTransactionProvider>();
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(color: AppTheme.accent)));
      case LoadStatus.error:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => provider.fetchTransactions(),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
              ),
            ],
          ),
        );
      case LoadStatus.loaded:
        final transactions = provider.transactionsFor(supplierId);
        if (transactions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No transactions yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none))),
          );
        }
        return Column(
          children: transactions.map((transaction) {
            final isReceivable = (transaction.toReceived ?? 0) > 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction.particulars, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                        Text(
                          '${_formatDate(transaction.date)} • ${transaction.paymentMethodName ?? 'Payment'}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                        ),
                        if (transaction.remarks != null && transaction.remarks!.isNotEmpty)
                          Text(transaction.remarks!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs ${transaction.totalPayment.toStringAsFixed(0)}',
                        style: TextStyle(color: isReceivable ? AppTheme.completed : AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                      ),
                      GestureDetector(
                        onTap: () => _deleteTransaction(transaction),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(Icons.delete_outline, color: AppTheme.cancelled, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppTheme.divider))),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          const Text(':  ', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
        ],
      ),
    );
  }
}
