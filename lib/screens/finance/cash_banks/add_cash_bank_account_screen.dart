import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/finance_form_fields.dart';
import '../../create_dish/add_dish_screen.dart' show ImageSourceSheet;
import 'add_payment_mode_screen.dart';
import 'cash_bank_models.dart';

/// "Add Account" screen reached from Cash & Banks' Account tab, matching the
/// reference design's Bank / Cash / Wallet tabs. All three share the same
/// common fields (Account Name, Opening Balance, Account Photo, Select
/// Modes, Description) and only differ in the extra type-specific fields
/// shown above them, so one screen covers every account type instead of
/// three separate ones.
class AddCashBankAccountScreen extends StatefulWidget {
  const AddCashBankAccountScreen({super.key});

  @override
  State<AddCashBankAccountScreen> createState() => _AddCashBankAccountScreenState();
}

class _AddCashBankAccountScreenState extends State<AddCashBankAccountScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _accountNameController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _walletAccountNameController = TextEditingController();
  final _walletIdController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedImageSource;
  final List<String> _selectedModes = [];
  bool _accountNameError = false;

  static const _tabs = ['Bank', 'Cash', 'Wallet'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accountNameController.dispose();
    _bankAccountNameController.dispose();
    _bankAccountNumberController.dispose();
    _walletAccountNameController.dispose();
    _walletIdController.dispose();
    _openingBalanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await ImageSourceSheet.show(context, includeLibrary: false);
    if (result != null) setState(() => _selectedImageSource = result);
  }

  Future<void> _pickModes() async {
    final result = await SearchSelectSheet.show(
      context,
      title: 'Select Modes',
      items: cashBankModes.map((m) => m.label).toList(),
      countLabel: 'Total Accounts',
      actionLabel: 'Add New Mode',
      onAction: (context) => Navigator.of(context).push<String>(MaterialPageRoute(builder: (context) => const AddPaymentModeScreen())),
    );
    if (result != null) {
      setState(() {
        if (!_selectedModes.contains(result)) _selectedModes.add(result);
      });
    }
  }

  void _save() {
    setState(() => _accountNameError = _accountNameController.text.trim().isEmpty);
    if (_accountNameError) return;
    Navigator.pop(context, _accountNameController.text.trim());
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
          'Add Account',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
          unselectedLabelStyle: const TextStyle(decoration: TextDecoration.none),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final tab = _tabs[_tabController.index];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              FieldLabel(label: 'Account Name', required: true),
              const SizedBox(height: 8),
              AppTextField(
                controller: _accountNameController,
                hint: 'Enter your Account Name',
                errorText: _accountNameError ? 'Required' : null,
                onChanged: (v) {
                  if (_accountNameError && v.trim().isNotEmpty) setState(() => _accountNameError = false);
                },
              ),
              const SizedBox(height: 20),

              if (tab == 'Bank') ...[
                const FieldLabel(label: 'Bank Account Name', required: false),
                const SizedBox(height: 8),
                AppTextField(controller: _bankAccountNameController, hint: 'Enter your Bank Account Name'),
                const SizedBox(height: 20),
                const FieldLabel(label: 'Bank Account Number', required: false),
                const SizedBox(height: 8),
                AppTextField(controller: _bankAccountNumberController, hint: 'Enter Bank Account Number', keyboardType: TextInputType.number),
                const SizedBox(height: 20),
              ] else if (tab == 'Wallet') ...[
                const FieldLabel(label: 'Wallet Account Name', required: false),
                const SizedBox(height: 8),
                AppTextField(controller: _walletAccountNameController, hint: 'Enter your Wallet Account Name'),
                const SizedBox(height: 20),
                const FieldLabel(label: 'Wallet Id', required: false),
                const SizedBox(height: 8),
                AppTextField(controller: _walletIdController, hint: 'Enter Wallet Id'),
                const SizedBox(height: 20),
              ],

              const FieldLabel(label: 'Opening Balance', required: false),
              const SizedBox(height: 8),
              AppTextField(controller: _openingBalanceController, hint: '00.00', prefix: 'Rs', keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              const FieldLabel(label: 'Account Photo', required: false),
              const SizedBox(height: 8),
              UploadBox(
                label: _selectedImageSource == null ? 'Tap here to select or upload photos' : 'Selected via ${_selectedImageSource!}',
                onTap: _pickPhoto,
              ),
              const SizedBox(height: 20),

              const FieldLabel(label: 'Select Modes', required: false),
              const SizedBox(height: 8),
              SelectField(
                hint: 'Select Modes',
                value: _selectedModes.isEmpty ? null : _selectedModes.join(', '),
                onTap: _pickModes,
              ),
              const SizedBox(height: 20),

              const FieldLabel(label: 'Description', required: false),
              const SizedBox(height: 8),
              AppTextField(controller: _descriptionController, hint: 'Enter Description'),
            ],
          );
        },
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
                child: const Text('Save Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
