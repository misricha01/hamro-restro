import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Shared "No X found" empty state used by every simple list screen reached
/// from Orders' 3-dot Actions menu (Saved Order, KOT History, Recent
/// Transactions, Printers, Cancelled History) so each one doesn't hand-roll
/// its own illustration + copy + action button layout.
class SettingEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showLearnMore;

  const SettingEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.showLearnMore = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_outlined, size: 110, color: AppTheme.accent.withValues(alpha: 0.3)),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none),
                children: [
                  const TextSpan(text: 'No '),
                  TextSpan(text: title, style: const TextStyle(color: AppTheme.accent)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.4, decoration: TextDecoration.none),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(actionLabel!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
                ),
              ),
            ],
            if (showLearnMore) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening help article...'))),
                child: const Text('Learn More', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
