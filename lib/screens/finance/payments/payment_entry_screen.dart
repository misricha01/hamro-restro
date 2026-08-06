import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/finance_form_fields.dart';
import '../../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;
import '../../create_dish/add_dish_screen.dart' show ImageSourceSheet;

/// Shared "Payment In" / "Payment Out" form reached from [PaymentsScreen]'s
/// bottom CTAs, matching the reference design's Amount / Payment Account /
/// Parties / Remarks / Date / Attachment / Allocations layout — reusing the
/// same field widgets as Add Income / Add Expense instead of duplicating them.
class PaymentEntryScreen extends StatefulWidget {
  final bool isPaymentIn;

  const PaymentEntryScreen({super.key, required this.isPaymentIn});

  @override
  State<PaymentEntryScreen> createState() => _PaymentEntryScreenState();
}

class _PaymentEntryScreenState extends State<PaymentEntryScreen> {
  final _amountController = TextEditingController();
  final _partyNameController = TextEditingController();
  final _remarksController = TextEditingController();
  final _advanceController = TextEditingController();

  String? _selectedPaymentMethod;
  int _partyTypeIndex = 0;
  String? _selectedImageSource;
  DateTime _selectedDate = DateTime.now();

  bool _amountError = false;
  bool _paymentMethodError = false;

  static const _partyTypes = ['Customer', 'Staff', 'Suppliers'];

  @override
  void dispose() {
    _amountController.dispose();
    _partyNameController.dispose();
    _remarksController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await ImageSourceSheet.show(context, includeLibrary: false);
    if (result != null) setState(() => _selectedImageSource = result);
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() => _selectedDate = result);
  }

  void _save() {
    setState(() {
      _amountError = _amountController.text.trim().isEmpty;
      _paymentMethodError = _selectedPaymentMethod == null;
    });
    if (_amountError || _paymentMethodError) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isPaymentIn ? 'Payment In' : 'Payment Out';
    final partyHint = switch (_partyTypeIndex) {
      1 => 'Enter Staff Name',
      2 => 'Enter Supplier Name',
      _ => 'Enter Customer Name',
    };

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
          title,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FieldLabel(label: 'Amount', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _amountController,
            hint: '00.00',
            prefix: 'Rs',
            keyboardType: TextInputType.number,
            errorText: _amountError ? 'Required' : null,
            onChanged: (v) {
              if (_amountError && v.trim().isNotEmpty) setState(() => _amountError = false);
            },
          ),
          const SizedBox(height: 20),

          FieldLabel(label: 'Payment Account', required: true),
          const SizedBox(height: 8),
          PaymentMethodChipGroup(
            selected: _selectedPaymentMethod,
            onSelected: (label) => setState(() {
              _selectedPaymentMethod = label;
              _paymentMethodError = false;
            }),
          ),
          if (_paymentMethodError) ...[
            const SizedBox(height: 8),
            const Text('Required', style: TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none)),
          ],
          const SizedBox(height: 20),

          FieldLabel(label: 'Parties', required: true),
          const SizedBox(height: 8),
          ThreeWaySegment(
            labels: _partyTypes,
            selectedIndex: _partyTypeIndex,
            onChanged: (i) => setState(() => _partyTypeIndex = i),
          ),
          const SizedBox(height: 12),
          PartySearchField(controller: _partyNameController, hint: partyHint),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Remarks', required: false),
          const SizedBox(height: 8),
          AppTextField(controller: _remarksController, hint: 'Enter your remarks'),
          const SizedBox(height: 20),

          const Text('Date', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          AppDateField(date: _selectedDate, onTap: _pickDate),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Attachment', required: false),
          const SizedBox(height: 8),
          UploadBox(
            label: _selectedImageSource == null ? 'Tap here to select or upload photos' : 'Selected via ${_selectedImageSource!}',
            onTap: _pickAttachment,
          ),
          const SizedBox(height: 20),

          Row(
            children: const [
              Text('Allocations ', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
              Text('(Unpaid Transactions)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Book as Advance', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                ),
                SizedBox(
                  width: 110,
                  child: AppTextField(controller: _advanceController, hint: '00.00', prefix: 'Rs', keyboardType: TextInputType.number),
                ),
              ],
            ),
          ),
          const SizedBox(height: 220, child: InvoiceEmptyState(entityName: 'Allocations')),
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
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Save Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
