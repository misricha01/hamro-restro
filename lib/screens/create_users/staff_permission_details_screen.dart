import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/role_model.dart';
import '../../data/repositories/rbac_repository.dart';
import 'staff_change_role_screen.dart';

/// Read-only "View Permission Details" screen reached from the Staff
/// detail's Role & Permission card, listing every permission currently
/// granted to [roleName] (backend: `GET /api/rbac/all?role=X`) with a
/// "Change Role" shortcut at the bottom.
class StaffPermissionDetailsScreen extends StatelessWidget {
  final String staffId;
  final String staffName;
  final String roleName;
  final ValueChanged<String> onRoleChanged;

  const StaffPermissionDetailsScreen({
    super.key,
    required this.staffId,
    required this.staffName,
    required this.roleName,
    required this.onRoleChanged,
  });

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
          staffName,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: FutureBuilder<List<RbacEntry>>(
        future: roleName.isEmpty ? Future.value(const []) : context.read<RbacRepository>().getRbacForRole(roleName),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }
          final entries = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (entries.isEmpty)
                const Text('No permissions configured for this role.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))
              else
                for (final entry in entries) _PermissionRow(label: '${entry.route} — ${entry.permission}'),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final newRole = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => StaffChangeRoleScreen(staffId: staffId, staffName: staffName, currentRoleName: roleName)),
              );
              if (newRole != null) {
                onRoleChanged(newRole);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cancelled,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Change Role', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, decoration: TextDecoration.none)),
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
