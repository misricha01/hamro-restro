import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// App bar action icon shared by the Manage list screens (Combo Offer,
/// Menu Set, Sub Menu). Search/filter render as plain tinted icons that turn
/// red while active; the "more" action keeps the bordered-box look already
/// used by ManageScreen's header and the Dishes/Category "+" actions.
class ManageAppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool bordered;

  const ManageAppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.cancelled : AppTheme.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: bordered
              ? BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10))
              : null,
          child: Icon(icon, color: color, size: bordered ? 20 : 22),
        ),
      ),
    );
  }
}

/// Toggleable "Search here" field shown below a Manage list screen's app
/// bar, with the red clear/close action seen in the Combo Offer / Menu Set /
/// Sub Menu reference screens.
class ManageSearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClose;
  final ValueChanged<String> onChanged;

  const ManageSearchField({
    super.key,
    required this.controller,
    required this.onClose,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
        child: TextField(
          controller: controller,
          autofocus: true,
          onChanged: onChanged,
          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          decoration: InputDecoration(
            hintText: 'Search here',
            hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
            suffixIcon: GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close, color: AppTheme.cancelled),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

/// Rounded pill used to open a filter sheet (e.g. "Status") from a Manage
/// list screen, matching the Sub Menu reference screenshot.
class ManageFilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const ManageFilterChip({super.key, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value == null ? label : '$label: $value',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
