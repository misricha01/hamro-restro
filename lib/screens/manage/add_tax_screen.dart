import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/tax_rate.dart';
import '../../widgets/common/finance_form_fields.dart';

/// "Add Tax" form reached from the Tax & Rates screen's "Create New Tax"
/// action, matching the reference's Name/Rate/Notes fields with a
/// Back / Save Tax bottom bar.
class AddTaxScreen extends StatefulWidget {
  final TaxRate? initial;
  const AddTaxScreen({super.key, this.initial});

  @override
  State<AddTaxScreen> createState() => _AddTaxScreenState();
}

class _AddTaxScreenState extends State<AddTaxScreen> {
  late final _nameController = TextEditingController(text: widget.initial?.name ?? '');
  late final _rateController = TextEditingController(text: widget.initial == null ? '' : widget.initial!.rate.toString());
  late final _notesController = TextEditingController(text: widget.initial?.notes ?? '');
  bool _nameError = false;
  bool _rateError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final rate = double.tryParse(_rateController.text.trim());
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _rateError = rate == null;
    });
    if (_nameError || _rateError) return;
    Navigator.pop(context, TaxRate(name: _nameController.text.trim(), rate: rate!, notes: _notesController.text.trim()));
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
          widget.initial == null ? 'Add Tax' : 'Edit Tax',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const FieldLabel(label: 'Tax Name', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _nameController,
            hint: 'Enter Your Tax Name',
            errorText: _nameError ? 'Tax Name is required' : null,
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),
          const FieldLabel(label: 'Tax Rate (in %)', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _rateController,
            hint: 'Enter Your Tax Rate',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _rateError ? 'Enter a valid Tax Rate' : null,
            onChanged: (v) {
              if (_rateError && double.tryParse(v.trim()) != null) setState(() => _rateError = false);
            },
          ),
          const SizedBox(height: 20),
          const FieldLabel(label: 'Notes', required: false),
          const SizedBox(height: 8),
          AppTextField(controller: _notesController, hint: 'Enter Notes', maxLines: 6, minLines: 5),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Tax', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
