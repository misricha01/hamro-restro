import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock/stock_group_model.dart';
import '../../data/models/stock/stock_model.dart';
import '../../providers/stock_group_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/common/edit_delete_actions_sheet.dart';
import '../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;
import 'add_stock_group_screen.dart';
import 'add_stock_item_screen.dart';

/// "Stock Group" detail sheet opened from a row on [StockGroupScreen],
/// matching the reference design's group summary card (No of Item /
/// Description) followed by an "Items Using This Group" table, populated
/// live from [StockProvider.stocks] filtered by `stockGroupId` (the same
/// filter [StockGroupScreen] already uses for its own item count) — empty
/// only when no stock item actually references this group yet. The group's
/// "..." menu opens [EditDeleteActionsSheet] — Edit pushes
/// [AddStockGroupScreen] in edit mode (`StockGroupProvider.updateStockGroup`),
/// Delete confirms then calls `StockGroupProvider.deleteStockGroup`. Each
/// item row has its own delete action calling `StockProvider.deleteStock`
/// (`/api/stock` has no dedicated "list items in group" endpoint, so this is
/// currently the only place in the app a stock item can be deleted from —
/// there's no separate item management screen).
class StockGroupDetailSheet extends StatelessWidget {
  final StockGroup group;
  final int itemCount;

  const StockGroupDetailSheet({super.key, required this.group, required this.itemCount});

  static Future<void> show(BuildContext context, {required StockGroup group, required int itemCount}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StockGroupDetailSheet(group: group, itemCount: itemCount),
    );
  }

  Future<void> _openActions(BuildContext context) async {
    final action = await EditDeleteActionsSheet.show(context, title: group.groupName);
    if (!context.mounted) return;
    if (action == 'edit') {
      Navigator.pop(context); // close this sheet first
      await Navigator.push(context, MaterialPageRoute(builder: (context) => AddStockGroupScreen(existingGroup: group)));
    } else if (action == 'delete') {
      await _confirmDelete(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Stock Group', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          'Remove "${group.groupName}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<StockGroupProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final success = await provider.deleteStockGroup(group.id);
    if (success) {
      if (context.mounted) navigator.pop(); // close this sheet
    } else if (context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to delete stock group')));
    }
  }

  Future<void> _openStockActions(BuildContext context, Stock stock) async {
    final action = await EditDeleteActionsSheet.show(context, title: stock.itemName);
    if (!context.mounted) return;
    if (action == 'edit') {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => AddStockItemScreen(existingStock: stock)));
    } else if (action == 'delete') {
      await _confirmDeleteStock(context, stock);
    }
  }

  Future<void> _confirmDeleteStock(BuildContext context, Stock stock) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Stock Item', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          'Remove "${stock.itemName}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<StockProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteStock(stock.id);
    if (!success && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to delete stock item')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stock Group', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(group.groupName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                              ),
                              InkWell(
                                onTap: () => _openActions(context),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.more_horiz, color: AppTheme.textSecondary, size: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _DetailRow(label: 'No of Item', value: '$itemCount'),
                          if ((group.groupDescription ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _DetailRow(label: 'Description', value: group.groupDescription!),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Items Using This Group', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15.5, decoration: TextDecoration.none)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('S.N', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5, decoration: TextDecoration.none))),
                          Expanded(flex: 4, child: Text('Stock Item', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5, decoration: TextDecoration.none))),
                          Expanded(flex: 3, child: Text('Default Price', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5, decoration: TextDecoration.none))),
                          Expanded(flex: 3, child: Text('Stock Value', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5, decoration: TextDecoration.none))),
                          SizedBox(width: 28),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Consumer<StockProvider>(
                        builder: (context, stockProvider, _) {
                          final items = stockProvider.stocks.where((s) => s.stockGroupId == group.id).toList();
                          if (items.isEmpty) return const InvoiceEmptyState(entityName: 'Items');
                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: AppTheme.divider),
                            itemBuilder: (context, index) {
                              final stock = items[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text('${index + 1}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none))),
                                    Expanded(flex: 4, child: Text(stock.itemName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none))),
                                    Expanded(flex: 3, child: Text('Rs ${stock.defaultPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none))),
                                    Expanded(flex: 3, child: Text('Rs ${(stock.quantity * stock.rate).toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none))),
                                    SizedBox(
                                      width: 28,
                                      child: GestureDetector(
                                        onTap: () => _openStockActions(context, stock),
                                        child: const Icon(Icons.more_horiz, color: AppTheme.textSecondary, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                  ),
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none),
          ),
        ),
      ],
    );
  }
}
