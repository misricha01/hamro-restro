import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Bordered card with a bold title + switch on top and a description below,
/// used for standalone on/off settings (Website's Delivery Service / Share
/// My Menu toggles, SMS Events toggles, etc).
class ToggleCard extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleCard({super.key, required this.title, required this.description, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none))),
              Switch(value: value, activeThumbColor: Colors.white, activeTrackColor: AppTheme.completed, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}
