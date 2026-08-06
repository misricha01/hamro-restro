import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Centered "No [label]" placeholder used by SMS Log and Purchase History
/// when there's nothing to show yet.
class SmsEmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const SmsEmptyState({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.cancelled.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.cancelled, size: 40),
          ),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              children: [
                const TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                TextSpan(text: label, style: const TextStyle(color: AppTheme.cancelled)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
