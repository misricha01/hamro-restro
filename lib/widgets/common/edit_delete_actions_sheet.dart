import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Small "Edit" / "Delete" action sheet shared by the Space list row and the
/// Table grid's long-press menu. Returns `'edit'`, `'delete'`, or `null` if
/// dismissed without a choice.
class EditDeleteActionsSheet {
  static Future<String?> show(BuildContext context, {required String title}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
                const SizedBox(height: 12),
                _ActionRow(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: () => Navigator.pop(context, 'edit'),
                ),
                const Divider(height: 1, color: AppTheme.divider),
                _ActionRow(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: AppTheme.cancelled,
                  onTap: () => Navigator.pop(context, 'delete'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ActionRow({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}
