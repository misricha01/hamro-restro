import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/customer/customer_model.dart';
import '../../data/models/payment_method/payment_method_model.dart';
import '../../data/models/checkout/checkout_model.dart';
import '../../data/repositories/checkout_repository.dart' show SplitPayment;
import '../../providers/checkout_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/finance_form_fields.dart';
import '../finance/add_expense_screen.dart' show SelectPaymentMethodSheet;
import '../finance/add_purchase_screen.dart' show SelectCustomerSheet;

/// "Checkout" / bill settlement, reached from an active order's Bill action.
/// Two-step flow matching the backend exactly:
///
/// 1. **Generate Bill** — `POST /api/checkout` (`CheckoutProvider.generateBill`)
///    computes the bill for [tableId]'s current order server-side (the app
///    has no client-side pricing data to build one from — `OrderItem`
///    carries no price at all). An optional discount can be applied here.
/// 2. **Complete Checkout** — `PATCH /api/checkout/{id}`
///    (`CheckoutProvider.completeCheckout`) records a payment-method split
///    and finalizes it. `checkoutStatus` is derived from how much of the
///    total the entered payments cover (`completed` vs `partial`) rather
///    than asked of the user directly.
///
/// A bill generated but abandoned can be cleared via the "Cancel Bill" app
/// bar action (`DELETE /api/checkout/{id}`) so it doesn't linger as an
/// orphaned `pending` record against the table.
class CheckoutScreen extends StatefulWidget {
  final String tableId;
  final String tableName;

