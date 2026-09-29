import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/dish/dish_model.dart';
import '../../data/repositories/dish_repository.dart' show DishStats, DishTransaction;
import '../../providers/dish_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/analytics_cards.dart';
import '../create_dish/add_dish_screen.dart' show AddDishScreen;

/// Dishes list for the Manage screen, backed by [DishProvider]
/// (`GET /api/dish`). Tapping "+" pushes [AddDishScreen]; since
/// [DishProvider] is a shared singleton, a dish created there already shows
/// up here without an explicit refresh.
class ManageDishesScreen extends StatefulWidget {
  const ManageDishesScreen({super.key});

  @override
  State<ManageDishesScreen> createState() => _ManageDishesScreenState();
}

class _ManageDishesScreenState extends State<ManageDishesScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<DishProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchDishes());
    }
    if (provider.dishStatsStatus == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchDishStats());
    }
  }

  @override
  Widget build(BuildContext context) {
    final dishProvider = context.watch<DishProvider>();

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
          'Dishes',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDishScreen())),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.divider),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: AppTheme.accent),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (dishProvider.dishStatsStatus == LoadStatus.loaded && dishProvider.dishStats != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _dishStatsCard(dishProvider.dishStats!),
              ),
            Expanded(child: _buildBody(dishProvider)),
          ],
        ),
      ),
    );
  }

  Widget _dishStatsCard(DishStats stats) {
    return AnalyticsLegendCard(
      title: 'Dish Stats',
      rows: [
        AnalyticsLegendRowData(label: 'Active Dishes', value: '${stats.activeDish}/${stats.totalDish}'),
        if (stats.topSoldName != null)
          AnalyticsLegendRowData(label: 'Top Sold', value: '${stats.topSoldName} (${stats.topSoldOrders ?? 0} orders)'),
        if (stats.topDishTypeName != null)
          AnalyticsLegendRowData(label: 'Top Type', value: '${stats.topDishTypeName} (${stats.topDishTypeCount ?? 0} dishes)'),
      ],
    );
  }

  Widget _buildBody(DishProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(
                  provider.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => provider.fetchDishes(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.dishes.isEmpty) {
          return const Center(
            child: Text(
              'No Dishes created yet.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 210,
                ),
                itemCount: provider.dishes.length,
                itemBuilder: (context, index) => _DishManageCard(dish: provider.dishes[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                'Total Dish : ${provider.dishes.length}',
                style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none),
              ),
            ),
          ],
        );
    }
  }
}

class _DishManageCard extends StatelessWidget {
  final Dish dish;
  const _DishManageCard({required this.dish});

  String get _priceLabel {
    final price = dish.priceAfterDiscount ?? dish.price;
    return price == null ? 'Rs —' : 'Rs ${price.toStringAsFixed(0)}';
  }

  Future<void> _edit(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddDishScreen(existingDish: dish)));
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Dish', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          'Remove "${dish.dishName}" from your menu? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<DishProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await provider.deleteDish(dish.id);
    if (!success && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Failed to delete dish')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 75,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const Icon(Icons.restaurant_menu, size: 34, color: AppTheme.accent),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  dish.dishName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 2),
                Text(
                  _priceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accent, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _edit(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: AppTheme.textPrimary),
                        SizedBox(width: 4),
                        Text('Edit', style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => DishTransactionsSheet.show(context, dish: dish),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.receipt_long_outlined, size: 16, color: AppTheme.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _delete(context),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_outline, size: 16, color: AppTheme.cancelled),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _txnMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _txnDate(DateTime? d) => d == null ? '—' : '${_txnMonths[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

String _txnRs(double v) => 'Rs ${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

/// "Transactions" bottom sheet reached from a dish card's receipt icon,
/// backed by `GET /api/dish/{id}/transactions` — there's no dish-detail
/// screen in the app yet, so this is a lightweight sheet rather than a full
/// new screen (checkoutId/amount/quantity/invoice number per Swagger).
class DishTransactionsSheet extends StatefulWidget {
  final Dish dish;
  const DishTransactionsSheet({super.key, required this.dish});

  static Future<void> show(BuildContext context, {required Dish dish}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DishTransactionsSheet(dish: dish),
    );
  }

  @override
  State<DishTransactionsSheet> createState() => _DishTransactionsSheetState();
}

class _DishTransactionsSheetState extends State<DishTransactionsSheet> {
  late Future<List<DishTransaction>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<DishProvider>().getDishTransactions(widget.dish.id);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.dish.dishName} — Transactions',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<DishTransaction>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Could not load transactions.', style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                          );
                        }
                        final transactions = snapshot.data ?? [];
                        if (transactions.isEmpty) {
                          return const Center(
                            child: Text('No transactions yet for this dish.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
                          );
                        }
                        return ListView.separated(
                          controller: scrollController,
                          itemCount: transactions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final txn = transactions[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          txn.invoiceNumber ?? 'Checkout #${txn.checkoutId ?? '—'}',
                                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(_txnDate(txn.date), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none)),
                                      ],
                                    ),
                                  ),
                                  Text('x${txn.quantity}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                  const SizedBox(width: 12),
                                  Text(_txnRs(txn.amount), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none)),
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
          ),
        );
      },
    );
  }
}

