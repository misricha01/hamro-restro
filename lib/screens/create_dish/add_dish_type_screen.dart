import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/dish_type/dish_type_model.dart';
import '../../providers/dish_type_provider.dart';

/// "Add Dish Type" form reached from [SelectDishTypeSheet]'s "Add New"
/// action, or its row's Edit action. Mirrors [CreateSpaceScreen]'s simple
/// name-only pattern. Saves via [DishTypeProvider.createDishType] /
/// [DishTypeProvider.updateDishType] and pops with the resulting [DishType]
/// on success.
class AddDishTypeScreen extends StatefulWidget {
  final DishType? existingDishType;

  const AddDishTypeScreen({super.key, this.existingDishType});

  bool get isEditing => existingDishType != null;

  @override
  State<AddDishTypeScreen> createState() => _AddDishTypeScreenState();
}

class _AddDishTypeScreenState extends State<AddDishTypeScreen> {
  final _nameController = TextEditingController();
  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    final dishType = widget.existingDishType;
    if (dishType != null) _nameController.text = dishType.dishTypeName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    setState(() => _nameError = name.isEmpty);
    if (_nameError) return;

    final provider = context.read<DishTypeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final dishType = widget.isEditing
        ? await provider.updateDishType(id: widget.existingDishType!.id, dishTypeName: name)
        : await provider.createDishType(dishTypeName: name);
    if (!mounted) return;

    if (dishType != null) {
      messenger.showSnackBar(SnackBar(content: Text(widget.isEditing ? 'Dish Type updated successfully' : 'Dish Type created successfully')));
      Navigator.pop(context, dishType);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      messenger.showSnackBar(SnackBar(content: Text(message ?? 'Failed to save dish type')));
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
          widget.isEditing ? 'Edit Dish Type' : 'Add Dish Type',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
              children: [
                TextSpan(text: 'Dish Type Name'),
                TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
            decoration: InputDecoration(
              hintText: 'Enter Dish Type Name',
              hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
              errorText: _nameError ? 'Required' : null,
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
              child: Consumer<DishTypeProvider>(
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
                        : Text(widget.isEditing ? 'Update Dish Type' : 'Save Dish Type', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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
