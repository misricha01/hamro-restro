import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/customer/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';

/// "Customer" list reached from Manage > Users > Customer, backed by
/// [CustomerProvider] (`GET /api/customers`). Tapping a row opens
/// [CustomerDetailScreen]; the "+" action reuses [AddCustomerScreen] — since
/// [CustomerProvider] is a shared singleton, a customer created there
/// already shows up here without an explicit refresh.
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CustomerProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchCustomers());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Customer> _filter(List<Customer> customers) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers.where((c) => c.customerName.toLowerCase().contains(query) || c.phoneNumber.contains(query)).toList();
  }

  Future<void> _openAddCustomer() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerScreen()));
  }

  Future<void> _openCustomerDetail(Customer customer) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerDetailScreen(customer: customer)));
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final filtered = _filter(customerProvider.customers);

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
          'Customer',
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
              onTap: _openAddCustomer,
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
                      hintText: 'Search customer',
                      hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            Expanded(child: _buildBody(customerProvider, filtered)),
            if (customerProvider.customers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('Total Customer : ${customerProvider.customers.length}', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CustomerProvider provider, List<Customer> filtered) {
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
                  onPressed: () => provider.fetchCustomers(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (filtered.isEmpty) return const _CustomerEmptyState();
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final customer = filtered[index];
            return _CustomerListTile(customer: customer, onTap: () => _openCustomerDetail(customer));
          },
        );
    }
  }
}

class _CustomerEmptyState extends StatelessWidget {
  const _CustomerEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.support_agent_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'No customers yet',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add your first customer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const _CustomerListTile({required this.customer, required this.onTap});

  String get _initials {
    final parts = customer.customerName.trim().split(RegExp(r'\s+'));
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
                  Text(customer.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                  const SizedBox(height: 2),
                  Text(customer.phoneNumber, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                ],
              ),
            ),
            if (customer.customerGroup != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(customer.customerGroup!.name, style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 12, decoration: TextDecoration.none)),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
