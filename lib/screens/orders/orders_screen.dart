import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/orders/order_model.dart';
import '../../data/models/orders/table_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/table_provider.dart';
import '../../widgets/common/confirm_delete_dialog.dart';
import '../../widgets/common/edit_delete_actions_sheet.dart';
import '../../widgets/common/order_actions_sheet.dart';
import '../../widgets/common/order_empty_state.dart';
import '../manage/add_table_screen.dart';
import '../notification/notification_screen.dart';
import '../quick_billing/quick_billing_screen.dart';
import 'checkout_screen.dart';
import 'saved_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              OrderActionsSheet.show(context);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
          unselectedLabelStyle: const TextStyle(
            decoration: TextDecoration.none,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Table'),
            Tab(text: 'KOT'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ActiveOrdersTab(),
          TableListTab(),
          _KotTab(),
        ],
      ),
    );
  }
}

// ---------------- Active Tab ----------------

class _ActiveOrdersTab extends StatefulWidget {
  const _ActiveOrdersTab();

  @override
  State<_ActiveOrdersTab> createState() => _ActiveOrdersTabState();
}

class _ActiveOrdersTabState extends State<_ActiveOrdersTab> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<OrderProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchOrders());
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    switch (orderProvider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(
          message: orderProvider.errorMessage ?? 'Something went wrong.',
          onRetry: () => context.read<OrderProvider>().fetchOrders(),
        );
      case LoadStatus.loaded:
        if (orderProvider.orders.isEmpty) {
          return _EmptyOrderState(onRefresh: () => context.read<OrderProvider>().fetchOrders());
        }
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => context.read<OrderProvider>().fetchOrders(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orderProvider.orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _OrderCard(order: orderProvider.orders[index]),
          ),
        );
    }
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final pending = order.isPending;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuickBillingScreen(title: order.table?.tableName ?? 'Order #${order.id}', tableId: order.table?.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.receipt_long_outlined, color: AppTheme.accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.table?.tableName ?? 'Order #${order.id}',
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${order.itemCount} item${order.itemCount == 1 ? '' : 's'} · Order #${order.id}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (pending ? AppTheme.pending : AppTheme.completed).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pending ? 'Pending' : 'Completed',
                style: TextStyle(color: pending ? AppTheme.pending : AppTheme.completed, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
            if (order.table?.id != null) ...[
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckoutScreen(tableId: order.table!.id, tableName: order.table!.tableName)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(border: Border.all(color: AppTheme.accent), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Bill', style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyOrderState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyOrderState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return OrderEmptyState(
      accentTitle: 'Order Yet',
      subtitle: 'Start taking orders and they will show up here.',
      onRefresh: () async => onRefresh(),
      extraContent: [
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedOrderScreen())),
          child: const Text('View Saved Order', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
              child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- KOT Tab ----------------

/// Pairs a [Kot] with the [Order] it belongs to, so the flattened KOT list
/// can still show which table/order each ticket came from.
class _KotEntry {
  final Kot kot;
  final Order order;
  const _KotEntry({required this.kot, required this.order});
}

class _KotTab extends StatefulWidget {
  const _KotTab();

  @override
  State<_KotTab> createState() => _KotTabState();
}

class _KotTabState extends State<_KotTab> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<OrderProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchOrders());
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    switch (orderProvider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(
          message: orderProvider.errorMessage ?? 'Something went wrong.',
          onRetry: () => context.read<OrderProvider>().fetchOrders(),
        );
      case LoadStatus.loaded:
        final kots = <_KotEntry>[
          for (final order in orderProvider.orders)
            for (final kot in order.kots) _KotEntry(kot: kot, order: order),
        ];
        if (kots.isEmpty) {
          return OrderEmptyState(
            accentTitle: 'KOT',
            titleSuffix: ' Yet',
            subtitle: 'No worries! With RestroX, orders are coming soon — this page will be full in no time.',
            onRefresh: () async => context.read<OrderProvider>().fetchOrders(),
            extraContent: const [
              OrderCreationHintRow(hint: OrderCreationHint(icon: Icons.crop_free, title: 'Scan by Customer', description: 'Place QR Stand in respective Table, let Customer scan & Order themselves.')),
              OrderCreationHintRow(hint: OrderCreationHint(icon: Icons.phone_outlined, title: 'Order from staff mobile app', description: 'Every Staff gets their mobile app, they can directly take orders from that.')),
              OrderCreationHintRow(hint: OrderCreationHint(icon: Icons.description_outlined, title: 'Manual KOT', description: 'Its ok to use paper KOT, you can make entry of that from any device in RestroX.')),
            ],
          );
        }
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => context.read<OrderProvider>().fetchOrders(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: kots.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _KotCard(entry: kots[index]),
          ),
        );
    }
  }
}

