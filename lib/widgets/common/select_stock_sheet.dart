import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock/stock_model.dart';
import '../../providers/stock_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../screens/inventory/add_stock_item_screen.dart';

/// "Select Stock" / "Select Stock Item" sheet, sourced live from
/// [StockProvider] (backend: `/api/stock`) — falls back to the reference
/// design's "No Stock" empty state only when the real list is actually
/// empty. Shared by Consumption's Stocks picker and Stock History's Filter
/// sheet.
class SelectStockSheet extends StatefulWidget {
  final String title;
  const SelectStockSheet({super.key, this.title = 'Select Stock'});

  static Future<Stock?> show(BuildContext context, {String title = 'Select Stock'}) {
    return showModalBottomSheet<Stock>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectStockSheet(title: title),
    );
  }

  @override
  State<SelectStockSheet> createState() => _SelectStockSheetState();
}

class _SelectStockSheetState extends State<SelectStockSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<StockProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchStocks());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Stock> _filtered(List<Stock> stocks) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return stocks;
    return stocks.where((s) => s.itemName.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                      Expanded(child: _buildBody(provider, scrollController)),
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

  Widget _buildBody(StockProvider provider, ScrollController scrollController) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    if (provider.stocks.isEmpty) {
      return SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.card, shape: BoxShape.circle, border: Border.all(color: AppTheme.divider)),
              child: const Icon(Icons.receipt_long_outlined, color: AppTheme.cancelled, size: 48),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                children: [
                  TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                  TextSpan(text: 'Stock', style: TextStyle(color: AppTheme.cancelled)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No Stock found. Needs to create the Stock!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context, rootNavigator: true);
                  Navigator.pop(context);
                  await navigator.push(MaterialPageRoute(builder: (context) => const AddStockItemScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Create New Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      );
    }

    final stocks = _filtered(provider.stocks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          decoration: InputDecoration(
            hintText: 'Search here',
            hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: stocks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(context, stock),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(stock.itemName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                      ),
                      Text('${stock.quantity}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
