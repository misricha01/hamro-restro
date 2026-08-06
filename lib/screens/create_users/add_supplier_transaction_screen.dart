import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/payment_method/payment_method_model.dart';
import '../../providers/supplier_transaction_provider.dart';
import '../../widgets/common/finance_form_fields.dart';
import '../finance/add_expense_screen.dart' show SelectPaymentMethodSheet;

/// "Add Transaction" — real form matching the backend's
/// `/api/supplier-transaction` DTO: Particulars, Date, To Receive / To Pay
/// (either side of the ledger, both optional), Total Payment, Payment
/// Method (real, reused from the Expense form), Remarks.
class AddSupplierTransactionScreen extends StatefulWidget {
  final String supplierId;
  const AddSupplierTransactionScreen({super.key, required this.supplierId});

  @override
  State<AddSupplierTransactionScreen> createState() => _AddSupplierTransactionScreenState();
}

class _AddSupplierTransactionScreenState extends State<AddSupplierTransactionScreen> {
  final _particularsController = TextEditingController();
  final _toReceivedController = TextEditingController();
  final _toPayController = TextEditingController();
  final _totalPaymentController = TextEditingController();
  final _remarksController = TextEditingController();

  PaymentMode? _paymentMethod;
  DateTime _date = DateTime.now();

  bool _particularsError = false;
  bool _totalPaymentError = false;
  bool _paymentMethodError = false;

  @override
  void dispose() {
    _particularsController.dispose();
    _toReceivedController.dispose();
    _toPayController.dispose();
    _totalPaymentController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickPaymentMethod() async {
    final result = await SelectPaymentMethodSheet.show(context);
    if (result != null) {
      setState(() {
        _paymentMethod = result;
        _paymentMethodError = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (result != null) setState(() => _date = result);
  }

  Future<void> _save() async {
    setState(() {
      _particularsError = _particularsController.text.trim().isEmpty;
      _totalPaymentError = double.tryParse(_totalPaymentController.text.trim()) == null;
      _paymentMethodError = _paymentMethod == null;
    });
    if (_particularsError || _totalPaymentError || _paymentMethodError) return;

    final provider = context.read<SupplierTransactionProvider>();
    final transaction = await provider.createSupplierTransaction(
      supplierId: widget.supplierId,
      date: AppDateField.format(_date),
      particulars: _particularsController.text.trim(),
      toReceived: double.tryParse(_toReceivedController.text.trim()),
      toPay: double.tryParse(_toPayController.text.trim()),
      paymentMethodId: _paymentMethod!.id,
      totalPayment: double.parse(_totalPaymentController.text.trim()),
      remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
    );
    if (!mounted) return;
    if (transaction != null) {
      Navigator.pop(context, transaction);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.createErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierTransactionProvider>();
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
        title: const Text('Add Transaction', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FieldLabel(label: 'Particulars', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _particularsController,
            hint: 'e.g. Vegetable supply for July',
            errorText: _particularsError ? 'Required' : null,
            onChanged: (v) {
              if (_particularsError && v.trim().isNotEmpty) setState(() => _particularsError = false);
            },
          ),
          const SizedBox(height: 20),

          const Text('Date', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          AppDateField(date: _date, onTap: _pickDate),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel(label: 'To Receive', required: false),
                    const SizedBox(height: 8),
                    AppTextField(controller: _toReceivedController, hint: '00.00', prefix: 'Rs', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel(label: 'To Pay', required: false),
                    const SizedBox(height: 8),
                    AppTextField(controller: _toPayController, hint: '00.00', prefix: 'Rs', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          FieldLabel(label: 'Total Payment', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _totalPaymentController,
            hint: '00.00',
            prefix: 'Rs',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _totalPaymentError ? 'Enter a valid amount' : null,
            onChanged: (v) {
              if (_totalPaymentError && double.tryParse(v.trim()) != null) setState(() => _totalPaymentError = false);
            },
          ),
          const SizedBox(height: 20),

          FieldLabel(label: 'Payment Method', required: true),
          const SizedBox(height: 8),
          SelectField(hint: 'Select Payment Method', value: _paymentMethod?.name, onTap: _pickPaymentMethod, errorText: _paymentMethodError ? 'Required' : null),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Remarks', required: false),
          const SizedBox(height: 8),
          AppTextField(controller: _remarksController, hint: 'Enter your remarks', maxLines: 3),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isCreating ? null : _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: provider.isCreating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }
}
