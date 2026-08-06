import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/payment_method/payment_method_model.dart';
import '../../../providers/payment_method_provider.dart';
import '../../../widgets/common/finance_form_fields.dart';

/// "Add Payment Mode" form, backed by [PaymentMethodProvider.createPaymentMethod]
/// / [PaymentMethodProvider.updatePaymentMethod] (`POST`/`PATCH
/// /api/payment-method`). The backend only has two fields (`name`,
/// `remarks`) — "Modes Photo", "Settlement Account" and "Integrations" from
/// the original design have no backend counterpart and are dropped rather
/// than shown as if they were saved. Pass [initial] to pre-fill for editing.
class AddPaymentModeScreen extends StatefulWidget {
  final PaymentMode? initial;

  const AddPaymentModeScreen({super.key, this.initial});

  bool get isEditing => initial != null;

  @override
  State<AddPaymentModeScreen> createState() => _AddPaymentModeScreenState();
}

class _AddPaymentModeScreenState extends State<AddPaymentModeScreen> {
  late final _nameController = TextEditingController(text: widget.initial?.name ?? '');
  late final _remarksController = TextEditingController(text: widget.initial?.remarks ?? '');

  bool _nameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    setState(() => _nameError = name.isEmpty);
    if (_nameError) return;

    final provider = context.read<PaymentMethodProvider>();
    final remarks = _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim();
    final result = widget.isEditing
        ? await provider.updatePaymentMethod(id: widget.initial!.id, name: name, remarks: remarks)
        : await provider.createPaymentMethod(name: name, remarks: remarks);

    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context, result);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentMethodProvider>();
    final isSaving = widget.isEditing ? provider.isUpdating : provider.isCreating;

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
          widget.isEditing ? 'Edit Payment Mode' : 'Add Payment Mode',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FieldLabel(label: 'Mode Name', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _nameController,
            hint: 'Enter your mode name',
            errorText: _nameError ? 'Required' : null,
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),

          const FieldLabel(label: 'Remarks', required: false),
          const SizedBox(height: 8),
          AppTextField(controller: _remarksController, hint: 'Enter Remarks'),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.isEditing ? 'Update Payment Mode' : 'Save Payment Mode', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
