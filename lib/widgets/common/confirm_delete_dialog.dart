import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Shared "Delete this X?" confirmation dialog, matching the style used by
/// [DeleteRestaurantScreen]. Returns `true` if the user confirmed deletion.
Future<bool> confirmDelete(BuildContext context, {required String entityName}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete this $entityName?', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      content: const Text('This cannot be undone.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
      ],
    ),
  );
  return confirmed == true;
}
