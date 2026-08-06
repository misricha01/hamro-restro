import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/role_model.dart';
import '../../data/repositories/rbac_repository.dart';
import '../../models/user_role_entry.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/role_provider.dart';
import '../../providers/route_provider.dart';

const _kPermissions = ['get', 'post', 'patch', 'delete'];

enum _RoleMenuAction { rename, delete }

/// Role detail / permissions screen reached by tapping a role card on the
/// User Role screen. Shows every route (backend: `GET /api/routes`) as a
/// row with GET/POST/PATCH/DELETE toggles — the real shape of this
/// backend's RBAC system — rather than a curated feature checklist, since
/// there's no reliable mapping from friendly feature names to real routes.
/// "Save Permissions" diffs the toggled grid against the role's current
/// grants (`GET /api/rbac/all?role=X`) and applies only the changes via
/// `PUT`/`DELETE /api/rbac/bulk`.
class RoleDetailScreen extends StatefulWidget {
  final UserRoleEntry role;
  const RoleDetailScreen({super.key, required this.role});

  @override
  State<RoleDetailScreen> createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends State<RoleDetailScreen> {
  late Role _role = widget.role.role;
  final _searchController = TextEditingController();

  LoadStatus _grantsStatus = LoadStatus.idle;
  String? _grantsError;
  List<RbacEntry> _originalGrants = [];

  /// route name -> set of granted permissions, mutated by the checkboxes.
  final Map<String, Set<String>> _grants = {};

  bool _isSaving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final routeProvider = context.read<RouteProvider>();
    if (routeProvider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => routeProvider.fetchRoutes());
    }
    _loadGrants();
  }

  Future<void> _loadGrants() async {
    setState(() {
      _grantsStatus = LoadStatus.loading;
      _grantsError = null;
    });
    try {
      final entries = await context.read<RbacRepository>().getRbacForRole(_role.name);
      _originalGrants = entries;
      _grants.clear();
      for (final e in entries) {
        _grants.putIfAbsent(e.route, () => {}).add(e.permission);
      }
      if (!mounted) return;
      setState(() => _grantsStatus = LoadStatus.loaded);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _grantsStatus = LoadStatus.error;
        _grantsError = e.message;
      });
    }
  }

  void _toggle(String route, String permission) {
    setState(() {
      final set = _grants.putIfAbsent(route, () => {});
      if (set.contains(permission)) {
        set.remove(permission);
      } else {
        set.add(permission);
      }
      _dirty = true;
    });
  }

  Future<void> _savePermissions() async {
    setState(() => _isSaving = true);

    final desired = <String>{}; // "route|permission"
    for (final entry in _grants.entries) {
      for (final p in entry.value) {
        desired.add('${entry.key}|$p');
      }
    }
    final existing = <String, String>{}; // "route|permission" -> id
    for (final e in _originalGrants) {
      if (e.id != null) existing['${e.route}|${e.permission}'] = e.id!;
    }

    final toAdd = desired
        .where((k) => !existing.containsKey(k))
        .map((k) {
          final parts = k.split('|');
          return RbacEntry(role: _role.name, route: parts[0], permission: parts[1]);
        })
        .toList();
    final toRemoveIds = existing.entries.where((e) => !desired.contains(e.key)).map((e) => e.value).toList();

    final rbac = context.read<RbacRepository>();
    try {
      await rbac.bulkSetRbac(toAdd);
      await rbac.bulkDeleteRbac(toRemoveIds);
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _dirty = false;
      });
      await _loadGrants();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissions updated')));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _renameRole() async {
    final controller = TextEditingController(text: _role.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Rename Role', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName.isEmpty || newName == _role.name) return;

    final provider = context.read<RoleProvider>();
    final updated = await provider.updateRole(id: _role.id, name: newName);
    if (!mounted) return;
    if (updated != null) {
      setState(() => _role = updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.updateErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Role', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text('Delete "${_role.name}"? Staff currently assigned this role will need a new one.', style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true) return;

    final provider = context.read<RoleProvider>();
    final ok = await provider.deleteRole(_role.id);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  void _handleMenuAction(_RoleMenuAction action) {
    switch (action) {
      case _RoleMenuAction.rename:
        _renameRole();
      case _RoleMenuAction.delete:
        _confirmDelete();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<RouteProvider>();
    final isBusy = context.watch<RoleProvider>().isDeleting || _isSaving;

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
        title: Text(_role.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<_RoleMenuAction>(
              onSelected: _handleMenuAction,
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
              itemBuilder: (context) => const [
                PopupMenuItem(value: _RoleMenuAction.rename, child: Text('Rename Role', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none))),
                PopupMenuItem(value: _RoleMenuAction.delete, child: Text('Delete Role', style: TextStyle(color: AppTheme.cancelled, decoration: TextDecoration.none))),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                  decoration: const InputDecoration(
                    hintText: 'Search routes',
                    hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                    prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text('Route', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5, decoration: TextDecoration.none))),
                  Expanded(child: Center(child: Text('GET', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 11, decoration: TextDecoration.none)))),
                  Expanded(child: Center(child: Text('POST', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 11, decoration: TextDecoration.none)))),
                  Expanded(child: Center(child: Text('PATCH', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 11, decoration: TextDecoration.none)))),
                  Expanded(child: Center(child: Text('DEL', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 11, decoration: TextDecoration.none)))),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.divider),
            Expanded(child: _buildBody(routeProvider)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (!_dirty || isBusy) ? null : _savePermissions,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Permissions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(RouteProvider routeProvider) {
    if (routeProvider.status == LoadStatus.loading || routeProvider.status == LoadStatus.idle || _grantsStatus == LoadStatus.loading || _grantsStatus == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (routeProvider.status == LoadStatus.error || _grantsStatus == LoadStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 12),
              Text(routeProvider.errorMessage ?? _grantsError ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  routeProvider.fetchRoutes();
                  _loadGrants();
                },
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
              ),
            ],
          ),
        ),
      );
    }

    final query = _searchController.text.toLowerCase();
    final routes = query.isEmpty ? routeProvider.routes : routeProvider.routes.where((r) => r.name.toLowerCase().contains(query)).toList();
    if (routes.isEmpty) {
      return const Center(child: Text('No routes found.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: routes.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.divider),
      itemBuilder: (context, index) {
        final route = routes[index];
        final granted = _grants[route.name] ?? const {};
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(route.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none))),
              for (final permission in _kPermissions)
                Expanded(
                  child: Center(
                    child: Checkbox(
                      value: granted.contains(permission),
                      activeColor: AppTheme.primary,
                      onChanged: (_) => _toggle(route.name, permission),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
