import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/department.dart';
import '../../widgets/common/finance_form_fields.dart';

/// "Create Department" form reached from the Department screen's "Create
/// New Department" action, matching the reference's Name + Description
/// fields with a Back / Save Department bottom bar.
class CreateDepartmentScreen extends StatefulWidget {
  final Department? initial;
  const CreateDepartmentScreen({super.key, this.initial});

  @override
  State<CreateDepartmentScreen> createState() => _CreateDepartmentScreenState();
}

class _CreateDepartmentScreenState extends State<CreateDepartmentScreen> {
  late final _nameController = TextEditingController(text: widget.initial?.name ?? '');
  late final _descriptionController = TextEditingController(text: widget.initial?.description ?? '');
  bool _nameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _nameError = _nameController.text.trim().isEmpty);
    if (_nameError) return;
    Navigator.pop(context, Department(name: _nameController.text.trim(), description: _descriptionController.text.trim()));
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
          widget.initial == null ? 'Create Department' : 'Edit Department',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const FieldLabel(label: 'Department Name', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _nameController,
            hint: 'Enter Department Name',
            errorText: _nameError ? 'Department Name is required' : null,
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),
          const FieldLabel(label: 'Description', required: false),
          const SizedBox(height: 8),
          AppTextField(controller: _descriptionController, hint: 'Enter Description', maxLines: 6, minLines: 5),
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
                child: const Text('Save Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
