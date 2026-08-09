import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/addon/addon_model.dart';
import '../../providers/addon_provider.dart';
import 'add_dish_screen.dart' show ImageSourceSheet;

/// Quick-create form for a new Add-On / Extra, reached from the Menu
/// screen's "+ Add" pills. Mirrors the simple name + photo pattern already
/// used by [AddCategoryScreen] / [AddSubMenuScreen] in add_dish_screen.dart.
/// Saves via [AddOnProvider.createAddOn] and pops with the created [AddOn]
/// on success.
class AddAddOnScreen extends StatefulWidget {
  final AddOn? existingAddOn;

  const AddAddOnScreen({super.key, this.existingAddOn});

  bool get isEditing => existingAddOn != null;

  @override
  State<AddAddOnScreen> createState() => _AddAddOnScreenState();
}

class _AddAddOnScreenState extends State<AddAddOnScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedImageSource;
  bool _nameError = false;
  bool _priceError = false;

  @override
  void initState() {
    super.initState();
    final addon = widget.existingAddOn;
    if (addon != null) {
      _nameController.text = addon.addonName;
      _priceController.text = addon.price.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImageSource() async {
    final result = await ImageSourceSheet.show(context);
    if (result != null) setState(() => _selectedImageSource = result);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    setState(() {
      _nameError = name.isEmpty;
      _priceError = price == null;
    });
    if (_nameError || _priceError) return;

    final provider = context.read<AddOnProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final addon = widget.isEditing
        ? await provider.updateAddOn(id: widget.existingAddOn!.id, addonName: name, price: price!)
        : await provider.createAddOn(addonName: name, price: price!);
    if (!mounted) return;

    if (addon != null) {
      messenger.showSnackBar(SnackBar(content: Text(widget.isEditing ? 'Add-On updated successfully' : 'Add-On created successfully')));
      Navigator.pop(context, addon);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      messenger.showSnackBar(SnackBar(content: Text(message ?? 'Failed to save add-on')));
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
          widget.isEditing ? 'Edit Add-On' : 'Add Add-On',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const _FieldLabel(label: 'Add-On Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Enter Add-On Name',
            errorText: _nameError ? 'Required' : null,
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),
          const _FieldLabel(label: 'Price', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _priceController,
            hint: '00.00',
            prefix: 'Rs',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _priceError ? 'Enter a valid amount' : null,
            onChanged: (v) {
              if (_priceError && double.tryParse(v.trim()) != null) setState(() => _priceError = false);
            },
          ),
          const SizedBox(height: 20),
          const _FieldLabel(label: 'Add-On Photo', required: false),
          const SizedBox(height: 8),
          _UploadBox(
            label: _selectedImageSource == null ? 'Tap here to select or upload photos' : 'Selected via ${_selectedImageSource!}',
            onTap: _pickImageSource,
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
              child: Consumer<AddOnProvider>(
                builder: (context, provider, _) {
                  final isSaving = widget.isEditing ? provider.isUpdating : provider.isCreating;
                  return ElevatedButton(
                    onPressed: isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(widget.isEditing ? 'Update Add-On' : 'Save Add-On', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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
  final String? prefix;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    this.controller,
    required this.hint,
    this.prefix,
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
        prefixText: prefix == null ? null : '$prefix   ',
        prefixStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
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

class _UploadBox extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _UploadBox({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_outlined, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          ],
        ),
      ),
    );
  }
}
