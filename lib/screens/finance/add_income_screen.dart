import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/finance_form_fields.dart';
import '../create_dish/add_dish_screen.dart' show ImageSourceSheet;

/// Account head entry used by [AccountHeadSheet]. Public so other Finance
/// quick-action screens (e.g. Add Purchase's item details) can reuse the
/// same picker instead of duplicating it.
class AccountHeadItem {
  final String name;
  final String type;
  AccountHeadItem(this.name, this.type);
}

/// Result returned by [AddAccountHeadScreen]. [name] is always populated;
/// the rest are only set when the screen was opened with `fullForm: true`
/// (from Chart of Accounts) — callers that only care about the name (e.g.
/// [AccountHeadSheet]) can keep reading just `.name`.
class AccountHeadFormResult {
  final String name;
  final String? parent;
  final String? group;
  final String? subGroup;
  final String? description;
  final double? openingBalance;
  final bool isCredit;

  const AccountHeadFormResult({
    required this.name,
    this.parent,
    this.group,
    this.subGroup,
    this.description,
    this.openingBalance,
    this.isCredit = false,
  });
}

/// Parent Account Head options offered by the Chart of Accounts "Add Account
/// Head" form's Parent picker.
const List<String> kDefaultAccountHeadParents = ['Equity', 'Asset', 'Liability', 'Income', 'Expense'];

/// Group options available once a given Parent is selected — mirrors the
/// same Asset/Liability/Income/Expense/Equity taxonomy already used by the
/// Trial Balance and Account Summary reports.
const Map<String, List<String>> kDefaultAccountHeadGroupsByParent = {
  'Equity': ['Capital', 'Reserve and Surplus'],
  'Asset': ['Current Assets', 'Non Current Assets'],
  'Liability': ['Current Liability', 'Non Current Liability'],
  'Income': ['Direct Income', 'Indirect Income'],
  'Expense': ['Direct Expenses', 'Indirect Expenses'],
};

final List<AccountHeadItem> _incomeAccountHeads = [
  AccountHeadItem('Gross Sales', 'Income'),
  AccountHeadItem('Dish Discount', 'Income'),
  AccountHeadItem('Loyalty Discount', 'Income'),
  AccountHeadItem('Sales Discount', 'Income'),
  AccountHeadItem('Sales Return', 'Income'),
  AccountHeadItem('Service Charge', 'Income'),
  AccountHeadItem('Tips', 'Income'),
  AccountHeadItem('Rental Income', 'Income'),
  AccountHeadItem('Sales Commission', 'Income'),
  AccountHeadItem('Bank Interest Income', 'Income'),
];

/// Public: for Add Purchase's item-level account-head picker, once that
/// screen gets a backend line-item concept to attach it to (the current
/// `/api/purchase-bill` DTO is bill-level only — see add_purchase_screen.dart).
final List<AccountHeadItem> purchaseAccountHeads = [
  AccountHeadItem('Raw Material Purchase', 'Purchase'),
  AccountHeadItem('Packaging Purchase', 'Purchase'),
  AccountHeadItem('Kitchen Equipment', 'Purchase'),
  AccountHeadItem('Kitchen Supplies', 'Purchase'),
  AccountHeadItem('Beverage Purchase', 'Purchase'),
  AccountHeadItem('Others', 'Purchase'),
];

class AccountHeadSheet extends StatefulWidget {
  final List<AccountHeadItem> items;
  final String? typeLabel;

  const AccountHeadSheet({super.key, required this.items, this.typeLabel});

  static Future<String?> show(BuildContext context, {required List<AccountHeadItem> items, String? typeLabel}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AccountHeadSheet(items: items, typeLabel: typeLabel),
    );
  }

  @override
  State<AccountHeadSheet> createState() => _AccountHeadSheetState();
}

class _AccountHeadSheetState extends State<AccountHeadSheet> {
  final TextEditingController _searchController = TextEditingController();

