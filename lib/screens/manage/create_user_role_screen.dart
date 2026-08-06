import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_role_entry.dart';
import '../../providers/role_provider.dart';
import '../../widgets/common/finance_form_fields.dart';

/// "Add New Role" form reached from the User Role screen, backed by
/// [RoleProvider.createRole] (`POST /api/roles`). Permissions for the new
/// role are set afterwards from its detail screen's Route x Permission
/// matrix (a brand new role starts with zero grants).
class CreateUserRoleScreen extends StatefulWidget {
  const CreateUserRoleScreen({super.key});

  @override
  State<CreateUserRoleScreen> createState() => _CreateUserRoleScreenState();
}

class _CreateUserRoleScreenState extends State<CreateUserRoleScreen> {
  final _nameController = TextEditingController();
  bool _nameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    setState(() => _nameError = name.isEmpty);
    if (_nameError) return;

    final provider = context.read<RoleProvider>();
    final role = await provider.createRole(name);
    if (!mounted) return;
    if (role != null) {
      Navigator.pop(context, UserRoleEntry(role: role, totalUsers: 0));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.createErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = context.watch<RoleProvider>().isCreating;

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
        title: const Text('Add New Role', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const FieldLabel(label: 'Role Name', required: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _nameController,
            hint: 'Enter Role Name',
            errorText: _nameError ? 'Role Name is required' : null,
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 12),
          const Text(
            "You'll be able to set exactly what this role can view and edit once it's created.",
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, height: 1.4, decoration: TextDecoration.none),
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
                onPressed: isCreating ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isCreating ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isCreating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Role', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
