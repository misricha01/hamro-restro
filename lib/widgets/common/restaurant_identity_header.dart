import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Restaurant avatar + name + plan/role badges, shared by the Delete
/// Restaurant and Reset Restaurant confirmation screens (and matching the
/// Manage screen's business card) instead of each re-declaring it.
class RestaurantIdentityHeader extends StatelessWidget {
  final String initials;
  final String name;
  final String planLabel;
  final String roleLabel;

  const RestaurantIdentityHeader({
    super.key,
    this.initials = 'RE',
    this.name = 'Restrox',
    this.planLabel = 'Premium (Trial)',
    this.roleLabel = 'Role: SuperAdmin',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
          child: Text(initials, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none)),
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
              child: Text(planLabel, style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8)),
              child: Text(roleLabel, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none)),
            ),
          ],
        ),
      ],
    );
  }
}