  List<AccountHeadItem> get _filtered {
    if (_searchController.text.isEmpty) return widget.items;
    return widget.items
        .where((i) => i.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Head',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search here',
                          hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : GestureDetector(
                                  onTap: () => setState(() => _searchController.clear()),
                                  child: const Icon(Icons.close, color: AppTheme.cancelled, size: 20),
                                ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, item.name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.divider),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                  Text(item.type, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final type = widget.typeLabel ?? (widget.items.isNotEmpty ? widget.items.first.type : 'Income');
                          final result = await Navigator.of(context).push<AccountHeadFormResult>(
                            MaterialPageRoute(builder: (context) => const AddAccountHeadScreen()),
                          );
                          if (result != null && context.mounted) {
                            setState(() => widget.items.add(AccountHeadItem(result.name, type)));
                            Navigator.pop(context, result.name);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Add New Account Head', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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

/// "Add Account Head" screen opened from [AccountHeadSheet]'s "Add New
/// Account Head" button (minimal Name/Description form), and — with
/// `fullForm: true` — from the Chart of Accounts screen, which additionally
/// needs Parent/Group/Sub Group/Opening Balance. The Group field only
/// activates once a Parent is chosen (tapping it earlier shows a validation
/// message instead of opening the picker), and Opening Balance stays hidden
/// entirely until a Parent is picked. Returns an [AccountHeadFormResult] via
/// [Navigator.pop] once saved.
class AddAccountHeadScreen extends StatefulWidget {
  final bool fullForm;
  final List<String> parentOptions;
  final Map<String, List<String>> groupOptionsByParent;

  const AddAccountHeadScreen({
    super.key,
    this.fullForm = false,
    this.parentOptions = kDefaultAccountHeadParents,
    this.groupOptionsByParent = kDefaultAccountHeadGroupsByParent,
  });

  @override
  State<AddAccountHeadScreen> createState() => _AddAccountHeadScreenState();
}

class _AddAccountHeadScreenState extends State<AddAccountHeadScreen> {
  static const _descriptionMaxLength = 75;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subGroupController = TextEditingController();
  final _openingBalanceController = TextEditingController();

  bool _nameError = false;
  bool _parentError = false;
  bool _groupError = false;
  String? _groupBlockedMessage;

  String? _parent;
  String? _group;
  bool _isCredit = false;
  bool _isDirty = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _subGroupController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _reset() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _subGroupController.clear();
      _openingBalanceController.clear();
      _parent = null;
      _group = null;
      _isCredit = false;
      _nameError = false;
      _parentError = false;
      _groupError = false;
      _groupBlockedMessage = null;
      _isDirty = false;
    });
  }

  Future<void> _pickParent() async {
    final result = await SimpleListSheet.show(context, title: 'Select Parent', items: widget.parentOptions);
    if (result != null && result != _parent) {
      setState(() {
        _parent = result;
        _parentError = false;
        // Group options depend on the Parent, so a Parent change clears
        // whatever Group was previously chosen.
        _group = null;
        _groupError = false;
        _groupBlockedMessage = null;
        _isDirty = true;
      });
    }
  }

  Future<void> _onGroupTap() async {
    if (_parent == null) {
      setState(() => _groupBlockedMessage = 'Please select Account Head Parent.');
      return;
    }
    final options = widget.groupOptionsByParent[_parent] ?? const [];
    final result = await SimpleListSheet.show(context, title: 'Select Group', items: options);
    if (result != null) {
      setState(() {
        _group = result;
        _groupError = false;
        _groupBlockedMessage = null;
        _isDirty = true;
      });
    }
  }

  void _save() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      if (widget.fullForm) {
        _parentError = _parent == null;
        _groupError = _group == null;
      }
    });
    if (_nameError || _parentError || _groupError) return;
    Navigator.pop(
      context,
      AccountHeadFormResult(
        name: _nameController.text.trim(),
        parent: _parent,
        group: _group,
        subGroup: _subGroupController.text.trim().isEmpty ? null : _subGroupController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        openingBalance: double.tryParse(_openingBalanceController.text.trim()),
        isCredit: _isCredit,
      ),
    );
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
          'Add Account Head',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FieldLabel(label: 'Name', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _nameController,
            hint: 'Enter Account Head',
            errorText: _nameError ? 'Required' : null,
            onChanged: (v) {
              _markDirty();
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),

          if (widget.fullForm) ...[
            FieldLabel(label: 'Parent', required: true),
            const SizedBox(height: 8),
            SelectField(
              hint: 'Select Parent',
              value: _parent,
              onTap: _pickParent,
              errorText: _parentError ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            FieldLabel(label: 'Group', required: true),
            const SizedBox(height: 8),
            SelectField(
              hint: 'Select Group',
              value: _group,
              onTap: _onGroupTap,
              errorText: _groupBlockedMessage ?? (_groupError ? 'Required' : null),
            ),
            const SizedBox(height: 20),

            if (_parent != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel(label: 'Opening Balance', required: false),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _openingBalanceController,
                          hint: 'Enter Opening Balance',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _markDirty(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Is Credit', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                        const SizedBox(height: 8),
                        _DrCrToggle(isCredit: _isCredit, onChanged: (v) => setState(() {
                          _isCredit = v;
                          _isDirty = true;
                        })),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            const Text('Sub Group', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
            const SizedBox(height: 8),
            AppTextField(controller: _subGroupController, hint: 'Enter Sub Group', onChanged: (_) => _markDirty()),
            const SizedBox(height: 20),
          ],

          Row(
            children: [
              const Text('Description', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
              const Spacer(),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _descriptionController,
                builder: (context, value, _) => Text(
                  '${_descriptionMaxLength - value.text.length}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLength: _descriptionMaxLength,
            maxLines: 3,
            onChanged: (_) => _markDirty(),
            style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
            decoration: InputDecoration(
              hintText: 'Enter Description',
              hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
              counterText: '',
              filled: true,
              fillColor: AppTheme.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
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
                onPressed: _isDirty ? _reset : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  _isDirty ? 'Reset' : 'Back',
                  style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Save Account Head', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Dr / Cr" opening-balance toggle shown by [AddAccountHeadScreen]'s full
/// form once a Parent is picked — two standalone chips (unlike
/// [TwoWaySegment]'s single joined bar) matching the reference design.
class _DrCrToggle extends StatelessWidget {
  final bool isCredit;
  final ValueChanged<bool> onChanged;
  const _DrCrToggle({required this.isCredit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DrCrChip(label: 'Dr', selected: !isCredit, onTap: () => onChanged(false)),
        const SizedBox(width: 10),
        _DrCrChip(label: 'Cr', selected: isCredit, onTap: () => onChanged(true)),
      ],
    );
  }
}

class _DrCrChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DrCrChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.cancelled : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.cancelled : AppTheme.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.cancelled,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

/// Shared "Amount / Account Head / Paid-or-Received Account / Parties" form
/// used by Add Income, Add Expense, and Add Purchase — the three Finance
/// quick actions follow the same layout, differing only in copy, the
/// account-head list offered, and the default selected party.
class _FinanceEntryScreen extends StatefulWidget {
  final String title;
  final String accountSectionLabel;
  final List<AccountHeadItem> accountHeadItems;
  final String infoBannerText;
  final String saveButtonLabel;

  const _FinanceEntryScreen({
    required this.title,
    required this.accountSectionLabel,
    required this.accountHeadItems,
    required this.infoBannerText,
    required this.saveButtonLabel,
  });

  @override
  State<_FinanceEntryScreen> createState() => _FinanceEntryScreenState();
}

class _FinanceEntryScreenState extends State<_FinanceEntryScreen> {
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  final _partyNameController = TextEditingController();
  final _referenceController = TextEditingController();

  String? _accountHead;
  bool _isPaid = true;
  String? _selectedPaymentMethod;
  bool _multiplePayment = false;
  late int _partyTypeIndex;
  String? _selectedImageSource;
  DateTime _selectedDate = DateTime.now();

  bool _amountError = false;
  bool _accountHeadError = false;
  bool _paymentMethodError = false;

  bool _isDirty = false;

  final List<String> _partyTypes = ['Customer', 'Staff', 'Suppliers'];

  @override
  void initState() {
    super.initState();
    _partyTypeIndex = 0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    _partyNameController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _pickAccountHead() async {
    final result = await AccountHeadSheet.show(context, items: widget.accountHeadItems);
    if (result != null) {
      setState(() {
        _accountHead = result;
        _accountHeadError = false;
        _isDirty = true;
      });
    }
  }

  Future<void> _pickAttachment() async {
    final result = await ImageSourceSheet.show(context, includeLibrary: false);
    if (result != null) setState(() => _selectedImageSource = result);
    _markDirty();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() {
        _selectedDate = result;
        _isDirty = true;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _amountController.clear();
      _remarksController.clear();
      _partyNameController.clear();
      _referenceController.clear();
      _accountHead = null;
      _isPaid = true;
      _selectedPaymentMethod = null;
      _multiplePayment = false;
      _partyTypeIndex = 0;
      _selectedImageSource = null;
      _selectedDate = DateTime.now();
      _amountError = false;
      _accountHeadError = false;
      _paymentMethodError = false;
      _isDirty = false;
    });
  }

  void _save() {
    setState(() {
      _amountError = _amountController.text.trim().isEmpty;
      _accountHeadError = _accountHead == null;
      _paymentMethodError = _selectedPaymentMethod == null;
    });
    if (_amountError || _accountHeadError || _paymentMethodError) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          widget.title,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
              _markDirty();
              if (_amountError && v.trim().isNotEmpty) setState(() => _amountError = false);
            },
          ),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Remarks', required: false),
          const SizedBox(height: 8),
          AppTextField(controller: _remarksController, hint: 'Enter your remarks', onChanged: (_) => _markDirty()),
          const SizedBox(height: 20),

          FieldLabel(label: 'Account Head', required: true),
          const SizedBox(height: 8),
          SelectField(
            hint: 'Select Account Head',
            value: _accountHead,
            onTap: _pickAccountHead,
            errorText: _accountHeadError ? 'Required' : null,
          ),
          const SizedBox(height: 20),

          FieldLabel(label: widget.accountSectionLabel, required: true),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _paymentMethodError ? AppTheme.cancelled : AppTheme.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TwoWaySegment(
                  leftLabel: 'Paid',
                  rightLabel: 'Unpaid / Credit',
                  isLeftSelected: _isPaid,
                  onChanged: (isLeft) => setState(() {
                    _isPaid = isLeft;
                    _isDirty = true;
                  }),
                ),
                const SizedBox(height: 14),
                PaymentMethodChipGroup(
                  selected: _selectedPaymentMethod,
                  onSelected: (label) => setState(() {
                    _selectedPaymentMethod = label;
                    _paymentMethodError = false;
                    _isDirty = true;
                  }),
                ),
                if (_paymentMethodError) ...[
                  const SizedBox(height: 8),
                  const Text('Required', style: TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none)),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('Multiple Payment', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                    const SizedBox(width: 6),
                    const Icon(Icons.help_outline, color: AppTheme.textSecondary, size: 16),
                    const Spacer(),
                    Switch(
                      value: _multiplePayment,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppTheme.accent,
                      onChanged: (v) => setState(() {
                        _multiplePayment = v;
                        _isDirty = true;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF241F3D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Color(0xFFC9BFFF), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.infoBannerText,
                          style: const TextStyle(color: Color(0xFFC9BFFF), fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Parties', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          ThreeWaySegment(
            labels: _partyTypes,
            selectedIndex: _partyTypeIndex,
            onChanged: (i) => setState(() {
              _partyTypeIndex = i;
              _isDirty = true;
            }),
          ),
          const SizedBox(height: 12),
          PartySearchField(controller: _partyNameController, hint: partyHint, onChanged: (_) => _markDirty()),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Attachment', required: false),
          const SizedBox(height: 8),
          UploadBox(
            label: _selectedImageSource == null ? 'Tap here to select or upload photos' : 'Selected via ${_selectedImageSource!}',
            onTap: _pickAttachment,
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reference No:', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                    const SizedBox(height: 8),
                    AppTextField(controller: _referenceController, hint: 'Enter number', onChanged: (_) => _markDirty()),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                    const SizedBox(height: 8),
                    AppDateField(date: _selectedDate, onTap: _pickDate),
                  ],
                ),
              ),
            ],
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
                onPressed: _isDirty ? _resetForm : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  _isDirty ? 'Reset' : 'Back',
                  style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text(widget.saveButtonLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddIncomeScreen extends StatelessWidget {
  const AddIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _FinanceEntryScreen(
      title: 'Add Income',
      accountSectionLabel: 'Received Account',
      accountHeadItems: _incomeAccountHeads,
      infoBannerText: 'Turn this ON, if customer pay via Multiple payment mode or make Partial payments.',
      saveButtonLabel: 'Save Income',
    );
  }
}

