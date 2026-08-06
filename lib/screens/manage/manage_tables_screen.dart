import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../orders/orders_screen.dart' show TableListTab;

/// Table list for the Manage screen. Reuses the existing [TableListTab]
/// widget (also used by the Orders "Table" tab) so both places show the
/// exact same tables, layout and styling.
class ManageTablesScreen extends StatelessWidget {
  const ManageTablesScreen({super.key});

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
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Table',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: const SafeArea(child: TableListTab()),
    );
  }
}
