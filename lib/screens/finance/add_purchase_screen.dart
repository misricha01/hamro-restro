import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/customer/customer_model.dart';
import '../../data/models/media/media_model.dart';
import '../../data/models/payment_method/payment_method_model.dart';
import '../../data/models/sales_purchase/purchase_bill_model.dart';
import '../../data/models/supplier/supplier_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/purchase_bill_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/common/finance_form_fields.dart';
import '../../widgets/common/media_upload_helper.dart';
import '../create_users/add_supplier_screen.dart';
import 'add_expense_screen.dart' show SelectPaymentMethodSheet;

/// "Add Purchase Bill" — real form matching the backend's
/// `/api/purchase-bill` `CreatePurchaseBillDTO` exactly: Bill No, Bill Date,
/// Supplier (real `/api/supplier`), Customer (real `/api/customers` — the
/// DTO requires a `customerId` even though this is a supplier purchase),
/// Amount, Purchase Status, Payment Method (real `/api/payment-method`,
/// also supplies the required free-text `payment_type`), and an optional
/// Bill Photo wired to the real `imageId` field via the shared media-upload
/// flow (mirrors Add Dish's Dish Photo / Add Combo's Combo Photo). Replaces the
/// previous local-only "Item Details / Account Head" mockup, which had no
/// backend equivalent (the API has no line-item concept) and saved nothing.
///
/// Also doubles as the edit form when [existingBill] is passed — the
/// Supplier/Customer objects aren't embedded richly enough on the bill to
/// reconstruct locally, so edit mode resolves them by id against
/// [SupplierProvider]/[CustomerProvider]'s already-fetched lists (fetching
/// first if needed); if a match can't be found the field is simply left
/// blank and the existing required-field validation makes the user re-pick
/// it before saving, same as create.
class AddPurchaseScreen extends StatefulWidget {
  final String title;
  final PurchaseBill? existingBill;

  const AddPurchaseScreen({super.key, this.title = 'Add Purchase Bill', this.existingBill});

  bool get isEditing => existingBill != null;

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _billNoController = TextEditingController();
  final _amountController = TextEditingController();

  Supplier? _supplier;
  Customer? _customer;
  PaymentMode? _paymentMethod;
  DateTime _billDate = DateTime.now();
  bool _isPaid = true;
  UploadedMedia? _uploadedPhoto;

  bool _billNoError = false;
  bool _amountError = false;
  bool _supplierError = false;
  bool _customerError = false;

  @override
  void initState() {
    super.initState();
    final bill = widget.existingBill;
    if (bill == null) return;
    _billNoController.text = bill.billNo;
    _amountController.text = bill.amount.toStringAsFixed(0);
    _billDate = bill.date;
    _isPaid = bill.purchaseStatus == 'paid';
    if (bill.paymentMethodId != null) {
      _paymentMethod = PaymentMode(id: bill.paymentMethodId!, name: bill.paymentMethodName ?? bill.paymentType);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveExistingRefs(bill));
  }

  Future<void> _resolveExistingRefs(PurchaseBill bill) async {
    final supplierProvider = context.read<SupplierProvider>();
    final customerProvider = context.read<CustomerProvider>();
    if (supplierProvider.status == LoadStatus.idle) await supplierProvider.fetchSuppliers();
    if (customerProvider.status == LoadStatus.idle) await customerProvider.fetchCustomers();
    if (!mounted) return;

    final supplierId = bill.supplier?.id;
    final supplierMatches = supplierId == null ? const <Supplier>[] : supplierProvider.suppliers.where((s) => s.id == supplierId).toList();
    final customerMatches = bill.customerId == null ? const <Customer>[] : customerProvider.customers.where((c) => c.id == bill.customerId).toList();
    if (supplierMatches.isEmpty && customerMatches.isEmpty) return;
    setState(() {
      if (supplierMatches.isNotEmpty) _supplier = supplierMatches.first;
      if (customerMatches.isNotEmpty) _customer = customerMatches.first;
    });
  }

