import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../create_users/add_supplier_screen.dart';
import 'add_consumption_screen.dart';
import 'add_measuring_unit_screen.dart';
import 'add_stock_item_screen.dart';

/// "+ Add" menu shown from the Inventory Features screen, offering Stock
/// Item / Suppliers / Consumption / Measuring Unit — matching the reference
/// design's red quick-action row, but as a single tappable menu instead of
/// four always-visible chips. Follows the same modal-sheet shape as
/// [OrderActionsSheet] (title + close button + one bordered action group).
class InventoryAddMenuSheet extends StatelessWidget {
  const InventoryAddMenuSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InventoryAddMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                  ),
                ),
              ),
              const Text(
                'Add',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 16),
              Material(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _AddMenuRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Stock Item',
                      onTap: () => _open(context, const AddStockItemScreen()),
                    ),
                    const Divider(height: 1, color: AppTheme.divider),
                    _AddMenuRow(
                      icon: Icons.people_outline,
                      label: 'Suppliers',
                      onTap: () => _open(context, const AddSupplierScreen()),
                    ),
                    const Divider(height: 1, color: AppTheme.divider),
                    _AddMenuRow(
                      icon: Icons.create_new_folder_outlined,
                      label: 'Consumption',
                      onTap: () => _open(context, const AddConsumptionScreen()),
                    ),
                    const Divider(height: 1, color: AppTheme.divider),
                    _AddMenuRow(
                      icon: Icons.straighten,
                      label: 'Measuring Unit',
                      onTap: () => _open(context, const AddMeasuringUnitScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}

class _AddMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AddMenuRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: AppTheme.textPrimary),
            ),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}
