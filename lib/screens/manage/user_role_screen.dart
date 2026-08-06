import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_role_entry.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/role_provider.dart';
import '../../providers/staff_provider.dart';
import 'create_user_role_screen.dart';
import 'role_detail_screen.dart';

/// "User Role" screen reached from Manage > Setting > General Setting,
/// sourced live from [RoleProvider] (backend: `/api/roles`) — every role is
/// a real, per-restaurant record now, not a fixed built-in list. "Total
/// user" per role is computed from [StaffProvider]'s already-fetched list.
class UserRoleScreen extends StatefulWidget {
  const UserRoleScreen({super.key});

  @override
  State<UserRoleScreen> createState() => _UserRoleScreenState();
}

class _UserRoleScreenState extends State<UserRoleScreen> {
  @override
  void initState() {
    super.initState();
    final roleProvider = context.read<RoleProvider>();
    final staffProvider = context.read<StaffProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (roleProvider.status == LoadStatus.idle) roleProvider.fetchRoles();
      if (staffProvider.status == LoadStatus.idle) staffProvider.fetchStaff();
    });
  }

  Future<void> _openRole(UserRoleEntry role) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => RoleDetailScreen(role: role)));
  }

  Future<void> _addRole() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUserRoleScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = context.watch<RoleProvider>();
    final staffProvider = context.watch<StaffProvider>();

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
        title: const Text('User Role', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(child: _buildBody(roleProvider, staffProvider)),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _addRole,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Add New Role', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(RoleProvider provider, StaffProvider staffProvider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => provider.fetchRoles(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.roles.isEmpty) {
          return Center(
            child: Text('No roles created yet.', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
          );
        }
        final entries = provider.roles
            .map((r) => UserRoleEntry(role: r, totalUsers: staffProvider.staff.where((s) => s.role == r.name).length))
            .toList();
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => provider.fetchRoles(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              const Text('Roles', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
              const SizedBox(height: 12),
              _RoleGrid(roles: entries, onTap: _openRole),
            ],
          ),
        );
    }
  }
}

class _RoleGrid extends StatelessWidget {
  final List<UserRoleEntry> roles;
  final ValueChanged<UserRoleEntry> onTap;
  const _RoleGrid({required this.roles, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: roles.map((role) {
            return SizedBox(
              width: cardWidth,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onTap(role),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(role.icon, color: role.color, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(role.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Total user: ${role.totalUsers}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
