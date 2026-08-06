import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;

/// "Stock Group" detail sheet opened from a row on [StockGroupScreen],
/// matching the reference design's group summary card (No of Item /
/// Description) followed by an "Items Using This Group" table that's empty
/// until stock items reference this group.
class StockGroupDetailSheet extends StatelessWidget {
  final String name;
  final String description;
  final int itemCount;

  const StockGroupDetailSheet({super.key, required this.name, required this.description, required this.itemCount});

  static Future<void> show(BuildContext context, {required String name, required String description, required int itemCount}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StockGroupDetailSheet(name: name, description: description, itemCount: itemCount),
    );
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
                                child: Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                              ),
                              InkWell(
                                onTap: () {},
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
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _DetailRow(label: 'Description', value: description),
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
                          Expanded(flex: 4, child: Text('Default Price', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5, decoration: TextDecoration.none))),
                          Expanded(flex: 3, child: Text('Stock Value', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5, decoration: TextDecoration.none))),
                        ],
                      ),
                    ),
                    const Expanded(child: InvoiceEmptyState(entityName: 'Items')),
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
