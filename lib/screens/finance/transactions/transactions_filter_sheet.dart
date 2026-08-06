import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/order_provider.dart' show LoadStatus;
import '../../../providers/supplier_provider.dart';
import '../../../widgets/common/select_staffs_sheet.dart';
import '../../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;

const List<String> kTransactionTypes = [
  'All', 'Sales', 'Sales Return', 'Purchase', 'Purchase Return',
  'Income', 'Expense', 'Payment In', 'Payment Out', 'Balance Transfer',
];
const List<String> kTransactionPaymentStatuses = ['All', 'Paid', 'Unpaid', 'Partial'];
const List<String> kTransactionPaymentModes = ['All', 'Bank Transfer', 'Card', 'Cash', 'Fonepay', 'Nepal Pay'];
const List<String> kTransactionDatePresets = ['Today', 'This Month', 'This Week', 'Last Week', 'Last Month'];
const List<StaffOption> kTransactionStaffOptions = [StaffOption(name: 'Kritika Mishra', username: 'kritikamishra')];

/// Snapshot of everything selected in [TransactionsFilterSheet], handed back
/// to [TransactionsScreen] via [TransactionsFilterSheet.onApply].
class TransactionsFilter {
  final String datePreset;
  final DateTime from;
  final DateTime to;
  final List<String> entryByStaffs;
  final String type;
  final String paymentStatus;
  final String paymentMode;
  final List<String> assignedStaffs;
  final String? customer;
  final String? supplier;

  const TransactionsFilter({
    required this.datePreset,
    required this.from,
    required this.to,
    required this.entryByStaffs,
    required this.type,
    required this.paymentStatus,
    required this.paymentMode,
    required this.assignedStaffs,
    this.customer,
    this.supplier,
  });

  factory TransactionsFilter.initial() {
    final now = DateTime.now();
    return TransactionsFilter(
      datePreset: 'This Year',
      from: DateTime(now.year, 1, 1),
      to: DateTime(now.year, 12, 31),
      entryByStaffs: const [],
      type: 'All',
      paymentStatus: 'All',
      paymentMode: 'All',
      assignedStaffs: const [],
    );
  }

  bool get isDefault {
    final d = TransactionsFilter.initial();
    return type == d.type && paymentStatus == d.paymentStatus && paymentMode == d.paymentMode && datePreset == d.datePreset;
  }

  TransactionsFilter copyWith({
    String? datePreset,
    DateTime? from,
    DateTime? to,
    List<String>? entryByStaffs,
    String? type,
    String? paymentStatus,
    String? paymentMode,
    List<String>? assignedStaffs,
    String? customer,
    String? supplier,
  }) {
    return TransactionsFilter(
      datePreset: datePreset ?? this.datePreset,
      from: from ?? this.from,
      to: to ?? this.to,
      entryByStaffs: entryByStaffs ?? this.entryByStaffs,
      type: type ?? this.type,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMode: paymentMode ?? this.paymentMode,
      assignedStaffs: assignedStaffs ?? this.assignedStaffs,
      customer: customer ?? this.customer,
      supplier: supplier ?? this.supplier,
    );
  }
}

/// "Filter" bottom sheet reached from the Transactions screen's Filter
/// button. Covers Date range, Entry By staff, transaction Type, Payment
/// Status, Payment Mode, assigned Staffs, Customer and Suppliers.
class TransactionsFilterSheet extends StatefulWidget {
  final TransactionsFilter initial;
  final ValueChanged<TransactionsFilter> onApply;

  const TransactionsFilterSheet({super.key, required this.initial, required this.onApply});

  static Future<void> show(
    BuildContext context, {
    required TransactionsFilter initial,
    required ValueChanged<TransactionsFilter> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionsFilterSheet(initial: initial, onApply: onApply),
    );
  }

  @override
  State<TransactionsFilterSheet> createState() => _TransactionsFilterSheetState();
}

class _TransactionsFilterSheetState extends State<TransactionsFilterSheet> {
  late TransactionsFilter _filter = widget.initial;

