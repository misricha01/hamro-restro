import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/stock_group_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/unit_provider.dart';
import '../../widgets/common/setting_rows_card.dart';
import '../create_users/add_supplier_screen.dart';
import 'add_consumption_screen.dart';
import 'add_measuring_unit_screen.dart';
import 'add_stock_item_screen.dart';
import 'inventory_add_menu_sheet.dart';
import 'measuring_unit_screen.dart';
import 'stock_group_screen.dart';
import 'stock_history_screen.dart';

/// "Inventory" screen reached from Manage > Inventory > View All / "3 more
/// features". Summary counts are sourced live from [StockProvider]
/// (`GET /api/stock/stats`), [StockGroupProvider] and [UnitProvider];
/// "Consumption" reflects `reduce`-type entries already fetched into
/// [StockProvider.history] (no dedicated consumption-count endpoint exists),
/// so it reads 0 until Stock History has been opened at least once.
class InventoryFeaturesScreen extends StatefulWidget {
  const InventoryFeaturesScreen({super.key});

  @override
  State<InventoryFeaturesScreen> createState() => _InventoryFeaturesScreenState();
}

class _InventoryFeaturesScreenState extends State<InventoryFeaturesScreen> {
  @override
  void initState() {
    super.initState();
    final stockProvider = context.read<StockProvider>();
    final groupProvider = context.read<StockGroupProvider>();
    final unitProvider = context.read<UnitProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stockProvider.fetchStats();
      if (stockProvider.status == LoadStatus.idle) stockProvider.fetchStocks();
      if (groupProvider.status == LoadStatus.idle) groupProvider.fetchStockGroups();
      if (unitProvider.status == LoadStatus.idle) unitProvider.fetchUnits();
    });
  }

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
          'Inventory',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const _InventorySummaryCard(),
            const SizedBox(height: 16),
            SettingRowsCard(
              items: [
                SettingRowData(
                  icon: Icons.inventory_2_outlined,
                  title: 'Stock Item',
                  subtitle: 'All Stock & items of restaurant',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddStockItemScreen())),
                ),
                SettingRowData(
                  icon: Icons.create_new_folder_outlined,
                  title: 'Consumption',
                  subtitle: 'Amount of stock to reduced by sales',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddConsumptionScreen())),
                ),
                SettingRowData(
                  icon: Icons.people_outline,
                  title: 'Suppliers',
                  subtitle: 'List of suppliers of restaurant',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSupplierScreen())),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingRowsCard(
              items: [
                SettingRowData(
                  icon: Icons.straighten,
                  title: 'Measuring Unit',
                  subtitle: 'Calculate unit conversion',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MeasuringUnitScreen())),
                ),
                SettingRowData(
                  icon: Icons.category_outlined,
                  title: 'Stock Group',
                  subtitle: 'Categories your inventory',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StockGroupScreen())),
                ),
                SettingRowData(
                  icon: Icons.layers_outlined,
                  title: 'Stock History',
                  subtitle: 'Stock history of items',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StockHistoryScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySummaryCard extends StatelessWidget {
  const _InventorySummaryCard();

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();
    final groupProvider = context.watch<StockGroupProvider>();
    final unitProvider = context.watch<UnitProvider>();

    final stockItemCount = stockProvider.stats?.totalStocks ?? stockProvider.stocks.length;
    final consumptionCount = stockProvider.history.where((t) => t.type.toLowerCase() == 'reduce').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Summary', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SummaryStat(value: '$stockItemCount', label: 'Stock Item', color: AppTheme.textPrimary)),
              Expanded(child: _SummaryStat(value: '$consumptionCount', label: 'Consumption', color: AppTheme.completed)),
              Expanded(child: _SummaryStat(value: '${unitProvider.units.length}', label: 'Measuring Unit', color: AppTheme.pending)),
              Expanded(child: _SummaryStat(value: '${groupProvider.groups.length}', label: 'Stock Group', color: AppTheme.accent)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _AddChip(onTap: () => InventoryAddMenuSheet.show(context)),
                const SizedBox(width: 10),
                _QuickActionChip(label: 'Stock Item', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddStockItemScreen()))),
                const SizedBox(width: 10),
                _QuickActionChip(label: 'Suppliers', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSupplierScreen()))),
                const SizedBox(width: 10),
                _QuickActionChip(
                  label: 'Consumption',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddConsumptionScreen())),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  label: 'Measuring Unit',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMeasuringUnitScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _SummaryStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20, decoration: TextDecoration.none)),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
        ),
      ],
    );
  }
}

class _AddChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppTheme.textPrimary, size: 18),
            SizedBox(width: 6),
            Text('Add', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppTheme.cancelled, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
      ),
    );
  }
}
