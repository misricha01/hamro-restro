import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/orders/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/setting_empty_state.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

bool _kotCancelled(Kot k) => k.orderStatus.toLowerCase() == 'cancelled';
bool _itemCancelled(OrderItem i) => i.dishStatus.toLowerCase() == 'cancelled';

/// "Cancelled History" reached from Orders' 3-dot Actions menu, with
/// Orders / KOT / Dishes tabs matching the reference. Backed by
/// [OrderProvider] (`GET /api/order`) — the same data already powering the
/// Orders screen — filtered down to cancelled KOTs/items, since there's no
/// separate cancelled-history endpoint.
class CancelledHistoryScreen extends StatefulWidget {
  const CancelledHistoryScreen({super.key});

  @override
  State<CancelledHistoryScreen> createState() => _CancelledHistoryScreenState();
}

class _CancelledHistoryScreenState extends State<CancelledHistoryScreen> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    final provider = context.read<OrderProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchOrders());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

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
        title: const Text('Cancelled History', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.cancelled,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.cancelled,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.none),
          unselectedLabelStyle: const TextStyle(decoration: TextDecoration.none),
          tabs: const [Tab(text: 'Orders'), Tab(text: 'KOT'), Tab(text: 'Dishes')],
        ),
      ),
      body: SafeArea(
        child: _buildBody(
          orderProvider,
          child: TabBarView(
            controller: _tabController,
            children: [
              _OrdersSubTab(orders: orderProvider.orders),
              _KotSubTab(orders: orderProvider.orders),
              _DishesSubTab(orders: orderProvider.orders),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(OrderProvider provider, {required Widget child}) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (provider.status == LoadStatus.error) {
      return _ErrorState(message: provider.errorMessage ?? 'Something went wrong.', onRetry: () => context.read<OrderProvider>().fetchOrders());
    }
    return child;
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: AppTheme.textSecondary),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
            const SizedBox(height: 12),
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

// ---------------- Orders sub-tab ----------------

class _OrdersSubTab extends StatelessWidget {
  final List<Order> orders;
  const _OrdersSubTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    final cancelled = orders.where((o) => o.kots.any(_kotCancelled)).toList();
    if (cancelled.isEmpty) {
      return const SettingEmptyState(title: 'Cancelled History', subtitle: 'No Cancelled History found. Cancelled orders will show up here.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cancelled.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = cancelled[index];
        final cancelledCount = order.kots.where(_kotCancelled).length;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long_outlined, color: AppTheme.cancelled, size: 22),
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
                      '$cancelledCount cancelled KOT${cancelledCount == 1 ? '' : 's'} · ${_formatDate(order.createdAt)}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------- KOT sub-tab ----------------

class _KotEntry {
  final Kot kot;
  final Order order;
  const _KotEntry({required this.kot, required this.order});
}

class _KotSubTab extends StatelessWidget {
  final List<Order> orders;
  const _KotSubTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    final cancelled = <_KotEntry>[
      for (final order in orders)
        for (final kot in order.kots)
          if (_kotCancelled(kot)) _KotEntry(kot: kot, order: order),
    ];
    if (cancelled.isEmpty) {
      return const SettingEmptyState(title: 'Cancelled History', subtitle: 'No Cancelled History found. Cancelled KOTs will show up here.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cancelled.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = cancelled[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.soup_kitchen_outlined, color: AppTheme.cancelled, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KOT #${entry.kot.kotNumber}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
                    const SizedBox(height: 3),
                    Text(
                      [entry.order.table?.tableName ?? 'Order #${entry.order.id}', _formatDate(entry.order.createdAt)].join(' · '),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------- Dishes sub-tab ----------------

class _DishEntry {
  final OrderItem item;
  final Order order;
  const _DishEntry({required this.item, required this.order});
}

class _DishesSubTab extends StatelessWidget {
  final List<Order> orders;
  const _DishesSubTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    final cancelled = <_DishEntry>[
      for (final order in orders)
        for (final kot in order.kots)
          for (final item in kot.items)
            if (_itemCancelled(item)) _DishEntry(item: item, order: order),
    ];
    if (cancelled.isEmpty) {
      return const SettingEmptyState(title: 'Cancelled History', subtitle: 'No Cancelled History found. Cancelled dishes will show up here.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cancelled.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = cancelled[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.item.displayName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
                    const SizedBox(height: 3),
                    Text(
                      [entry.order.table?.tableName ?? 'Order #${entry.order.id}', _formatDate(entry.order.createdAt)].join(' · '),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
              Text('x${entry.item.quantity}', style: const TextStyle(color: AppTheme.cancelled, fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
            ],
          ),
        );
      },
    );
  }
}
