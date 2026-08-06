import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/role_model.dart';
import '../../models/role_style.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/role_provider.dart';

/// Picker for a [Role], sourced live from [RoleProvider] (backend:
/// `GET /api/roles`) — this restaurant's actual, freely-editable roles
/// rather than a fixed list. Colors/icons come from [role_style] (built-in
/// palette for the 5 common role names, deterministic fallback otherwise).
class SelectRoleSheet extends StatefulWidget {
  final String? initialRoleName;
  final ValueChanged<Role> onSelected;

  const SelectRoleSheet({super.key, this.initialRoleName, required this.onSelected});

  static Future<void> show(BuildContext context, {String? initialRoleName, required ValueChanged<Role> onSelected}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectRoleSheet(initialRoleName: initialRoleName, onSelected: onSelected),
    );
  }

  @override
  State<SelectRoleSheet> createState() => _SelectRoleSheetState();
}

class _SelectRoleSheetState extends State<SelectRoleSheet> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<RoleProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchRoles());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoleProvider>();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Role',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.card,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.completed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Select the role for staff to define their permissions and access level in the system.',
                  style: TextStyle(color: AppTheme.completed, fontSize: 13, decoration: TextDecoration.none),
                ),
              ),
              const SizedBox(height: 16),
              if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle)
                const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))
              else if (provider.status == LoadStatus.error)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(provider.errorMessage ?? 'Something went wrong.', style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => provider.fetchRoles(),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                        child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                      ),
                    ],
                  ),
                )
              else if (provider.roles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No roles created yet.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: provider.roles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final role = provider.roles[index];
                      final selected = role.name == widget.initialRoleName;
                      final color = roleColorFor(role.name);
                      return Material(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            widget.onSelected(role);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: selected ? color : AppTheme.divider, width: 2),
                                    color: AppTheme.surface,
                                  ),
                                  child: selected
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    role.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(roleIconFor(role.name), color: color, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
