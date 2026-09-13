import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/supplier/supplier_model.dart';
import '../../providers/supplier_provider.dart';

/// "Add Supplier" form, backed by [SupplierProvider.createSupplier]
/// (`POST /api/supplier`). Fields mirror the real backend `Supplier` shape
/// confirmed via Swagger — the previous version (Opening Balance, Legal
/// Name, Tax Number, Email, Date of Birth) doesn't match any real field and
/// has been dropped in favor of `address`/`remarks`. Also reused for editing
/// (pass [existingSupplier]), which calls
/// [SupplierProvider.updateSupplier] (`PATCH /api/supplier/{id}`) instead.
class AddSupplierScreen extends StatefulWidget {
  final Supplier? existingSupplier;

  const AddSupplierScreen({super.key, this.existingSupplier});

  bool get isEditing => existingSupplier != null;

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isDirty = false;
  bool _nameError = false;
  bool _contactError = false;
  bool _addressError = false;
  bool _remarksError = false;

  @override
  void initState() {
    super.initState();
    final supplier = widget.existingSupplier;
    if (supplier != null) {
      _nameController.text = supplier.supplierName;
      _contactController.text = supplier.phoneNumber;
      _addressController.text = supplier.address ?? '';
      _remarksController.text = supplier.remarks ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _contactController.clear();
      _addressController.clear();
      _remarksController.clear();
      _isDirty = false;
      _nameError = false;
      _contactError = false;
      _addressError = false;
      _remarksError = false;
    });
  }

  Future<void> _saveSupplier() async {
    final name = _nameController.text.trim();
    final phone = _contactController.text.trim();
    final address = _addressController.text.trim();
    final remarks = _remarksController.text.trim();
    // The backend's CreateSupplierDto requires both `address` and
    // `remarks` (confirmed live: submitting without them 400s with
    // "address must be a string, address should not be empty, remarks
    // must be a string, remarks should not be empty") even though this
    // form used to treat them as optional.
    setState(() {
      _nameError = name.isEmpty;
      _contactError = phone.isEmpty;
      _addressError = address.isEmpty;
      _remarksError = remarks.isEmpty;
    });
    if (_nameError || _contactError || _addressError || _remarksError) return;

    final provider = context.read<SupplierProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final supplier = widget.isEditing
        ? await provider.updateSupplier(id: widget.existingSupplier!.id, supplierName: name, phoneNumber: phone, address: address, remarks: remarks)
        : await provider.createSupplier(supplierName: name, phoneNumber: phone, address: address, remarks: remarks);
    if (!mounted) return;

    if (supplier != null) {
      messenger.showSnackBar(SnackBar(content: Text(widget.isEditing ? 'Supplier updated successfully' : 'Supplier created successfully')));
      Navigator.pop(context, supplier);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      messenger.showSnackBar(SnackBar(content: Text(message ?? 'Failed to save supplier')));
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
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: Text(
          widget.isEditing ? 'Edit Supplier' : 'Add Supplier',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _FieldLabel(label: 'Supplier Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Enter Supplier Name',
            errorText: _nameError ? 'Supplier Name is required' : null,
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

          const _FieldLabel(label: 'Address', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _addressController,
            hint: "Enter Supplier's Address",
            errorText: _addressError ? 'Address is required' : null,
            onChanged: (v) {
              _markDirty();
              if (_addressError && v.trim().isNotEmpty) setState(() => _addressError = false);
            },
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Remarks', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _remarksController,
            hint: 'e.g. Regular supplier',
            errorText: _remarksError ? 'Remarks is required' : null,
            onChanged: (v) {
              _markDirty();
              if (_remarksError && v.trim().isNotEmpty) setState(() => _remarksError = false);
            },
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
              child: Consumer<SupplierProvider>(
                builder: (context, provider, _) {
                  final isSaving = widget.isEditing ? provider.isUpdating : provider.isCreating;
                  return ElevatedButton(
                    onPressed: isSaving ? null : _saveSupplier,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(widget.isEditing ? 'Update Supplier' : 'Save Supplier', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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
                    hintText: 'Enter Supplier Contact Number',
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
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    this.controller,
    required this.hint,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
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
