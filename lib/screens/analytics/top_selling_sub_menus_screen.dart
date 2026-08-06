import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/select_printer_sheet.dart';

/// "Top Selling Sub Menus" screen reached from the Order tab's "Sales by Sub
/// Menu" card via its "View All" action. Shows the Rank/Name/Amount table
/// matching the reference design, with a Print action (mirroring the Order
/// Service Overview card's outlined Print button) that opens
/// [SelectPrinterSheet].
class TopSellingSubMenusScreen extends StatelessWidget {
  const TopSellingSubMenusScreen({super.key});

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
        title: const Text(
          'Top Selling Sub Menus',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: () => SelectPrinterSheet.show(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.divider),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.print_outlined, color: AppTheme.textPrimary, size: 18),
              label: const Text('Print', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
            child: Column(
              children: [
                Container(
                  color: AppTheme.card,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Rank', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('Name', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Amount',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Total Top Selling Sub Menus : 0',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
