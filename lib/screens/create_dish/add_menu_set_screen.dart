import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Quick-create form for a new Menu Set, reached from the Manage Menu Set
/// list's "Add New Menu Set" button. Mirrors the simple name-only pattern
/// already used by AddCategoryScreen / AddSubMenuScreen.
class AddMenuSetScreen extends StatefulWidget {
  const AddMenuSetScreen({super.key});

  @override
  State<AddMenuSetScreen> createState() => _AddMenuSetScreenState();
}

class _AddMenuSetScreenState extends State<AddMenuSetScreen> {
  final _nameController = TextEditingController();
  bool _nameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    setState(() => _nameError = name.isEmpty);
    if (_nameError) return;
    Navigator.pop(context, name);
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
        title: const Text(
          'Add Menu Set',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
              children: [
                const TextSpan(text: 'Menu Set Name'),
                const TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
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
              hintText: 'Enter Menu Set Name',
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
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Menu Set', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
