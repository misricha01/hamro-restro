import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// One row (icon + title + subtitle + chevron) inside a [SettingRowsCard].
/// Set [danger] for destructive entries (e.g. "Reset & Delete") to render
/// the icon, title and chevron in the app's cancelled/red tone.
class SettingRowData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool danger;
  final VoidCallback onTap;
  /// When set, the row shows a [Switch] instead of a chevron (e.g. quick
  /// enable/disable rows like Dine In Service / Delivery Services on the
  /// Services screen).
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  SettingRowData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.danger = false,
    required this.onTap,
    this.toggleValue,
    this.onToggleChanged,
  });
}

/// Bordered card grouping related settings/menu rows, matching the
/// Dish Setup / Menu Setup groups on the Menu overview screen and the
/// General Setting / Order Setting / Dangerous Area groups on the
/// Restaurant Setting screen.
class SettingRowsCard extends StatelessWidget {
  final List<SettingRowData> items;
  const SettingRowsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTheme.divider),
            _SettingRow(data: items[i]),
          ],
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final SettingRowData data;
  const _SettingRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.danger ? AppTheme.cancelled : AppTheme.textPrimary;
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(data.icon, color: color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
                      ),
                      if (data.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.completed.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            data.badge!,
                            style: const TextStyle(color: AppTheme.completed, fontWeight: FontWeight.w600, fontSize: 11, decoration: TextDecoration.none),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                  ),
                ],
              ),
            ),
            if (data.toggleValue != null)
              Switch(value: data.toggleValue!, activeThumbColor: Colors.white, activeTrackColor: AppTheme.completed, onChanged: data.onToggleChanged)
            else
              Icon(Icons.chevron_right, color: data.danger ? AppTheme.cancelled : AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
