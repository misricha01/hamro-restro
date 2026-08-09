import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/customer/customer_model.dart';
import '../../data/models/dish/dish_model.dart';
import '../../data/models/orders/table_model.dart';
import '../../providers/customer_group_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/dish_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/table_provider.dart';

/// "Add Customer" form, backed by [CustomerProvider.createCustomer]
/// (`POST /api/customers`). Fields mirror the real backend `Customer` shape
/// confirmed via Swagger — the previous version of this form (Opening
/// Balance, Legal Name, Credit Limit/Term, Date of Birth, Address, profile
/// photo) doesn't match any real field and has been dropped. `dietaryTypeId`
/// is left out of the form for now: it's a real, distinct backend resource
/// (seen nested on a customer response) but this app has no list/create
/// endpoint for it yet, so there's nothing to build a picker against.
/// `customerGroupId` now has a real picker via [CustomerGroupProvider]
/// (backend: `/api/customer-group`).
class AddCustomerScreen extends StatefulWidget {
  final Customer? existingCustomer;

  const AddCustomerScreen({super.key, this.existingCustomer});

  bool get isEditing => existingCustomer != null;

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _panVatController = TextEditingController();
  final _discountController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _commentController = TextEditingController();

  CustomerGroup? _customerGroup;
  // Lightweight id+name pair rather than the picker's full [Dish]/
  // [RestaurantTable] type, so editing can prefill directly from the
  // customer's already-nested [FavouriteDish]/[PreferredSeating] without
  // needing to re-fetch and resolve full objects by id.
  ({String id, String name})? _favouriteDish;
  ({String id, String name})? _preferredSeating;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isDirty = false;
  bool _nameError = false;
  bool _contactError = false;

