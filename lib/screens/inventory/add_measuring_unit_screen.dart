import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/unit/unit_model.dart';
import '../../providers/unit_provider.dart';

/// "Add Measuring Unit" screen, matching [AddStockGroupScreen]'s form/nav
/// pattern. Backed by [UnitProvider.createUnit]/[UnitProvider.updateUnit]
/// (`POST`/`PATCH /api/unit`). The backend only has two fields (`name`,
/// `description`) — per its own Swagger example (`name: "kg", description:
/// "Kilogram unit"`) `name` is the short form, so "Short Name" maps to it;
/// "Measuring Unit" (long name) and "Description" both fold into
/// `description`. Pass [initial] to pre-fill for editing an existing unit.
/// Returns the saved [Unit] via [Navigator.pop] once saved.
class AddMeasuringUnitScreen extends StatefulWidget {
  final Unit? initial;

  const AddMeasuringUnitScreen({super.key, this.initial});

  @override
  State<AddMeasuringUnitScreen> createState() => _AddMeasuringUnitScreenState();
}

class _AddMeasuringUnitScreenState extends State<AddMeasuringUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _unitNameController = TextEditingController(text: widget.initial?.description ?? '');
  late final _symbolController = TextEditingController(text: widget.initial?.name ?? '');
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _unitNameController.dispose();
    _symbolController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final longName = _unitNameController.text.trim();
    final extraDescription = _descriptionController.text.trim();
    final description = extraDescription.isEmpty ? longName : '$longName — $extraDescription';
    final name = _symbolController.text.trim();

    final provider = context.read<UnitProvider>();
    final unit = widget.initial?.id == null
        ? await provider.createUnit(name: name, description: description)
        : await provider.updateUnit(id: widget.initial!.id!, name: name, description: description);

    if (!mounted) return;
    if (unit != null) {
      Navigator.pop(context, unit);
    } else {
      final message = widget.initial?.id == null ? provider.createErrorMessage : provider.updateErrorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<UnitProvider>().isCreating || context.watch<UnitProvider>().isUpdating;

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
              child: const Icon(Icons.chevron_left, color: AppTheme.primary),
            ),
          ),
        ),
        title: const Text(
          'Add Measuring Unit',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
                children: [
                  TextSpan(text: 'Measuring Unit'),
                  TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _unitNameController,
              style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Measuring Unit is required';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter Unit, eg: Kilogram, Millilitre, Pieces',
                hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                filled: true,
                fillColor: AppTheme.card,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                errorStyle: const TextStyle(color: AppTheme.cancelled, decoration: TextDecoration.none),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.cancelled),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.cancelled),
                ),
              ),
            ),
            const SizedBox(height: 20),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
                children: [
                  TextSpan(text: 'Short Name'),
                  TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _symbolController,
              style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Short Name is required';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter Short Name, eg: kg, ml, pcs',
                hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                filled: true,
                fillColor: AppTheme.card,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                errorStyle: const TextStyle(color: AppTheme.cancelled, decoration: TextDecoration.none),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.cancelled),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.cancelled),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
              decoration: InputDecoration(
                hintText: 'Enter Description',
                hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                filled: true,
                fillColor: AppTheme.card,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text(
                          'Save Unit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
