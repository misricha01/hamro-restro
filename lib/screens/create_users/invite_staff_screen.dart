import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/role_model.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/common/select_role_sheet.dart';

/// "Invite Staff" screen reached from [StaffListScreen]. This backend has no
/// "invite before an account exists" endpoint — the only staff-creation
/// endpoint (`POST /api/restaurant/create-account`) creates a full account
/// with a password immediately. So each row collects Name + Email + Password
/// + Role and "Send Invitation" loops them through
/// [StaffProvider.createStaff], reporting any per-row failures rather than
/// silently dropping them.
class InviteStaffScreen extends StatefulWidget {
  const InviteStaffScreen({super.key});

  @override
  State<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _StaffRow {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Role? role;
  bool hasError = false;

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final List<_StaffRow> _rows = [_StaffRow()];
  bool _isDirty = false;
  bool _isSending = false;

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _addRow() {
    setState(() {
      _rows.add(_StaffRow());
      _isDirty = true;
    });
  }

  void _removeRow(_StaffRow row) {
    setState(() {
      if (_rows.length > 1) {
        _rows.remove(row);
        row.dispose();
      } else {
        row.nameController.clear();
        row.emailController.clear();
        row.passwordController.clear();
        row.role = null;
        row.hasError = false;
      }
      _isDirty = true;
    });
  }

  void _resetForm() {
    setState(() {
      for (final row in _rows) {
        row.dispose();
      }
      _rows
        ..clear()
        ..add(_StaffRow());
      _isDirty = false;
    });
  }

  Future<void> _sendInvitation() async {
    var hasError = false;
    setState(() {
      for (final row in _rows) {
        row.hasError = row.nameController.text.trim().isEmpty || row.emailController.text.trim().isEmpty || row.passwordController.text.trim().isEmpty;
        if (row.hasError) hasError = true;
      }
    });
    if (hasError) return;

    setState(() => _isSending = true);
    final provider = context.read<StaffProvider>();
    final failures = <String>[];
    for (final row in _rows) {
      final result = await provider.createStaff(
        fullname: row.nameController.text.trim(),
        email: row.emailController.text.trim(),
        password: row.passwordController.text.trim(),
        position: 'Staff',
        role: row.role?.name,
      );
      if (result == null) {
        failures.add('${row.nameController.text.trim()}: ${provider.createErrorMessage ?? 'failed'}');
      }
    }
    if (!mounted) return;
    setState(() => _isSending = false);

    if (failures.isEmpty) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Some staff could not be created:\n${failures.join('\n')}')));
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
        title: const Text(
          'Invite Staff',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          for (final row in _rows) ...[
            _StaffRowField(
              row: row,
              onChanged: _markDirty,
              onDelete: () => _removeRow(row),
              onRoleTap: () => SelectRoleSheet.show(
                context,
                initialRoleName: row.role?.name,
                onSelected: (role) => setState(() {
                  row.role = role;
                  _isDirty = true;
                }),
              ),
            ),
            const SizedBox(height: 20),
          ],

          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _addRow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: AppTheme.textPrimary, size: 18),
                  SizedBox(width: 6),
                  Text('Add More', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ],
              ),
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
                onPressed: _isSending ? null : (_isDirty ? _resetForm : () => Navigator.pop(context)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  _isDirty ? 'Reset' : 'Back',
                  style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendInvitation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffRowField extends StatelessWidget {
  final _StaffRow row;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final VoidCallback onRoleTap;

  const _StaffRowField({
    required this.row,
    required this.onChanged,
    required this.onDelete,
    required this.onRoleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _FieldLabel(label: 'Staff Name', required: true),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, color: AppTheme.cancelled),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _AppTextField(
            controller: row.nameController,
            hint: "Enter staff's name",
            errorText: row.hasError && row.nameController.text.trim().isEmpty ? 'Required' : null,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 14),

          const _FieldLabel(label: 'Staff Email', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: row.emailController,
            hint: "Enter staff's email",
            keyboardType: TextInputType.emailAddress,
            errorText: row.hasError && row.emailController.text.trim().isEmpty ? 'Required' : null,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 14),

          const _FieldLabel(label: 'Password', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: row.passwordController,
            hint: 'Enter password',
            obscureText: true,
            errorText: row.hasError && row.passwordController.text.trim().isEmpty ? 'Required' : null,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 14),

          const _FieldLabel(label: 'Role', required: false),
          const SizedBox(height: 8),
          _RoleField(roleName: row.role?.name, onTap: onRoleTap),
        ],
      ),
    );
  }
}

class _RoleField extends StatelessWidget {
  final String? roleName;
  final VoidCallback onTap;

  const _RoleField({required this.roleName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                roleName ?? 'Select Role',
                style: TextStyle(color: roleName != null ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
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
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  const _AppTextField({
    this.controller,
    required this.hint,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
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
