import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/finance_form_fields.dart';

class AddKotTypeScreen extends StatefulWidget {
  final List<String> printers;

  const AddKotTypeScreen({super.key, this.printers = const []});

  @override
  State<AddKotTypeScreen> createState() => _AddKotTypeScreenState();
}

class _AddKotTypeScreenState extends State<AddKotTypeScreen> {
  final _nameController = TextEditingController();
  final _remarksController = TextEditingController();
  String? _printer;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _nameError = _nameController.text.trim().isEmpty ? 'KOT type name is required' : null);
    if (_nameError != null) return;
    Navigator.pop(context, _nameController.text.trim());
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
        title: const Text('Add KOT Type', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const FieldLabel(label: 'KOT Type Name', required: true),
                  const SizedBox(height: 8),
                  AppTextField(controller: _nameController, hint: 'Enter KOT Type Name', errorText: _nameError, onChanged: (_) => setState(() => _nameError = null)),
                  const SizedBox(height: 16),

                  const FieldLabel(label: 'Printers', required: false),
                  const SizedBox(height: 8),
                  widget.printers.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                          child: const Text('No Printers found. Add a printer in Printers Setting first.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
                        )
                      : SelectField(
                          hint: 'Select Printer for this Kot Type',
                          value: _printer,
                          onTap: () async {
                            final picked = await SimpleListSheet.show(context, title: 'Select Printer', items: widget.printers);
                            if (picked != null) setState(() => _printer = picked);
                          },
                        ),
                  const SizedBox(height: 16),

                  const FieldLabel(label: 'Remarks', required: false),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _remarksController,
                    maxLines: 4,
                    maxLength: 75,
                    style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                    decoration: InputDecoration(
                      hintText: 'Enter your remarks',
                      hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                      filled: true,
                      fillColor: AppTheme.card,
                      contentPadding: const EdgeInsets.all(14),
                      counterStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
              child: Row(
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                  const Spacer(),
                  SizedBox(
                    width: 180,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Save KOT Type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