  @override
  void dispose() {
    _billNoController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickSupplier() async {
    final result = await SelectSupplierSheet.show(context);
    if (result != null) {
      setState(() {
        _supplier = result;
        _supplierError = false;
      });
    }
  }

  Future<void> _pickCustomer() async {
    final result = await SelectCustomerSheet.show(context);
    if (result != null) {
      setState(() {
        _customer = result;
        _customerError = false;
      });
    }
  }

  Future<void> _pickPaymentMethod() async {
    final result = await SelectPaymentMethodSheet.show(context);
    if (result != null) setState(() => _paymentMethod = result);
  }

  Future<void> _pickBillPhoto() async {
    final media = await pickAndUploadImage(context);
    if (media != null) setState(() => _uploadedPhoto = media);
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(context: context, initialDate: _billDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (result != null) setState(() => _billDate = result);
  }

  bool _isSaving(PurchaseBillProvider provider) => widget.isEditing ? provider.isUpdating : provider.isCreating;

  Future<void> _save() async {
    setState(() {
      _billNoError = _billNoController.text.trim().isEmpty;
      _amountError = double.tryParse(_amountController.text.trim()) == null;
      _supplierError = _supplier == null;
      _customerError = _customer == null;
    });
    if (_billNoError || _amountError || _supplierError || _customerError) return;

    final provider = context.read<PurchaseBillProvider>();
    final bill = widget.isEditing
        ? await provider.updatePurchaseBill(
            id: widget.existingBill!.id,
            date: AppDateField.format(_billDate),
            supplierId: _supplier!.id,
            billNo: _billNoController.text.trim(),
            amount: double.parse(_amountController.text.trim()),
            purchaseStatus: _isPaid ? 'paid' : 'unpaid',
            customerId: _customer!.id,
            paymentType: (_paymentMethod?.name ?? 'cash').toLowerCase(),
            paymentMethodId: _paymentMethod?.id,
            // A newly-uploaded photo wins; otherwise keep whatever the bill
            // already had rather than clearing it.
            imageId: _uploadedPhoto?.id ?? widget.existingBill!.imageId,
          )
        : await provider.createPurchaseBill(
            date: AppDateField.format(_billDate),
            supplierId: _supplier!.id,
            billNo: _billNoController.text.trim(),
            amount: double.parse(_amountController.text.trim()),
            purchaseStatus: _isPaid ? 'paid' : 'unpaid',
            customerId: _customer!.id,
            paymentType: (_paymentMethod?.name ?? 'cash').toLowerCase(),
            paymentMethodId: _paymentMethod?.id,
            imageId: _uploadedPhoto?.id,
          );
    if (!mounted) return;
    if (bill != null) {
      Navigator.pop(context, bill);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseBillProvider>();
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
          widget.isEditing ? 'Edit Purchase Bill' : widget.title,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FieldLabel(label: 'Bill Number', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _billNoController,
            hint: 'e.g. BILL-104',
            errorText: _billNoError ? 'Required' : null,
            onChanged: (v) {
              if (_billNoError && v.trim().isNotEmpty) setState(() => _billNoError = false);
            },
          ),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Bill Date', required: true),
          const SizedBox(height: 8),
          AppDateField(date: _billDate, onTap: _pickDate),
          const SizedBox(height: 20),

          FieldLabel(label: 'Supplier', required: true),
          const SizedBox(height: 8),
          SelectField(hint: 'Select Supplier', value: _supplier?.supplierName, onTap: _pickSupplier, errorText: _supplierError ? 'Required' : null),
          const SizedBox(height: 20),

          FieldLabel(label: 'Customer', required: true),
          const SizedBox(height: 8),
          SelectField(hint: 'Select Customer', value: _customer?.customerName, onTap: _pickCustomer, errorText: _customerError ? 'Required' : null),
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

          const Text('Purchase Status', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TwoWaySegment(leftLabel: 'Paid', rightLabel: 'Unpaid', isLeftSelected: _isPaid, onChanged: (v) => setState(() => _isPaid = v)),
          ),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Payment Method', required: false),
          const SizedBox(height: 8),
          SelectField(hint: 'Select Payment Method', value: _paymentMethod?.name, onTap: _pickPaymentMethod),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Bill Photo', required: false),
          const SizedBox(height: 8),
          UploadBox(
            label: _uploadedPhoto != null
                ? 'Photo uploaded'
                : (widget.existingBill?.imageUrl != null ? 'Tap to change photo' : 'Tap here to select or upload photos'),
            previewUrl: _uploadedPhoto?.url != null
                ? '${ApiClient.mediaBaseUrl}${_uploadedPhoto!.url}'
                : (widget.existingBill?.imageUrl != null ? '${ApiClient.mediaBaseUrl}${widget.existingBill!.imageUrl}' : null),
            onTap: _pickBillPhoto,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving(provider) ? null : _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: _isSaving(provider)
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.isEditing ? 'Update Purchase' : 'Save Purchase', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }
}

// ---------------- Supplier picker ----------------

/// Picker for a [Supplier], sourced live from [SupplierProvider] (backend:
/// `/api/supplier`), with an inline "Create Supplier" action reusing
/// [AddSupplierScreen] for when the desired supplier doesn't exist yet.
class SelectSupplierSheet extends StatefulWidget {
  const SelectSupplierSheet({super.key});

  static Future<Supplier?> show(BuildContext context) {
    return showModalBottomSheet<Supplier>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectSupplierSheet(),
    );
  }

  @override
  State<SelectSupplierSheet> createState() => _SelectSupplierSheetState();
}

class _SelectSupplierSheetState extends State<SelectSupplierSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<SupplierProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchSuppliers());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Supplier> _filter(List<Supplier> suppliers) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return suppliers;
    return suppliers.where((s) => s.supplierName.toLowerCase().contains(query)).toList();
  }

