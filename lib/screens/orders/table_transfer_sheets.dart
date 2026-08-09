import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/orders/table_model.dart';
import '../../providers/table_provider.dart';

bool _isOccupied(RestaurantTable table) => table.tableStatus.toLowerCase() == 'occupied';

/// Long-press menu for a table in the Table tab's grid. Move/Merge only show
/// for a table with an active order (`tableStatus == 'Occupied'`) — moving
/// or merging an empty table is a no-op the backend itself would reject.
class TableActionsSheet {
  static Future<String?> show(BuildContext context, {required RestaurantTable table}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TableActionsSheetContent(table: table),
    );
  }
}

class _TableActionsSheetContent extends StatelessWidget {
  final RestaurantTable table;
  const _TableActionsSheetContent({required this.table});

  @override
  Widget build(BuildContext context) {
    final occupied = _isOccupied(table);
    return Container(
      decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(table.tableName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
              const SizedBox(height: 12),
              _ActionRow(icon: Icons.edit_outlined, label: 'Edit', onTap: () => Navigator.pop(context, 'edit')),
              const Divider(height: 1, color: AppTheme.divider),
              if (occupied) ...[
                _ActionRow(icon: Icons.swap_horiz, label: 'Move Table', onTap: () => Navigator.pop(context, 'move')),
                const Divider(height: 1, color: AppTheme.divider),
                _ActionRow(icon: Icons.call_merge, label: 'Merge Tables', onTap: () => Navigator.pop(context, 'merge')),
                const Divider(height: 1, color: AppTheme.divider),
              ],
              _ActionRow(icon: Icons.delete_outline, label: 'Delete', color: AppTheme.cancelled, onTap: () => Navigator.pop(context, 'delete')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ActionRow({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

/// Single-table picker shared by Move Table (pick a destination) and Merge
/// Tables (pick the "merge into" destination). Operates on an
/// already-loaded [tables] list rather than fetching its own — the Table
/// tab has always already loaded it by the time either flow can be opened.
class SelectTableSheet extends StatelessWidget {
  final List<RestaurantTable> tables;
  final String title;

  const SelectTableSheet({super.key, required this.tables, this.title = 'Select Table'});

  static Future<RestaurantTable?> show(BuildContext context, {required List<RestaurantTable> tables, String title = 'Select Table'}) {
    return showModalBottomSheet<RestaurantTable>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectTableSheet(tables: tables, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
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
                      Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: tables.isEmpty
                            ? const Center(child: Text('No other tables available.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)))
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: tables.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final table = tables[index];
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => Navigator.pop(context, table),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                                            child: const Icon(Icons.table_bar_outlined, color: AppTheme.accent, size: 22),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(child: Text(table.tableName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(color: (_isOccupied(table) ? AppTheme.pending : AppTheme.completed).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)),
                                            child: Text(
                                              table.tableStatus,
                                              style: TextStyle(color: _isOccupied(table) ? AppTheme.pending : AppTheme.completed, fontSize: 11, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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

/// Full-screen "Merge Tables" flow: check any number of source tables (the
/// long-pressed table is pre-checked), pick one destination via
/// [SelectTableSheet], then `POST /api/table-order/merge-table`
/// (`TableProvider.mergeTables`). The destination doesn't have to be one of
/// the checked sources — confirmed live: merging into an already-occupied
/// table simply adds another active order to it.
class MergeTablesScreen extends StatefulWidget {
  final String initialTableId;
  const MergeTablesScreen({super.key, required this.initialTableId});

  @override
  State<MergeTablesScreen> createState() => _MergeTablesScreenState();
}

class _MergeTablesScreenState extends State<MergeTablesScreen> {
  late final Set<String> _selectedSourceIds = {widget.initialTableId};
  RestaurantTable? _destination;

  void _toggleSource(String id) {
    setState(() {
      if (_selectedSourceIds.contains(id)) {
        _selectedSourceIds.remove(id);
      } else {
        _selectedSourceIds.add(id);
      }
      // The destination can't also be a source.
      if (_destination != null && _selectedSourceIds.contains(_destination!.id)) {
        _destination = null;
      }
    });
  }

  Future<void> _pickDestination(List<RestaurantTable> tables) async {
    final candidates = tables.where((t) => !_selectedSourceIds.contains(t.id)).toList();
    final result = await SelectTableSheet.show(context, tables: candidates, title: 'Merge Into');
    if (result != null) setState(() => _destination = result);
  }

  Future<void> _merge() async {
    final destination = _destination;
    if (_selectedSourceIds.isEmpty || destination == null) return;

    final provider = context.read<TableProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final message = await provider.mergeTables(fromTableIds: _selectedSourceIds.toList(), toTableId: destination.id);
    if (!mounted) return;

    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context, true);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(provider.mergeErrorMessage ?? 'Failed to merge tables')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TableProvider>();
    final tables = provider.tables;

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
        title: const Text('Merge Tables', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Select the tables whose orders should be combined.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: tables.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final table = tables[index];
                  final selected = _selectedSourceIds.contains(table.id);
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _toggleSource(table.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider)),
                      child: Row(
                        children: [
                          Icon(selected ? Icons.check_box : Icons.check_box_outline_blank, color: selected ? AppTheme.accent : AppTheme.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(table.tableName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: (_isOccupied(table) ? AppTheme.pending : AppTheme.completed).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              table.tableStatus,
                              style: TextStyle(color: _isOccupied(table) ? AppTheme.pending : AppTheme.completed, fontSize: 11, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Merge Into', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _pickDestination(tables),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _destination?.tableName ?? 'Select destination table',
                              style: TextStyle(color: _destination != null ? AppTheme.textPrimary : AppTheme.textSecondary, decoration: TextDecoration.none),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedSourceIds.isEmpty || _destination == null || provider.isMerging) ? null : _merge,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: provider.isMerging
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('Merge Tables', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