  const CheckoutScreen({super.key, required this.tableId, required this.tableName});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _PaymentRow {
  PaymentMode? method;
  final TextEditingController amountController = TextEditingController();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _discountController = TextEditingController();
  final _remarksController = TextEditingController();
  bool _isPercentageDiscount = false;

  Checkout? _checkout;

  final _guestsController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyPanController = TextEditingController();
  Customer? _customer;
  final List<_PaymentRow> _paymentRows = [_PaymentRow()];

  @override
  void dispose() {
    _discountController.dispose();
    _remarksController.dispose();
    _guestsController.dispose();
    _companyNameController.dispose();
    _companyPanController.dispose();
    for (final row in _paymentRows) {
      row.amountController.dispose();
    }
    super.dispose();
  }

  double get _totalPaid => _paymentRows.fold(0.0, (sum, row) => sum + (double.tryParse(row.amountController.text.trim()) ?? 0));

  double get _remaining => (_checkout?.totalAmount ?? 0) - _totalPaid;

  Future<void> _generateBill() async {
    final provider = context.read<CheckoutProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final discount = _discountController.text.trim();
    final remarks = _remarksController.text.trim();

    final checkout = await provider.generateBill(
      tableId: widget.tableId,
      discountType: discount.isEmpty ? null : (_isPercentageDiscount ? 'percentage' : 'amount'),
      discount: discount.isEmpty ? null : discount,
      remarks: remarks.isEmpty ? null : remarks,
    );
    if (!mounted) return;

    if (checkout != null) {
      setState(() => _checkout = checkout);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(provider.generateErrorMessage ?? 'Failed to generate bill')));
    }
  }

  Future<void> _pickCustomer() async {
    final result = await SelectCustomerSheet.show(context);
    if (result != null) setState(() => _customer = result);
  }

  void _addPaymentRow() => setState(() => _paymentRows.add(_PaymentRow()));

  void _removePaymentRow(int index) {
    setState(() {
      _paymentRows[index].amountController.dispose();
      _paymentRows.removeAt(index);
    });
  }

  Future<void> _pickPaymentMethodForRow(int index) async {
    final result = await SelectPaymentMethodSheet.show(context);
    if (result != null) setState(() => _paymentRows[index].method = result);
  }

  Future<void> _complete() async {
    final checkout = _checkout;
    if (checkout == null) return;
    final messenger = ScaffoldMessenger.of(context);

    final splits = <SplitPayment>[];
    for (final row in _paymentRows) {
      final amount = double.tryParse(row.amountController.text.trim());
      if (row.method == null || amount == null || amount <= 0) continue;
      splits.add(SplitPayment(paymentMethodId: row.method!.id, amount: amount));
    }
    if (splits.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Add at least one payment method and amount')));
      return;
    }

    final checkoutStatus = _totalPaid + 0.01 >= checkout.totalAmount ? 'completed' : 'partial';
    final guests = _guestsController.text.trim();
    final companyName = _companyNameController.text.trim();
    final companyPan = _companyPanController.text.trim();

    final provider = context.read<CheckoutProvider>();
    final result = await provider.completeCheckout(
      id: checkout.id,
      checkoutStatus: checkoutStatus,
      noOfGuests: guests.isEmpty ? null : guests,
      customerId: _customer?.id,
      companyName: companyName.isEmpty ? null : companyName,
      companyPan: companyPan.isEmpty ? null : companyPan,
      payments: splits,
    );
    if (!mounted) return;

    if (result != null) {
      messenger.showSnackBar(SnackBar(content: Text(checkoutStatus == 'completed' ? 'Bill settled' : 'Partial payment recorded')));
      // The table's order should now read as closed (or partially paid) —
      // refresh so the Active Orders tab drops or updates it.
      context.read<OrderProvider>().fetchOrders();
      Navigator.pop(context, result);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(provider.completeErrorMessage ?? 'Failed to complete checkout')));
    }
  }

  Future<void> _cancelBill() async {
    final checkout = _checkout;
    if (checkout == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Cancel this bill?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: const Text('The generated bill will be discarded. You can generate a new one anytime.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Editing', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel Bill', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<CheckoutProvider>();
    await provider.cancelCheckout(checkout.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final checkout = _checkout;

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
          '${widget.tableName} - Bill',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          if (checkout != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: provider.isCancelling ? null : _cancelBill,
                child: const Text('Cancel Bill', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: checkout == null ? _buildGenerateForm(provider) : _buildBillForm(provider, checkout),
      ),
    );
  }

  Widget _buildGenerateForm(CheckoutProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text('Generate Bill', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
        const SizedBox(height: 6),
        const Text(
          "Generates the bill from this table's current order. You can apply a discount before generating.",
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
        ),
        const SizedBox(height: 24),

        const FieldLabel(label: 'Discount', required: false),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _discountController,
                hint: '0',
                prefix: _isPercentageDiscount ? '%' : 'Rs',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 160,
                child: TwoWaySegment(
                  leftLabel: 'Amount',
                  rightLabel: 'Percent',
                  isLeftSelected: !_isPercentageDiscount,
                  onChanged: (v) => setState(() => _isPercentageDiscount = !v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const FieldLabel(label: 'Remarks', required: false),
        const SizedBox(height: 8),
        AppTextField(controller: _remarksController, hint: 'Optional note for this bill', maxLines: 3),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isGenerating ? null : _generateBill,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: provider.isGenerating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Generate Bill', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ),
        ),
      ],
    );
  }

  Widget _buildBillForm(CheckoutProvider provider, Checkout checkout) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
                child: Column(
                  children: [
                    if (checkout.invoiceNumber != null) _SummaryRow(label: 'Invoice No.', value: checkout.invoiceNumber!),
                    if (checkout.discount > 0) _SummaryRow(label: 'Discount', value: checkout.discountType == 'percentage' ? '${checkout.discount.toStringAsFixed(0)}%' : 'Rs ${checkout.discount.toStringAsFixed(0)}'),
                    _SummaryRow(label: 'Total Amount', value: 'Rs ${checkout.totalAmount.toStringAsFixed(0)}', emphasize: true),
                    _SummaryRow(label: 'Paid So Far', value: 'Rs ${checkout.paidAmount.toStringAsFixed(0)}'),
                    _SummaryRow(label: 'Due', value: 'Rs ${checkout.dueAmount.toStringAsFixed(0)}', isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel(label: 'No. of Guests', required: false),
                        const SizedBox(height: 8),
                        AppTextField(controller: _guestsController, hint: 'e.g. 4', keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel(label: 'Customer', required: false),
                        const SizedBox(height: 8),
                        SelectField(hint: 'Select Customer', value: _customer?.customerName, onTap: _pickCustomer),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel(label: 'Company Name', required: false),
                        const SizedBox(height: 8),
                        AppTextField(controller: _companyNameController, hint: 'For VAT invoice'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel(label: 'Company PAN', required: false),
                        const SizedBox(height: 8),
                        AppTextField(controller: _companyPanController, hint: 'e.g. 123-A12Z'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(
                    child: Text('Payment Split', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                  ),
                  TextButton.icon(
                    onPressed: _addPaymentRow,
                    icon: const Icon(Icons.add, color: AppTheme.accent, size: 18),
                    label: const Text('Add Method', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < _paymentRows.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SelectField(hint: 'Method', value: _paymentRows[i].method?.name, onTap: () => _pickPaymentMethodForRow(i)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: _paymentRows[i].amountController,
                          hint: '0',
                          prefix: 'Rs',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (_paymentRows.length > 1) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: () => _removePaymentRow(i),
                          icon: const Icon(Icons.close, color: AppTheme.cancelled, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 48),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Remaining', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                  Text(
                    'Rs ${_remaining > 0 ? _remaining.toStringAsFixed(0) : 0}',
                    style: TextStyle(color: _remaining > 0 ? AppTheme.pending : AppTheme.completed, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isCompleting ? null : _complete,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.completed, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: provider.isCompleting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(
                      _remaining > 0 ? 'Record Partial Payment' : 'Complete Checkout',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final bool emphasize;

  const _SummaryRow({required this.label, required this.value, this.isLast = false, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppTheme.divider))),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
              fontSize: emphasize ? 16 : 14,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
