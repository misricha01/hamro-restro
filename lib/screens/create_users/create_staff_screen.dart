import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/role_model.dart';
import '../../data/models/staff/staff_member_model.dart';
import '../../models/role_style.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/common/select_role_sheet.dart';

/// "Create Staff" form, reused both to add a brand new staff member from
/// [StaffListScreen] and to edit an existing one from [StaffDetailScreen]'s
/// "..." menu (title stays "Create Staff" in both cases; only the submit
/// button label changes to "Update Staff").
///
/// Backed by [StaffProvider.createStaff] (`POST
/// /api/restaurant/create-account`, which requires a password up front) /
/// [StaffProvider.updateStaff] (`PATCH /api/user/{id}`, no password resend).
/// This backend has no `contactNumber`/`discountLimit` fields on the user
/// entity, so those inputs from the original design are dropped rather than
/// shown as if they were saved.
class CreateStaffScreen extends StatefulWidget {
  final StaffMember? existingStaff;

  const CreateStaffScreen({super.key, this.existingStaff});

  bool get isEditing => existingStaff != null;

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _positionController;

  Role? _selectedRole;
  bool _isDirty = false;
  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;

  @override
  void initState() {
    super.initState();
    final staff = widget.existingStaff;
    _nameController = TextEditingController(text: staff?.fullname ?? '');
    _emailController = TextEditingController(text: staff?.email ?? '');
    _passwordController = TextEditingController();
    _positionController = TextEditingController(text: staff?.position ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _resetForm() {
    final staff = widget.existingStaff;
    setState(() {
      _nameController.text = staff?.fullname ?? '';
      _emailController.text = staff?.email ?? '';
      _passwordController.clear();
      _positionController.text = staff?.position ?? '';
      _selectedRole = null;
      _isDirty = false;
      _nameError = false;
      _emailError = false;
      _passwordError = false;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    setState(() {
      _nameError = name.isEmpty;
      _emailError = email.isEmpty;
      _passwordError = !widget.isEditing && password.isEmpty;
    });
    if (_nameError || _emailError || _passwordError) return;

    final provider = context.read<StaffProvider>();
    final position = _positionController.text.trim().isEmpty ? 'Staff' : _positionController.text.trim();

    final result = widget.isEditing
        ? await provider.updateStaff(id: widget.existingStaff!.id, fullname: name, email: email, position: position)
        : await provider.createStaff(fullname: name, email: email, password: password, position: position, role: _selectedRole?.name);

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
    final provider = context.watch<StaffProvider>();
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
        title: const Text(
          'Create Staff',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _FieldLabel(label: 'Staff Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Enter Staff Name',
            errorText: _nameError ? 'Staff Name is required' : null,
            onChanged: (v) {
              _markDirty();
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Email', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _emailController,
            hint: "Enter Staff's Email",
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError ? 'Email is required' : null,
            onChanged: (v) {
              _markDirty();
              if (_emailError && v.trim().isNotEmpty) setState(() => _emailError = false);
            },
          ),
          const SizedBox(height: 20),

          if (!widget.isEditing) ...[
            const _FieldLabel(label: 'Password', required: true),
            const SizedBox(height: 8),
            _AppTextField(
              controller: _passwordController,
              hint: 'Enter Password',
              obscureText: true,
              errorText: _passwordError ? 'Password is required' : null,
              onChanged: (v) {
                _markDirty();
                if (_passwordError && v.trim().isNotEmpty) setState(() => _passwordError = false);
              },
            ),
            const SizedBox(height: 20),
          ],

          const _FieldLabel(label: 'Position', required: false),
          const SizedBox(height: 8),
          _AppTextField(controller: _positionController, hint: 'Enter Position', onChanged: (_) => _markDirty()),
          const SizedBox(height: 20),

          if (!widget.isEditing) ...[
            const _FieldLabel(label: 'Role', required: false),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => SelectRoleSheet.show(
                context,
                initialRoleName: _selectedRole?.name,
                onSelected: (role) => setState(() {
                  _selectedRole = role;
                  _isDirty = true;
                }),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    if (_selectedRole != null) ...[
                      Icon(roleIconFor(_selectedRole!.name), color: roleColorFor(_selectedRole!.name), size: 18),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        _selectedRole?.name ?? 'Select Role',
                        style: TextStyle(color: _selectedRole != null ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: isSaving ? null : (_isDirty ? _resetForm : () => Navigator.pop(context)),
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
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        widget.isEditing ? 'Update Staff' : 'Save Staff',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                      ),
              ),
            ),
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

  const _AppTextField({this.controller, required this.hint, this.errorText, this.keyboardType, this.onChanged, this.obscureText = false});

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