  Future<void> _createSupplier() async {
    final supplier = await Navigator.of(context).push<Supplier>(MaterialPageRoute(builder: (context) => const AddSupplierScreen()));
    if (supplier != null && mounted) Navigator.pop(context, supplier);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
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
                      const Text('Select Supplier', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _createSupplier,
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Create Supplier', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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

  Widget _buildBody(SupplierProvider provider, ScrollController scrollController) {
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
                  onPressed: () => provider.fetchSuppliers(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final filtered = _filter(provider.suppliers);
        if (provider.suppliers.isEmpty) {
          return const Center(child: Text('No suppliers created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)));
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final supplier = filtered[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, supplier),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.local_shipping_outlined, color: AppTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(supplier.supplierName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                  ],
                ),
              ),
            );
          },
        );
    }
  }
}

// ---------------- Customer picker ----------------

/// Picker for a [Customer], sourced live from [CustomerProvider] (backend:
/// `/api/customers`) — used here purely to satisfy the purchase-bill DTO's
/// required `customerId`.
class SelectCustomerSheet extends StatefulWidget {
  const SelectCustomerSheet({super.key});

  static Future<Customer?> show(BuildContext context) {
    return showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SelectCustomerSheet(),
    );
  }

  @override
  State<SelectCustomerSheet> createState() => _SelectCustomerSheetState();
}

class _SelectCustomerSheetState extends State<SelectCustomerSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<CustomerProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchCustomers());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Customer> _filter(List<Customer> customers) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers.where((c) => c.customerName.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();
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
                      const Text('Select Customer', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
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

  Widget _buildBody(CustomerProvider provider, ScrollController scrollController) {
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
                  onPressed: () => provider.fetchCustomers(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final filtered = _filter(provider.customers);
        if (provider.customers.isEmpty) {
          return const Center(child: Text('No customers created yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)));
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final customer = filtered[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, customer),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.person_outline, color: AppTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(customer.customerName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                  ],
                ),
              ),
            );
          },
        );
    }
  }
}
