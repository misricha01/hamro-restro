import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_channel.dart';
import '../../widgets/common/notification_channel_card.dart';

/// "Notification" settings screen reached from Manage > Setting > General
/// Setting: every notifiable event grouped into channels/categories, each
/// rendered with the shared [NotificationChannelCard] so every entry — no
/// matter the category — expands into the same push/priority/sound/staff
/// form.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late final List<NotificationCategory> _categories = [
    NotificationCategory(
      label: 'Orders & Services',
      channels: [
        NotificationChannelData(
          id: 'new_orders',
          icon: Icons.receipt_long_outlined,
          title: 'New Orders',
          description: 'New orders and KOTs created plus order from POS and delivery orders placed through Connect.',
          priority: NotifyPriority.high,
          sound: NotifySound.ting,
        ),
        NotificationChannelData(
          id: 'order_edits',
          icon: Icons.edit_outlined,
          title: 'Order Edits',
          description: 'Items changed on an open order and updates to its delivery details.',
          priority: NotifyPriority.high,
          sound: NotifySound.ting,
        ),
        NotificationChannelData(
          id: 'cancellations',
          icon: Icons.remove_shopping_cart_outlined,
          title: 'Cancellations',
          description: 'Orders that get cancelled.',
          priority: NotifyPriority.normal,
          sound: NotifySound.ting,
        ),
        NotificationChannelData(
          id: 'status_changes',
          icon: Icons.sync_outlined,
          title: 'Status Changes',
          description: 'Kitchen tickets moving between one status to another.',
          priority: NotifyPriority.high,
          sound: NotifySound.ting,
        ),
        NotificationChannelData(
          id: 'order_movements',
          icon: Icons.swap_horiz,
          title: 'Order Movements',
          description: 'Order type changes and items or KOTs moved between tables.',
          priority: NotifyPriority.normal,
          sound: NotifySound.ting,
        ),
        NotificationChannelData(
          id: 'checkouts',
          icon: Icons.point_of_sale_outlined,
          title: 'Checkouts',
          description: 'Orders settled and paid at the counter.',
          priority: NotifyPriority.normal,
          sound: NotifySound.defaultSound,
        ),
        NotificationChannelData(
          id: 'customer_requests',
          icon: Icons.notifications_active_outlined,
          title: 'Customer Requests',
          description: 'Water, waiter and bill requests raised by customer through connect.',
          priority: NotifyPriority.high,
          sound: NotifySound.ting,
        ),
        NotificationChannelData(
          id: 'other_order_events',
          icon: Icons.description_outlined,
          title: 'Other Order Events',
          description: 'Advance payments, surcharges, reservations, and handled customer requests.',
          priority: NotifyPriority.normal,
          sound: NotifySound.defaultSound,
        ),
      ],
    ),
    NotificationCategory(
      label: 'Menu & Tables',
      channels: [
        NotificationChannelData(
          id: 'menu',
          icon: Icons.restaurant_menu,
          title: 'Menu',
          description: 'Dishes, add-ons, menu sets, categories, and delivery platforms.',
          priority: NotifyPriority.low,
          sound: NotifySound.defaultSound,
        ),
        NotificationChannelData(
          id: 'tables_spaces',
          icon: Icons.table_restaurant_outlined,
          title: 'Tables & Spaces',
          description: 'Tables and floor spaces created, updated, or removed.',
          priority: NotifyPriority.low,
          sound: NotifySound.defaultSound,
        ),
      ],
    ),
    NotificationCategory(
      label: 'Inventory',
      channels: [
        NotificationChannelData(
          id: 'inventory',
          icon: Icons.inventory_2_outlined,
          title: 'Inventory',
          description: 'Stock items, consumption, measuring units, and stock groups.',
          priority: NotifyPriority.low,
          sound: NotifySound.defaultSound,
        ),
        NotificationChannelData(
          id: 'low_stock',
          icon: Icons.shopping_cart_checkout_outlined,
          title: 'Low Stock',
          description: 'Items that fall below their reorder threshold.',
          priority: NotifyPriority.high,
          sound: NotifySound.defaultSound,
        ),
      ],
    ),
    NotificationCategory(
      label: 'Finance',
      channels: [
        NotificationChannelData(
          id: 'finance',
          icon: Icons.account_balance_wallet_outlined,
          title: 'Finance',
          description: 'Day-book closes, payments, purchases, tax rates, and account head changes.',
          priority: NotifyPriority.low,
          sound: NotifySound.defaultSound,
        ),
        NotificationChannelData(
          id: 'deleted_transactions',
          icon: Icons.delete_outline,
          title: 'Deleted Transactions',
          description: 'Transactions removed from the system.',
          priority: NotifyPriority.high,
          sound: NotifySound.defaultSound,
        ),
        NotificationChannelData(
          id: 'edited_transactions',
          icon: Icons.edit_note_outlined,
          title: 'Edited Transactions',
          description: 'Income, expense, and purchase entries edited after posting.',
          priority: NotifyPriority.high,
          sound: NotifySound.defaultSound,
        ),
      ],
    ),
    NotificationCategory(
      label: 'People',
      channels: [
        NotificationChannelData(
          id: 'customers',
          icon: Icons.groups_outlined,
          title: 'Customers',
          description: 'New and updated customers, birthdays, and balance adjustments.',
          priority: NotifyPriority.low,
          sound: NotifySound.defaultSound,
        ),
        NotificationChannelData(
          id: 'suppliers',
          icon: Icons.local_shipping_outlined,
          title: 'Suppliers',
          description: 'Suppliers created, updated, or removed.',
          priority: NotifyPriority.low,
          sound: NotifySound.defaultSound,
        ),
        NotificationChannelData(
          id: 'staff',
          icon: Icons.badge_outlined,
          title: 'Staff',
          description: 'Staff invited, updated, or removed from the restaurant.',
          priority: NotifyPriority.low,
          sound: NotifySound.defaultSound,
        ),
      ],
    ),
    NotificationCategory(
      label: 'System',
      channels: [
        NotificationChannelData(
          id: 'settings',
          icon: Icons.settings_outlined,
          title: 'Settings',
          description: 'Restaurant, roles, printers, invoice, and subscription changes.',
          priority: NotifyPriority.low,
          sound: NotifySound.defaultSound,
        ),
        NotificationChannelData(
          id: 'everything_else',
          icon: Icons.notifications_none_outlined,
          title: 'Everything else',
          description: 'Fallback for any event without its own rule, like completed exports.',
          priority: NotifyPriority.normal,
          sound: NotifySound.defaultSound,
        ),
      ],
    ),
  ];

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
          'Notification',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
          children: [
            const Text(
              'Customize exactly what happens when an event triggers — set the priority, pick a sound, choose who hears it, and decide if it triggers a push. Open a channel below to get started.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, height: 1.4, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < _categories.length; i++) ...[
              if (i > 0) const SizedBox(height: 24),
              _CategoryHeader(label: _categories[i].label, count: _categories[i].channels.length),
              const SizedBox(height: 12),
              for (int j = 0; j < _categories[i].channels.length; j++) ...[
                if (j > 0) const SizedBox(height: 12),
                NotificationChannelCard(data: _categories[i].channels[j]),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String label;
  final int count;
  const _CategoryHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          '${label.toUpperCase()}  $count',
          style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12.5, letterSpacing: 0.6, decoration: TextDecoration.none),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(height: 1, color: AppTheme.divider)),
      ],
    );
  }
}