  static TimeOfDay? _parseTime(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void initState() {
    super.initState();
    final customer = widget.existingCustomer;
    if (customer != null) {
      _nameController.text = customer.customerName;
      _contactController.text = customer.phoneNumber;
      _emailController.text = customer.emailAddress ?? '';
      _companyController.text = customer.companyName ?? '';
      _panVatController.text = customer.panVatNumber ?? '';
      _discountController.text = customer.discount ?? '';
      _allergiesController.text = customer.allergies ?? '';
      _customerGroup = customer.customerGroup;
      final favouriteDish = customer.favouriteDish;
      if (favouriteDish != null) _favouriteDish = (id: favouriteDish.id, name: favouriteDish.dishName);
      final preferredSeating = customer.preferredSeating;
      if (preferredSeating != null) _preferredSeating = (id: preferredSeating.id, name: preferredSeating.tableName);
      _startTime = _parseTime(customer.startPreferredTime);
      _endTime = _parseTime(customer.endPreferredTime);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _panVatController.dispose();
    _discountController.dispose();
    _allergiesController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _pickCustomerGroup() async {
    final result = await SelectCustomerGroupSheet.show(context);
    if (result != null) {
      setState(() {
        _customerGroup = result;
        _isDirty = true;
      });
    }
  }

  Future<void> _pickFavouriteDish() async {
    final result = await SelectFavouriteDishSheet.show(context);
    if (result != null) {
      setState(() {
      _favouriteDish = (id: result.id, name: result.dishName);
      _isDirty = true;
    });
    }
  }

  Future<void> _pickPreferredSeating() async {
    final result = await SelectPreferredSeatingSheet.show(context);
    if (result != null) {
      setState(() {
      _preferredSeating = (id: result.id, name: result.tableName);
      _isDirty = true;
    });
    }
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickStartTime() async {
    final result = await showTimePicker(context: context, initialTime: _startTime ?? const TimeOfDay(hour: 18, minute: 0));
    if (result != null) {
      setState(() {
      _startTime = result;
      _isDirty = true;
    });
    }
  }

  Future<void> _pickEndTime() async {
    final result = await showTimePicker(context: context, initialTime: _endTime ?? const TimeOfDay(hour: 20, minute: 0));
    if (result != null) {
      setState(() {
      _endTime = result;
      _isDirty = true;
    });
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _contactController.clear();
      _emailController.clear();
      _companyController.clear();
      _panVatController.clear();
      _discountController.clear();
      _allergiesController.clear();
      _commentController.clear();
      _customerGroup = null;
      _favouriteDish = null;
      _preferredSeating = null;
      _startTime = null;
      _endTime = null;
      _isDirty = false;
      _nameError = false;
      _contactError = false;
    });
  }

  Future<void> _saveCustomer() async {
    final name = _nameController.text.trim();
    final phone = _contactController.text.trim();
    setState(() {
      _nameError = name.isEmpty;
      _contactError = phone.isEmpty;
    });
    if (_nameError || _contactError) return;

    final provider = context.read<CustomerProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final comment = _commentController.text.trim();
    final emailAddress = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
    final companyName = _companyController.text.trim().isEmpty ? null : _companyController.text.trim();
    final panVatNumber = _panVatController.text.trim().isEmpty ? null : _panVatController.text.trim();
    final discount = _discountController.text.trim().isEmpty ? null : _discountController.text.trim();
    final allergies = _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim();
    final startPreferredTime = _startTime == null ? null : _formatTime(_startTime!);
    final endPreferredTime = _endTime == null ? null : _formatTime(_endTime!);
    final comments = comment.isEmpty ? const <String>[] : [comment];

    final customer = widget.isEditing
        ? await provider.updateCustomer(
            id: widget.existingCustomer!.id,
            customerName: name,
            phoneNumber: phone,
            emailAddress: emailAddress,
            companyName: companyName,
            panVatNumber: panVatNumber,
            discount: discount,
            customerGroupId: _customerGroup?.id,
            favouriteDishId: _favouriteDish?.id,
            preferredSeatingId: _preferredSeating?.id,
            allergies: allergies,
            startPreferredTime: startPreferredTime,
            endPreferredTime: endPreferredTime,
            comments: comments,
          )
        : await provider.createCustomer(
            customerName: name,
            phoneNumber: phone,
            emailAddress: emailAddress,
            companyName: companyName,
            panVatNumber: panVatNumber,
            discount: discount,
            customerGroupId: _customerGroup?.id,
            favouriteDishId: _favouriteDish?.id,
            preferredSeatingId: _preferredSeating?.id,
            allergies: allergies,
            startPreferredTime: startPreferredTime,
            endPreferredTime: endPreferredTime,
            comments: comments,
          );
    if (!mounted) return;

    if (customer != null) {
      messenger.showSnackBar(SnackBar(content: Text(widget.isEditing ? 'Customer updated successfully' : 'Customer created successfully')));
      Navigator.pop(context, customer);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      messenger.showSnackBar(SnackBar(content: Text(message ?? 'Failed to save customer')));
    }
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
        title: Text(
          widget.isEditing ? 'Edit Customer' : 'Add Customer',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _FieldLabel(label: 'Customer Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Enter Customer Name',
            errorText: _nameError ? 'Customer Name is required' : null,
            onChanged: (v) {
              _markDirty();
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Contact Number', required: true),
          const SizedBox(height: 8),
          _PhoneField(
            controller: _contactController,
            errorText: _contactError ? 'Contact Number is required' : null,
            onChanged: (v) {
              _markDirty();
              if (_contactError && v.trim().isNotEmpty) setState(() => _contactError = false);
            },
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Email', required: false),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _emailController,
            hint: "Enter Customer's Email",
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Company Name', required: false),
                    const SizedBox(height: 8),
                    _AppTextField(controller: _companyController, hint: 'Enter Company Name', onChanged: (_) => _markDirty()),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'PAN/VAT Number', required: false),
                    const SizedBox(height: 8),
                    _AppTextField(controller: _panVatController, hint: 'Enter PAN/VAT Number', onChanged: (_) => _markDirty()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Discount', required: false),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _discountController,
            hint: 'Enter Discount',
            suffix: '%',
            keyboardType: TextInputType.number,
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Customer Group', required: false),
          const SizedBox(height: 8),
          _SelectField(hint: 'Select Customer Group', value: _customerGroup?.name, onTap: _pickCustomerGroup),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Favourite Dish', required: false),
          const SizedBox(height: 8),
          _SelectField(hint: 'Select Favourite Dish', value: _favouriteDish?.name, onTap: _pickFavouriteDish),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Preferred Seating', required: false),
          const SizedBox(height: 8),
          _SelectField(hint: 'Select Preferred Table', value: _preferredSeating?.name, onTap: _pickPreferredSeating),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Preferred Time (Start)', required: false),
                    const SizedBox(height: 8),
                    _TimeField(time: _startTime, hint: 'Start Time', onTap: _pickStartTime, formatTime: _formatTime),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Preferred Time (End)', required: false),
                    const SizedBox(height: 8),
                    _TimeField(time: _endTime, hint: 'End Time', onTap: _pickEndTime, formatTime: _formatTime),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Allergies', required: false),
          const SizedBox(height: 8),
          _AppTextField(controller: _allergiesController, hint: 'e.g. Peanuts, Shellfish', onChanged: (_) => _markDirty()),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Comment', required: false),
          const SizedBox(height: 8),
          _AppTextField(controller: _commentController, hint: 'e.g. Prefers window seating.', onChanged: (_) => _markDirty()),
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
              child: Consumer<CustomerProvider>(
                builder: (context, provider, _) {
                  final isSaving = widget.isEditing ? provider.isUpdating : provider.isCreating;
                  return ElevatedButton(
                    onPressed: isSaving ? null : _saveCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(widget.isEditing ? 'Update Customer' : 'Save Customer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Customer Group picker ----------------

/// Picker for a [CustomerGroup], sourced live from [CustomerGroupProvider]
/// (backend: `/api/customer-group`), with an inline "Create Group" action
/// for when the desired group doesn't exist yet.
class SelectCustomerGroupSheet extends StatefulWidget {
  const SelectCustomerGroupSheet({super.key});

  static Future<CustomerGroup?> show(BuildContext context) {
    return showModalBottomSheet<CustomerGroup>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectCustomerGroupSheet(),
    );
  }

  @override
  State<SelectCustomerGroupSheet> createState() => _SelectCustomerGroupSheetState();
}

class _SelectCustomerGroupSheetState extends State<SelectCustomerGroupSheet> {
  final _searchController = TextEditingController();
  final _newGroupNameController = TextEditingController();
  bool _showCreateField = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CustomerGroupProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchCustomerGroups());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newGroupNameController.dispose();
    super.dispose();
  }

  List<CustomerGroup> _filter(List<CustomerGroup> groups) {
    if (_searchController.text.isEmpty) return groups;
    return groups.where((g) => g.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  Future<void> _createGroup() async {
    final name = _newGroupNameController.text.trim();
    if (name.isEmpty) return;
    final provider = context.read<CustomerGroupProvider>();
    final group = await provider.createCustomerGroup(name: name);
    if (!mounted) return;
    if (group != null) {
      Navigator.pop(context, group);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.createErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerGroupProvider>();
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
                      const Text('Select Customer Group', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
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
                                controller: _newGroupNameController,
                                style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                                decoration: InputDecoration(
                                  hintText: 'New group name',
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
                              onPressed: provider.isCreating ? null : _createGroup,
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
                            label: const Text('Create Group', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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

  Widget _buildBody(CustomerGroupProvider provider, ScrollController scrollController) {
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
                  onPressed: () => context.read<CustomerGroupProvider>().fetchCustomerGroups(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final filtered = _filter(provider.groups);
        if (provider.groups.isEmpty) {
          return const Center(child: Text('No Customer Groups created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)));
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = filtered[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, group),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.groups_outlined, color: AppTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(group.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            );
          },
        );
    }
  }
}

// ---------------- Favourite Dish picker ----------------

class SelectFavouriteDishSheet extends StatefulWidget {
  const SelectFavouriteDishSheet({super.key});

  static Future<Dish?> show(BuildContext context) {
    return showModalBottomSheet<Dish>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectFavouriteDishSheet(),
    );
  }

  @override
  State<SelectFavouriteDishSheet> createState() => _SelectFavouriteDishSheetState();
}

class _SelectFavouriteDishSheetState extends State<SelectFavouriteDishSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<DishProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchDishes());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Dish> _filter(List<Dish> dishes) {
    if (_searchController.text.isEmpty) return dishes;
    return dishes.where((d) => d.dishName.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dishProvider = context.watch<DishProvider>();
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
                      const Text('Select Favourite Dish', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
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
                      Expanded(child: _buildBody(dishProvider, scrollController)),
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

  Widget _buildBody(DishProvider provider, ScrollController scrollController) {
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
                  onPressed: () => context.read<DishProvider>().fetchDishes(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final filtered = _filter(provider.dishes);
        if (provider.dishes.isEmpty) {
          return const Center(child: Text('No Dishes created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)));
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final dish = filtered[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, dish),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.restaurant_menu, color: AppTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(dish.dishName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            );
          },
        );
    }
  }
}

// ---------------- Preferred Seating picker ----------------

class SelectPreferredSeatingSheet extends StatefulWidget {
  const SelectPreferredSeatingSheet({super.key});

  static Future<RestaurantTable?> show(BuildContext context) {
    return showModalBottomSheet<RestaurantTable>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectPreferredSeatingSheet(),
    );
  }

  @override
  State<SelectPreferredSeatingSheet> createState() => _SelectPreferredSeatingSheetState();
}

class _SelectPreferredSeatingSheetState extends State<SelectPreferredSeatingSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<TableProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchTables());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RestaurantTable> _filter(List<RestaurantTable> tables) {
    if (_searchController.text.isEmpty) return tables;
    return tables.where((t) => t.tableName.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = context.watch<TableProvider>();
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
                      const Text('Select Preferred Seating', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
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
                      Expanded(child: _buildBody(tableProvider, scrollController)),
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

  Widget _buildBody(TableProvider provider, ScrollController scrollController) {
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
                  onPressed: () => context.read<TableProvider>().fetchTables(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final filtered = _filter(provider.tables);
        if (provider.tables.isEmpty) {
          return const Center(child: Text('No Tables created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)));
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final table = filtered[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, table),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.table_bar_outlined, color: AppTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(table.tableName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            );
          },
        );
    }
  }
}

// ---------------- Shared form widgets ----------------

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _PhoneField({required this.controller, this.errorText, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: errorText == null ? AppTheme.divider : AppTheme.cancelled),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇳🇵', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Text('+977', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: AppTheme.divider),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  onChanged: onChanged,
                  style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                  decoration: const InputDecoration(
                    hintText: 'Enter Customer Contact Number',
                    hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(errorText!, style: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none)),
          ),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  final TimeOfDay? time;
  final String hint;
  final VoidCallback onTap;
  final String Function(TimeOfDay) formatTime;

  const _TimeField({required this.time, required this.hint, required this.onTap, required this.formatTime});

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
            const Icon(Icons.access_time, color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                time == null ? hint : formatTime(time!),
                style: TextStyle(color: time == null ? AppTheme.textSecondary : AppTheme.textPrimary, decoration: TextDecoration.none),
              ),
            ),
          ],
        ),
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
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: value != null ? AppTheme.textPrimary : AppTheme.textSecondary, fontSize: 14.5, decoration: TextDecoration.none),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
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
  final String? suffix;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    this.controller,
    required this.hint,
    this.suffix,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        errorText: errorText,
        errorStyle: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
      ),
    );
  }
}
