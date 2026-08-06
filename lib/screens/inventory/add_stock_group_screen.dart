import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock/stock_group_model.dart';
import '../../providers/stock_group_provider.dart';

/// "Add Stock Group" form, backed by [StockGroupProvider.createStockGroup]
/// (`POST /api/stock-group`) and pops with the created [StockGroup] on
/// success — mirrors [AddCategoryScreen]'s save/loading/error pattern.
class AddStockGroupScreen extends StatefulWidget {
  const AddStockGroupScreen({super.key});

  @override
  State<AddStockGroupScreen> createState() => _AddStockGroupScreenState();
}

class _AddStockGroupScreenState extends State<AddStockGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<StockGroupProvider>();
    final group = await provider.createStockGroup(
      groupName: _groupNameController.text.trim(),
      groupDescription: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

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
    final isCreating = context.watch<StockGroupProvider>().isCreating;

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
          'Add Stock Group',
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
                  TextSpan(text: 'Group Name'),
                  TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _groupNameController,
              style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Group Name is required';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter Group Name',
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
                  onPressed: isCreating ? null : () => Navigator.pop(context),
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
                  onPressed: isCreating ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Save Stock Group',
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