class _KotCard extends StatelessWidget {
  final _KotEntry entry;
  const _KotCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final kot = entry.kot;
    final completed = kot.orderStatus.toLowerCase() == 'completed';
    final statusColor = completed ? AppTheme.completed : AppTheme.pending;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuickBillingScreen(title: entry.order.table?.tableName ?? 'Order #${entry.order.id}', tableId: entry.order.table?.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.soup_kitchen_outlined, color: AppTheme.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KOT #${kot.kotNumber}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
                      const SizedBox(height: 3),
                      Text(
                        entry.order.table?.tableName ?? 'Order #${entry.order.id}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    kot.orderStatus.isEmpty ? '—' : kot.orderStatus[0].toUpperCase() + kot.orderStatus.substring(1),
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
            if (kot.items.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppTheme.divider),
              const SizedBox(height: 10),
              for (final item in kot.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.displayName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none))),
                      Text('x${item.quantity}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------- Table Tab (also reused by "Dine In Order") ----------------

class TableListTab extends StatefulWidget {
  const TableListTab({super.key});

  @override
  State<TableListTab> createState() => _TableListTabState();
}

class _TableListTabState extends State<TableListTab> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<TableProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchTables());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = context.watch<TableProvider>();

    switch (tableProvider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(
          message: tableProvider.errorMessage ?? 'Something went wrong.',
          onRetry: () => context.read<TableProvider>().fetchTables(),
        );
      case LoadStatus.loaded:
        return _TableGrid(tables: tableProvider.tables, onRefresh: () => context.read<TableProvider>().fetchTables());
    }
  }
}

class _TableGrid extends StatefulWidget {
  final List<RestaurantTable> tables;
  final VoidCallback onRefresh;
  const _TableGrid({required this.tables, required this.onRefresh});

  @override
  State<_TableGrid> createState() => _TableGridState();
}

class _TableGridState extends State<_TableGrid> {
  String _selectedCategory = 'All';

  Future<void> _openTableActions(RestaurantTable table) async {
    final action = await EditDeleteActionsSheet.show(context, title: table.tableName);
    if (!mounted || action == null) return;

    if (action == 'edit') {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddTableScreen(editingTable: table)));
      if (result != null) widget.onRefresh();
      return;
    }

    if (action == 'delete') {
      final confirmed = await confirmDelete(context, entityName: 'table');
      if (!mounted || !confirmed) return;

      final provider = context.read<TableProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final success = await provider.deleteTable(table.id);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(success ? 'Table deleted' : (provider.deleteErrorMessage ?? 'Failed to delete table'))));
    }
  }

  List<RestaurantTable> get _filteredTables {
    if (_selectedCategory == 'All') return widget.tables;
    return widget.tables.where((t) => t.categoryName == _selectedCategory).toList();
  }

  Map<String, List<RestaurantTable>> get _groupedTables {
    final Map<String, List<RestaurantTable>> map = {};
    for (final table in _filteredTables) {
      map.putIfAbsent(table.categoryName, () => []).add(table);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final uncategorizedCount = widget.tables.where((t) => t.categoryName == 'Uncategorized').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterToggleChip(
                        label: 'All',
                        isSelected: _selectedCategory == 'All',
                        onTap: () => setState(() => _selectedCategory = 'All'),
                      ),
                      if (uncategorizedCount > 0) ...[
                        const SizedBox(width: 10),
                        FilterToggleChip(
                          label: 'Uncategorized',
                          count: uncategorizedCount,
                          isSelected: _selectedCategory == 'Uncategorized',
                          onTap: () => setState(() => _selectedCategory = 'Uncategorized'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _AddTableButton(
                onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTableScreen()));
                  if (result != null) widget.onRefresh();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () async => widget.onRefresh(),
            child: _filteredTables.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No tables found',
                          style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                        ),
                      ),
                    ],
                  )
                : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _groupedTables.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 90,
                      ),
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        final table = entry.value[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuickBillingScreen(title: table.tableName, tableId: table.id),
                              ),
                            );
                          },
                          onLongPress: () => _openTableActions(table),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  table.tableName,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  table.tableStatus,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTableButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTableButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 4),
            Text(
              'Add Table',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterToggleChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterToggleChip({
    super.key,
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.card : AppTheme.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
