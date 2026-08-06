import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/finance_form_fields.dart';
import '../../create_dish/add_dish_screen.dart' show ImageSourceSheet;
import 'cash_bank_models.dart';

/// "Transfer Balance" screen reached from Cash & Banks' Balance Transfer tab,
/// matching the reference design's From / Amount / To / Transaction Date /
/// Remarks / Attachment layout.
class TransferBalanceScreen extends StatefulWidget {
  const TransferBalanceScreen({super.key});

  @override
  State<TransferBalanceScreen> createState() => _TransferBalanceScreenState();
}

class _TransferBalanceScreenState extends State<TransferBalanceScreen> {
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _fromAccount;
  String? _toAccount;
  String? _selectedImageSource;
  DateTime _selectedDate = DateTime.now();

  bool _fromError = false;
  bool _toError = false;
  bool _amountError = false;

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickFromAccount() async {
    final result = await SearchSelectSheet.show(context, title: 'Select Account', items: cashBankAccounts.map((a) => a.name).toList(), countLabel: 'Total Accounts');
    if (result != null) {
      setState(() {
        _fromAccount = result;
        _fromError = false;
      });
    }
  }

  Future<void> _pickToAccount() async {
    final result = await SearchSelectSheet.show(context, title: 'Select Account', items: cashBankAccounts.map((a) => a.name).toList(), countLabel: 'Total Accounts');
    if (result != null) {
      setState(() {
        _toAccount = result;
        _toError = false;
      });
    }
  }

  Future<void> _pickAttachment() async {
    final result = await ImageSourceSheet.show(context, includeLibrary: false);
    if (result != null) setState(() => _selectedImageSource = result);
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (result != null) setState(() => _selectedDate = result);
  }

  void _save() {
    setState(() {
      _fromError = _fromAccount == null;
      _toError = _toAccount == null;
      _amountError = _amountController.text.trim().isEmpty;
    });
    if (_fromError || _toError || _amountError) return;
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
          'Transfer Balance',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FieldLabel(label: 'From', required: true),
          const SizedBox(height: 8),
          SelectField(hint: 'Select Account', value: _fromAccount, onTap: _pickFromAccount, errorText: _fromError ? 'Required' : null),
          const SizedBox(height: 20),

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

          FieldLabel(label: 'To', required: true),
          const SizedBox(height: 8),
          SelectField(hint: 'Select Account', value: _toAccount, onTap: _pickToAccount, errorText: _toError ? 'Required' : null),
          const SizedBox(height: 20),

          const Text('Transaction Date', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          AppDateField(date: _selectedDate, onTap: _pickDate),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Remarks', required: false),
          const SizedBox(height: 8),
          AppTextField(controller: _remarksController, hint: 'Enter your remarks'),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Attachment', required: false),
          const SizedBox(height: 8),
          UploadBox(
            label: _selectedImageSource == null ? 'Tap here to select or upload photos' : 'Selected via ${_selectedImageSource!}',
            onTap: _pickAttachment,
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
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
