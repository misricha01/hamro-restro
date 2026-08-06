import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/setting_rows_card.dart';
import 'delete_restaurant_screen.dart';
import 'reset_restaurant_screen.dart';

/// "Reset & Delete" screen reached from Manage > Setting > Dangerous Area:
/// entry point for the two irreversible restaurant-level actions.
class ResetDeleteScreen extends StatelessWidget {
  const ResetDeleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Reset & Delete', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SettingRowsCard(
            items: [
              SettingRowData(
                icon: Icons.sync_alt,
                title: 'Reset Restaurant',
                subtitle: 'Reset data you want to start as new',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetRestaurantScreen())),
              ),
              SettingRowData(
                icon: Icons.delete_outline,
                title: 'Delete Restaurant',
                subtitle: 'Complete restaurant will be deleted',
                danger: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteRestaurantScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