  String _formatShort(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}';
  }

  String _formatIso(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _applyPreset(String preset) {
    final now = DateTime.now();
    DateTime from;
    DateTime to = now;
    switch (preset) {
      case 'Today':
        from = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        from = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Last Week':
        from = now.subtract(Duration(days: now.weekday - 1 + 7));
        to = now.subtract(Duration(days: now.weekday));
        break;
      case 'This Month':
        from = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        from = DateTime(now.year, now.month - 1, 1);
        to = DateTime(now.year, now.month, 0);
        break;
      default:
        from = DateTime(now.year, 1, 1);
        to = DateTime(now.year, 12, 31);
    }
    setState(() => _filter = _filter.copyWith(datePreset: preset, from: from, to: to));
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final result = await showDatePicker(
      context: context,
      initialDate: isFrom ? _filter.from : _filter.to,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result == null) return;
    setState(() => _filter = isFrom ? _filter.copyWith(from: result, datePreset: 'Custom Range') : _filter.copyWith(to: result, datePreset: 'Custom Range'));
  }

  Future<void> _pickEntryByStaffs() async {
    await SelectStaffsSheet.show(
      context,
      staffs: kTransactionStaffOptions,
      initialSelected: _filter.entryByStaffs,
      onApply: (selected) => setState(() => _filter = _filter.copyWith(entryByStaffs: selected)),
    );
  }

  Future<void> _pickAssignedStaffs() async {
    await SelectStaffsSheet.show(
      context,
      staffs: kTransactionStaffOptions,
      initialSelected: _filter.assignedStaffs,
      onApply: (selected) => setState(() => _filter = _filter.copyWith(assignedStaffs: selected)),
    );
  }

  Future<void> _pickCustomer() async {
    final provider = context.read<CustomerProvider>();
    if (provider.status == LoadStatus.idle) await provider.fetchCustomers();
    if (!mounted) return;
    final result = await _SelectEntityPickerSheet.show(
      context,
      title: 'Select Customer',
      entityName: 'Customer',
      names: provider.customers.map((c) => c.customerName).toList(),
    );
    if (result != null) setState(() => _filter = _filter.copyWith(customer: result));
  }

  Future<void> _pickSupplier() async {
    final provider = context.read<SupplierProvider>();
    if (provider.status == LoadStatus.idle) await provider.fetchSuppliers();
    if (!mounted) return;
    final result = await _SelectEntityPickerSheet.show(
      context,
      title: 'Select Suppliers',
      entityName: 'Suppliers',
      names: provider.suppliers.map((s) => s.supplierName).toList(),
    );
    if (result != null) setState(() => _filter = _filter.copyWith(supplier: result));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Filter', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Text('Date', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                            const Spacer(),
                            Text(
                              '${_formatShort(_filter.from)} - ${_formatShort(_filter.to)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final preset in kTransactionDatePresets) ...[
                                _FilterChip(label: preset, selected: _filter.datePreset == preset, onTap: () => _applyPreset(preset)),
                                const SizedBox(width: 10),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _DateBox(label: 'From', value: _formatIso(_filter.from), onTap: () => _pickDate(isFrom: true)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DateBox(label: 'To', value: _formatIso(_filter.to), onTap: () => _pickDate(isFrom: false)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text('Entry By', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                        const SizedBox(height: 10),
                        _SelectBox(
                          hint: 'Select Staffs to filter',
                          value: _filter.entryByStaffs.isEmpty ? null : '${_filter.entryByStaffs.length} Selected',
                          onTap: _pickEntryByStaffs,
                        ),
                        const SizedBox(height: 24),

                        const Text('Type', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final type in kTransactionTypes)
                              _FilterChip(label: type, selected: _filter.type == type, onTap: () => setState(() => _filter = _filter.copyWith(type: type))),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text('Payment Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final status in kTransactionPaymentStatuses)
                              _FilterChip(label: status, selected: _filter.paymentStatus == status, onTap: () => setState(() => _filter = _filter.copyWith(paymentStatus: status))),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text('Payment Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final mode in kTransactionPaymentModes)
                              _FilterChip(label: mode, selected: _filter.paymentMode == mode, onTap: () => setState(() => _filter = _filter.copyWith(paymentMode: mode))),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text('Staffs', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF241F3D), borderRadius: BorderRadius.circular(10)),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline, color: Color(0xFFC9BFFF), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Those staffs which are assigned to transactions.',
                                  style: TextStyle(color: Color(0xFFC9BFFF), fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _SelectBox(
                          hint: 'Select Staffs to filter',
                          value: _filter.assignedStaffs.isEmpty ? null : '${_filter.assignedStaffs.length} Selected',
                          onTap: _pickAssignedStaffs,
                        ),
                        const SizedBox(height: 24),

                        const Text('Customer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                        const SizedBox(height: 10),
                        _SelectBox(hint: 'Select Customer to filter', value: _filter.customer, onTap: _pickCustomer),
                        const SizedBox(height: 24),

                        const Text('Suppliers', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                        const SizedBox(height: 10),
                        _SelectBox(hint: 'Select Suppliers to filter', value: _filter.supplier, onTap: _pickSupplier),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.divider))),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onApply(_filter);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cancelled,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Apply Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -18,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: AppTheme.cancelled, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cancelled.withValues(alpha: 0.12) : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.cancelled.withValues(alpha: 0.4) : AppTheme.divider),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? AppTheme.cancelled : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateBox({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
            child: Row(
              children: [
                Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none))),
                const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectBox extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;
  const _SelectBox({required this.hint, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(color: value != null ? AppTheme.textPrimary : AppTheme.textSecondary, decoration: TextDecoration.none),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// "Select Customer" / "Select Suppliers" picker stacked on top of the
/// Filter sheet, backed by [CustomerProvider]/[SupplierProvider] (`GET
/// /api/customers`, `/api/supplier`) — falls back to the shared
/// "No {entity} found" empty state when there's nothing to pick from.
class _SelectEntityPickerSheet extends StatelessWidget {
  final String title;
  final String entityName;
  final List<String> names;
  const _SelectEntityPickerSheet({required this.title, required this.entityName, required this.names});

  static Future<String?> show(BuildContext context, {required String title, required String entityName, required List<String> names}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectEntityPickerSheet(title: title, entityName: entityName, names: names),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: names.isEmpty
                      ? InvoiceEmptyState(entityName: entityName)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: names.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.divider),
                          itemBuilder: (context, index) => InkWell(
                            onTap: () => Navigator.pop(context, names[index]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(names[index], style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14.5, decoration: TextDecoration.none)),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -18,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: AppTheme.cancelled, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
