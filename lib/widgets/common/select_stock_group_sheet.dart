import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock/stock_group_model.dart';
import '../../providers/stock_group_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../screens/inventory/add_stock_group_screen.dart';

/// Picker for a [StockGroup], sourced live from [StockGroupProvider]
/// (backend: `/api/stock-group`) — mirrors [SelectUnitSheet]'s search +
/// "Create" pattern.
class SelectStockGroupSheet extends StatefulWidget {
  final ValueChanged<StockGroup> onSelected;

  const SelectStockGroupSheet({super.key, required this.onSelected});

  static Future<void> show(BuildContext context, {required ValueChanged<StockGroup> onSelected}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectStockGroupSheet(onSelected: onSelected),
    );
  }

  @override
  State<SelectStockGroupSheet> createState() => _SelectStockGroupSheetState();
}

class _SelectStockGroupSheetState extends State<SelectStockGroupSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<StockGroupProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchStockGroups());
    }
  }

  List<StockGroup> _filtered(List<StockGroup> groups) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return groups;
    return groups.where((g) => g.groupName.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockGroupProvider>();
    final groups = _filtered(provider.groups);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Stock Group',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.card,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(decoration: TextDecoration.none),
                decoration: InputDecoration(
                  hintText: 'Search here',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: provider.status == LoadStatus.loading || provider.status == LoadStatus.idle
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              widget.onSelected(group);
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.divider),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                group.groupName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Total Stock Group : ${provider.groups.length}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push<StockGroup>(
                      context,
                      MaterialPageRoute(builder: (context) => const AddStockGroupScreen()),
                    );
                    if (result != null && context.mounted) {
                      widget.onSelected(result);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Create Group',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
