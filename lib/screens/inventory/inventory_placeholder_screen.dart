import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;

/// Generic placeholder for Inventory sub-screens whose detailed UI hasn't
/// been built yet (Stock Item / Consumption / Suppliers / Measuring Unit /
/// Stock Group / Stock History browse lists, and the Consumption / Measuring
/// Unit "Add" forms) — mirrors [ReportDetailScreen]'s use of the shared
/// [InvoiceEmptyState] so every unbuilt screen still matches the app's style.
class InventoryPlaceholderScreen extends StatelessWidget {
  final String title;
  final String entityName;

  const InventoryPlaceholderScreen({super.key, required this.title, required this.entityName});

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
        title: Text(
          title,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(child: InvoiceEmptyState(entityName: entityName)),
    );
  }
}
