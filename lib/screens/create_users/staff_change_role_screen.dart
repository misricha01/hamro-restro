import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/role_model.dart';
import '../../data/repositories/rbac_repository.dart';
import '../../models/role_style.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/role_provider.dart';
import '../../providers/staff_provider.dart';

/// "Change Role" screen reached from the Staff detail's Role & Permission
/// card. Role chips come from [RoleProvider] (backend: `GET /api/roles`) —
/// this restaurant's actual roles, not a fixed list. Confirming calls
/// [StaffProvider.assignRole] (`POST /api/rbac/assign-role`) and pops with
/// the new role name on success. The permission preview reads
/// [RbacRepository.getRbacForRole] (`GET /api/rbac/all?role=X`); there's no
/// bulk RBAC editor in this app yet, so the previous "tune" fine-grained
/// permission affordance is dropped rather than left non-functional.
class StaffChangeRoleScreen extends StatefulWidget {
  final String staffId;
  final String staffName;
  final String currentRoleName;

  const StaffChangeRoleScreen({super.key, required this.staffId, required this.staffName, required this.currentRoleName});

  @override
  State<StaffChangeRoleScreen> createState() => _StaffChangeRoleScreenState();
}

class _StaffChangeRoleScreenState extends State<StaffChangeRoleScreen> {
  late String _selectedRoleName = widget.currentRoleName;
  late Future<List<RbacEntry>> _permissionsFuture;

  @override
  void initState() {
    super.initState();
    final roleProvider = context.read<RoleProvider>();
    if (roleProvider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => roleProvider.fetchRoles());
    }
    _permissionsFuture = _loadPermissions(_selectedRoleName);
  }

  Future<List<RbacEntry>> _loadPermissions(String roleName) {
    if (roleName.isEmpty) return Future.value(const []);
    return context.read<RbacRepository>().getRbacForRole(roleName);
  }

  void _selectRole(String roleName) {
    setState(() {
      _selectedRoleName = roleName;
      _permissionsFuture = _loadPermissions(roleName);
    });
  }

  Future<void> _confirm() async {
    final provider = context.read<StaffProvider>();
    final ok = await provider.assignRole(id: widget.staffId, roleName: _selectedRoleName);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, _selectedRoleName);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.assignRoleErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = context.watch<RoleProvider>();
    final isAssigning = context.watch<StaffProvider>().isAssigningRole;

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
          widget.staffName,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const Text('Role', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none)),
          const SizedBox(height: 12),
          if (roleProvider.status == LoadStatus.loading || roleProvider.status == LoadStatus.idle)
            const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          else if (roleProvider.status == LoadStatus.error)
            Text(roleProvider.errorMessage ?? 'Something went wrong.', style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: roleProvider.roles.map((role) {
                final selected = role.name == _selectedRoleName;
                final color = roleColorFor(role.name);
                return GestureDetector(
                  onTap: () => _selectRole(role.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? color.withValues(alpha: 0.15) : AppTheme.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? color : AppTheme.divider),
                    ),
                    child: Text(
                      role.name,
                      style: TextStyle(color: selected ? color : AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          const Text('Permissions', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none)),
          const SizedBox(height: 12),
          FutureBuilder<List<RbacEntry>>(
            future: _permissionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: CircularProgressIndicator(color: AppTheme.accent));
              }
              final entries = snapshot.data ?? const [];
              if (entries.isEmpty) {
                return const Text('No permissions configured for this role.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none));
              }
              return Column(
                children: [for (final entry in entries) _PermissionRow(label: '${entry.route} — ${entry.permission}')],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isAssigning ? null : _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cancelled,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: isAssigning
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Change Role', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String label;
  const _PermissionRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_box, color: AppTheme.completed, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none))),
        ],
      ),
    );
  }
}
