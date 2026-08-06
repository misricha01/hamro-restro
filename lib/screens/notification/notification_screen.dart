import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/notification/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

String _formatTime(DateTime d) {
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final amPm = d.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $amPm';
}

String _dateGroupLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(d.year, d.month, d.day);
  final diff = today.difference(that).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return _formatDate(d);
}

Color _kotStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return AppTheme.completed;
    case 'pending':
      return AppTheme.pending;
    default:
      return AppTheme.textSecondary;
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final provider = context.read<NotificationProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchNotifications());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.accent,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.accent,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                decoration: TextDecoration.none,
              ),
              unselectedLabelStyle: const TextStyle(
                decoration: TextDecoration.none,
              ),
              tabs: const [
                Tab(text: 'Order'),
                Tab(text: 'Activity Log'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OrderNotificationTab(),
          _ActivityLogTab(),
        ],
      ),
    );
  }
}

// ---------------- Order Tab ----------------

class _OrderNotificationTab extends StatelessWidget {
  const _OrderNotificationTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(message: provider.errorMessage, onRetry: () => context.read<NotificationProvider>().fetchNotifications());
      case LoadStatus.loaded:
        final orders = provider.orderNotifications;
        if (orders.isEmpty) return const _EmptyOrdersState();
        return RefreshIndicator(
          onRefresh: () => context.read<NotificationProvider>().fetchNotifications(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: orders.length,
            itemBuilder: (context, index) => _OrderNotificationTile(notification: orders[index]),
          ),
        );
    }
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.notifications_none_outlined,
            size: 120,
            color: AppTheme.accent.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                decoration: TextDecoration.none,
              ),
              children: [
                TextSpan(text: 'No '),
                TextSpan(
                  text: 'Order Updates',
                  style: TextStyle(color: AppTheme.accent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'You will see order updates here once you start taking orders.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderNotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _OrderNotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final kot = notification.kot;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.receipt_long, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15, decoration: TextDecoration.none),
                      ),
                    ),
                    if (kot != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kotStatusColor(kot.status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'KOT ${kot.kotNumber} · ${kot.status}',
                          style: TextStyle(color: _kotStatusColor(kot.status), fontSize: 11, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.subject,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.notificationMessage,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatDate(notification.createdAt)} · ${_formatTime(notification.createdAt)}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              message ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 16),
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

// ---------------- Activity Log Tab ----------------

class _ActivityLogTab extends StatelessWidget {
  const _ActivityLogTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(message: provider.errorMessage, onRetry: () => context.read<NotificationProvider>().fetchNotifications());
      case LoadStatus.loaded:
        final activities = provider.activityNotifications;

        final Map<String, List<AppNotification>> grouped = {};
        for (final item in activities) {
          grouped.putIfAbsent(_dateGroupLabel(item.createdAt), () => []).add(item);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Show filter options once real filter criteria exist.
                },
                icon: const Icon(Icons.tune, size: 18, color: AppTheme.textPrimary),
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filter',
                      style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: AppTheme.textPrimary, size: 20),
                  ],
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.divider),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            Expanded(
              child: activities.isEmpty
                  ? const Center(
                      child: Text(
                        'No activities yet',
                        style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => context.read<NotificationProvider>().fetchNotifications(),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: grouped.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
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
                              ...entry.value.map((item) => _ActivityTile(item: item)),
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
}

class _ActivityTile extends StatelessWidget {
  final AppNotification item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.notificationMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(item.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    decoration: TextDecoration.none,
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
