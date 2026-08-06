import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../quick_billing/quick_billing_screen.dart';

/// "Add Sales Return" — reached from the Sales & Purchase screen's Sales
/// Returns tab. Mirrors [AddPurchaseScreen]'s bill-style layout (see
/// add_purchase_screen.dart): customer, return date/reference, a line-item
/// list picked from the dish grid (via [QuickBillingScreen] in selection
/// mode, reused rather than duplicated), and a computed return summary.
class AddSalesReturnScreen extends StatefulWidget {
  const AddSalesReturnScreen({super.key});

  @override
  State<AddSalesReturnScreen> createState() => _AddSalesReturnScreenState();
}

class _AddSalesReturnScreenState extends State<AddSalesReturnScreen> {
  final _returnRefController = TextEditingController();

  String? _customer;
  DateTime _returnDate = DateTime.now();
  String? _returnStaff;
  List<Map<String, dynamic>> _items = [];
  bool _roundOff = false;

  bool _itemsError = false;

  static const List<String> _customers = [
    'Walk-in Customer',
    'Sita Gurung',
    'Prakash Thapa',
  ];

  static const List<String> _staffOptions = [
    'Rajesh Sharma',
    'Sita Gurung',
    'Prakash Thapa',
  ];

  double get _subTotal => _items.fold(0.0, (sum, item) => sum + (item['totalPrice'] as double? ?? 0));
  double get _taxableAmount => _subTotal;
  double get _totalAmount => _roundOff ? _subTotal.roundToDouble() : _subTotal;

  @override
  void dispose() {
    _returnRefController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final result = await _PickSheet.show(context, title: 'Select Customer', items: _customers);
    if (result != null) setState(() => _customer = result);
  }

  Future<void> _pickStaff() async {
    final result = await _PickSheet.show(context, title: 'Select Sales Staff', items: _staffOptions);
    if (result != null) setState(() => _returnStaff = result);
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _returnDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() => _returnDate = result);
  }

  Future<void> _openItemDetails() async {
    final result = await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(builder: (context) => const QuickBillingScreen(title: 'Return Items', isSelectionMode: true)),
    );
    if (result != null) {
      setState(() {
        _items = result;
        _itemsError = false;
      });
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _save() {
    setState(() => _itemsError = _items.isEmpty);
    if (_itemsError) return;
    Navigator.pop(context);
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
          'Add Sales Return',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _FieldLabel(label: 'Customer', required: false),
          const SizedBox(height: 8),
          _SelectField(hint: 'Select Customer', value: _customer, onTap: _pickCustomer),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Return Date', required: true),
          const SizedBox(height: 8),
          _DateField(date: _formatDate(_returnDate), onTap: _pickDate),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Return Reference Number', required: false),
          const SizedBox(height: 8),
          _AppTextField(controller: _returnRefController, hint: 'Enter Return Reference Number'),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Return Staff', required: false),
          const SizedBox(height: 8),
          _SelectField(hint: 'Select Sales Staff', value: _returnStaff, onTap: _pickStaff),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Item Details', required: true),
          const SizedBox(height: 8),
          InkWell(
            onTap: _openItemDetails,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _itemsError ? AppTheme.cancelled : AppTheme.divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _items.isEmpty ? 'Add Item Details' : '${_items.length} Item${_items.length > 1 ? 's' : ''} Added',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
                ],
              ),
            ),
          ),
          if (_itemsError) ...[
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text('Required', style: TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none)),
            ),
          ],
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Return Summary', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                const SizedBox(height: 14),
                _SummaryRow(label: 'Sub Total', value: _subTotal),
                const SizedBox(height: 10),
                _SummaryRow(label: 'Taxable Amount', value: _taxableAmount),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppTheme.divider, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Total Amount', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                        const SizedBox(width: 8),
                        _RoundOffChip(active: _roundOff, onTap: () => setState(() => _roundOff = !_roundOff)),
                      ],
                    ),
                    Text(
                      'Rs ${_totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
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
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Save Sales Return', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Simple search-free list picker (Customer / Staff) ----------------

class _PickSheet extends StatelessWidget {
  final String title;
  final List<String> items;

  const _PickSheet({required this.title, required this.items});

  static Future<String?> show(BuildContext context, {required String title, required List<String> items}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PickSheet(title: title, items: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: items.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                              child: Text(item, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                  ),
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------- Shared small styled widgets (mirrors add_purchase_screen.dart) ----------------

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
        Text('Rs ${value.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
      ],
    );
  }
}

class _RoundOffChip extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _RoundOffChip({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(
          'Add Round Off',
          style: TextStyle(color: active ? AppTheme.primary : AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String date;
  final VoidCallback onTap;
  const _DateField({required this.date, required this.onTap});

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
            const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 10),
            Text(date, style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
        children: [
          TextSpan(text: label),
          if (required) const TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;

  const _AppTextField({this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _SelectField({required this.hint, required this.value, required this.onTap});

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
