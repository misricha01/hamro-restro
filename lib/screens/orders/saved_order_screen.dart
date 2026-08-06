import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/setting_empty_state.dart';

/// "Last Saved Orders - Offline" reached from Orders' 3-dot Actions menu.
class SavedOrderScreen extends StatelessWidget {
  const SavedOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lastSynced = DateTime.now();
    final formatted =
        '${lastSynced.year}-${lastSynced.month.toString().padLeft(2, '0')}-${lastSynced.day.toString().padLeft(2, '0')} '
        '${(lastSynced.hour % 12 == 0 ? 12 : lastSynced.hour % 12).toString().padLeft(2, '0')}:${lastSynced.minute.toString().padLeft(2, '0')} '
        '${lastSynced.hour >= 12 ? 'PM' : 'AM'}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text('Saved Order', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppTheme.textPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_alt_outlined, color: AppTheme.textPrimary), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, decoration: TextDecoration.none),
                  children: [
                    const TextSpan(text: 'Last Synced : ', style: TextStyle(color: AppTheme.accent)),
                    TextSpan(text: formatted, style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppTheme.divider),
            const Expanded(
              child: SettingEmptyState(title: 'Order', subtitle: 'No Order Found.', showLearnMore: false),
            ),
          ],
        ),
      ),
    );
  }
}
