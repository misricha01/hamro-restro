import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable top-right "⋮" app bar action shared by the Menu Setup screens
/// (Default Menu Set, Sub Menu detail) — matches the reference screenshot's
/// dropdown: Edit, a divider, then Help, with "Move To Trash" in red between
/// them. [onHelp] defaults to a "coming soon" snackbar, matching how this
/// app already handles other not-yet-built help/support links (see
/// MenuOverviewScreen's "Learn More"/"Need Help?" rows) rather than a dead
/// no-op.
class MenuItemActionsMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onMoveToTrash;
  final VoidCallback? onHelp;

  const MenuItemActionsMenu({super.key, required this.onEdit, required this.onMoveToTrash, this.onHelp});

  void _defaultHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help is coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        color: AppTheme.surface,
        elevation: 6,
        offset: const Offset(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.divider)),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit();
            case 'trash':
              onMoveToTrash();
            case 'help':
              (onHelp ?? () => _defaultHelp(context))();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: _ActionRow(icon: Icons.edit_outlined, label: 'Edit', color: AppTheme.textPrimary)),
          const PopupMenuItem(value: 'trash', child: _ActionRow(icon: Icons.delete_outline, label: 'Move To Trash', color: AppTheme.cancelled)),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'help', child: _ActionRow(icon: Icons.help_outline, label: 'Help', color: AppTheme.textPrimary)),
        ],
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionRow({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 14),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
      ],
    );
  }
}
