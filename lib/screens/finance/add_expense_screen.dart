import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/expense/expense_model.dart';
import '../../data/models/payment_method/payment_method_model.dart';
import '../../providers/expense_category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/payment_method_provider.dart';
import '../../widgets/common/finance_form_fields.dart';

/// "Add Expense" — real form matching the backend's `/api/expenses` DTO
/// exactly: Title, Category (real `/api/expense-category`, inline create),
/// Amount, Expense/Payment/Due dates, Payment Status, Payment Method (real
/// `/api/payment-method`), Description. Replaces the previous local-only
/// "Account Head / Parties / Reference No" mockup, which had no backend
/// equivalent and saved nothing.
///
/// Also doubles as the edit form when [existingExpense] is passed — the
/// category/payment-method pickers need real [ExpenseCategory]/[PaymentMode]
/// objects to prefill, not just ids, so those are reconstructed directly
/// from [Expense.categoryName]/[Expense.paymentMethodName] rather than
/// re-resolving by id against a provider list.
class AddExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  const AddExpenseScreen({super.key, this.existingExpense});

  bool get isEditing => existingExpense != null;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExpenseCategory? _category;
  PaymentMode? _paymentMethod;
  bool _isPaid = true;
  DateTime _expenseDate = DateTime.now();
  DateTime _paymentDate = DateTime.now();
  DateTime _dueDate = DateTime.now();

  bool _titleError = false;
  bool _amountError = false;
  bool _categoryError = false;
  bool _paymentMethodError = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.existingExpense;
    if (expense == null) return;
    _titleController.text = expense.title;
    _amountController.text = expense.amount == expense.amount.roundToDouble() ? expense.amount.toStringAsFixed(0) : expense.amount.toString();
    _descriptionController.text = expense.description ?? '';
    _category = ExpenseCategory(id: expense.categoryId, name: expense.categoryName ?? 'Category');
    _paymentMethod = PaymentMode(id: expense.paymentMethodId, name: expense.paymentMethodName ?? 'Payment Method');
    _isPaid = expense.paymentStatus.toLowerCase() == 'paid';
    _expenseDate = expense.expenseDate ?? DateTime.now();
    _paymentDate = expense.paymentDate ?? DateTime.now();
    _dueDate = expense.dueDate ?? DateTime.now();

    // The already-listed [expense] doesn't carry real category/payment-method
    // ids (`GET /api/expenses` omits those relations, unlike the single-item
    // fetch — confirmed live) — refresh from the full detail so the picker
    // fields above aren't silently wrong if the user doesn't reselect them.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final detail = await context.read<ExpenseProvider>().fetchExpenseDetail(expense.id);
      if (detail == null || !mounted) return;
      setState(() {
        _category = ExpenseCategory(id: detail.categoryId, name: detail.categoryName ?? _category?.name ?? 'Category');
        _paymentMethod = PaymentMode(id: detail.paymentMethodId, name: detail.paymentMethodName ?? _paymentMethod?.name ?? 'Payment Method');
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final result = await SelectExpenseCategorySheet.show(context);
    if (result != null) {
      setState(() {
        _category = result;
        _categoryError = false;
      });
    }
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

  Future<void> _pickDate(DateTime initial, ValueChanged<DateTime> onPicked) async {
    final result = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (result != null) setState(() => onPicked(result));
  }

  Future<void> _save() async {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty;
      _amountError = double.tryParse(_amountController.text.trim()) == null;
      _categoryError = _category == null;
      _paymentMethodError = _paymentMethod == null;
    });
    if (_titleError || _amountError || _categoryError || _paymentMethodError) return;

    final provider = context.read<ExpenseProvider>();
    final description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();
    final expense = widget.isEditing
        ? await provider.updateExpense(
            id: widget.existingExpense!.id,
            title: _titleController.text.trim(),
            categoryId: _category!.id,
            amount: double.parse(_amountController.text.trim()),
            expenseDate: AppDateField.format(_expenseDate),
            paymentDate: AppDateField.format(_paymentDate),
            dueDate: AppDateField.format(_dueDate),
            paymentStatus: _isPaid ? 'paid' : 'unpaid',
            paymentMethodId: _paymentMethod!.id,
            description: description,
          )
        : await provider.createExpense(
            title: _titleController.text.trim(),
            categoryId: _category!.id,
            amount: double.parse(_amountController.text.trim()),
            expenseDate: AppDateField.format(_expenseDate),
            paymentDate: AppDateField.format(_paymentDate),
            dueDate: AppDateField.format(_dueDate),
            paymentStatus: _isPaid ? 'paid' : 'unpaid',
            paymentMethodId: _paymentMethod!.id,
            description: description,
          );
    if (!mounted) return;
    if (expense != null) {
      Navigator.pop(context, expense);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
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
        title: Text(widget.isEditing ? 'Edit Expense' : 'Add Expense', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FieldLabel(label: 'Title', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _titleController,
            hint: 'e.g. Fuel refill',
            errorText: _titleError ? 'Required' : null,
            onChanged: (v) {
              if (_titleError && v.trim().isNotEmpty) setState(() => _titleError = false);
            },
          ),
          const SizedBox(height: 20),

          FieldLabel(label: 'Category', required: true),
          const SizedBox(height: 8),
          SelectField(hint: 'Select Category', value: _category?.name, onTap: _pickCategory, errorText: _categoryError ? 'Required' : null),
          const SizedBox(height: 20),

          FieldLabel(label: 'Amount', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _amountController,
            hint: '00.00',
            prefix: 'Rs',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _amountError ? 'Enter a valid amount' : null,
            onChanged: (v) {
              if (_amountError && double.tryParse(v.trim()) != null) setState(() => _amountError = false);
            },
          ),
          const SizedBox(height: 20),

          FieldLabel(label: 'Payment Method', required: true),
          const SizedBox(height: 8),
          SelectField(hint: 'Select Payment Method', value: _paymentMethod?.name, onTap: _pickPaymentMethod, errorText: _paymentMethodError ? 'Required' : null),
          const SizedBox(height: 20),

          const Text('Payment Status', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TwoWaySegment(leftLabel: 'Paid', rightLabel: 'Unpaid', isLeftSelected: _isPaid, onChanged: (v) => setState(() => _isPaid = v)),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expense Date', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                    const SizedBox(height: 8),
                    AppDateField(date: _expenseDate, onTap: () => _pickDate(_expenseDate, (d) => _expenseDate = d)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Date', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                    const SizedBox(height: 8),
                    AppDateField(date: _paymentDate, onTap: () => _pickDate(_paymentDate, (d) => _paymentDate = d)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Due Date', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          AppDateField(date: _dueDate, onTap: () => _pickDate(_dueDate, (d) => _dueDate = d)),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Description', required: false),
          const SizedBox(height: 8),
          AppTextField(controller: _descriptionController, hint: 'Enter notes', maxLines: 3),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (widget.isEditing ? provider.isUpdating : provider.isCreating) ? null : _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: (widget.isEditing ? provider.isUpdating : provider.isCreating)
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.isEditing ? 'Update Expense' : 'Save Expense', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }
}

// ---------------- Expense Category picker ----------------

/// Picker for an [ExpenseCategory], sourced live from
/// [ExpenseCategoryProvider] (backend: `/api/expense-category`), with an
/// inline "Create Category" action for when the desired category doesn't
/// exist yet.
class SelectExpenseCategorySheet extends StatefulWidget {
  const SelectExpenseCategorySheet({super.key});

  static Future<ExpenseCategory?> show(BuildContext context) {
    return showModalBottomSheet<ExpenseCategory>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectExpenseCategorySheet(),
    );
  }

  @override
  State<SelectExpenseCategorySheet> createState() => _SelectExpenseCategorySheetState();
}

class _SelectExpenseCategorySheetState extends State<SelectExpenseCategorySheet> {
  final _searchController = TextEditingController();
  final _newCategoryNameController = TextEditingController();
  bool _showCreateField = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ExpenseCategoryProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchExpenseCategories());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newCategoryNameController.dispose();
    super.dispose();
  }

  List<ExpenseCategory> _filter(List<ExpenseCategory> categories) {
    if (_searchController.text.isEmpty) return categories;
    return categories.where((c) => c.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  Future<void> _createCategory() async {
    final name = _newCategoryNameController.text.trim();
    if (name.isEmpty) return;
    final provider = context.read<ExpenseCategoryProvider>();
    final category = await provider.createExpenseCategory(name: name);
    if (!mounted) return;
    if (category != null) {
      Navigator.pop(context, category);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.createErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseCategoryProvider>();
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
                      const Text('Select Category', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Search here',
                            hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                            prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildBody(provider, scrollController)),
                      const SizedBox(height: 12),
                      if (_showCreateField) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newCategoryNameController,
                                style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                                decoration: InputDecoration(
                                  hintText: 'New category name',
                                  hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                                  filled: true,
                                  fillColor: AppTheme.card,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: provider.isCreating ? null : _createCategory,
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: provider.isCreating
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                            ),
                          ],
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _showCreateField = true),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            icon: const Icon(Icons.add, color: AppTheme.textPrimary, size: 18),
                            label: const Text('Create Category', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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

  Widget _buildBody(ExpenseCategoryProvider provider, ScrollController scrollController) {
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
                  onPressed: () => context.read<ExpenseCategoryProvider>().fetchExpenseCategories(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final filtered = _filter(provider.categories);
        if (provider.categories.isEmpty) {
          return const Center(child: Text('No Expense Categories created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)));
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = filtered[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.category_outlined, color: AppTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(category.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            );
          },
        );
    }
  }
}

// ---------------- Payment Method picker ----------------

/// Picker for a [PaymentMode], sourced live from [PaymentMethodProvider]
/// (backend: `/api/payment-method`) — the same list managed on Cash &
/// Banks' Modes tab.
class SelectPaymentMethodSheet extends StatefulWidget {
  const SelectPaymentMethodSheet({super.key});

  static Future<PaymentMode?> show(BuildContext context) {
    return showModalBottomSheet<PaymentMode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectPaymentMethodSheet(),
    );
  }

  @override
  State<SelectPaymentMethodSheet> createState() => _SelectPaymentMethodSheetState();
}

class _SelectPaymentMethodSheetState extends State<SelectPaymentMethodSheet> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<PaymentMethodProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchPaymentMethods());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentMethodProvider>();
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
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
                      const Text('Select Payment Method', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                      const SizedBox(height: 16),
                      Expanded(child: _buildBody(provider, scrollController)),
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

  Widget _buildBody(PaymentMethodProvider provider, ScrollController scrollController) {
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
                  onPressed: () => context.read<PaymentMethodProvider>().fetchPaymentMethods(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.methods.isEmpty) {
          return const Center(child: Text('No Payment Methods created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)));
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: provider.methods.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final method = provider.methods[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, method),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(method.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            );
          },
        );
    }
  }
}
