import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/reservation/add_reservation_screen.dart';
import '../../screens/orders/checkout_history_screen.dart';
import '../../screens/orders/kot_history_screen.dart';
import '../../screens/orders/recent_transactions_screen.dart';
import '../../screens/orders/saved_order_screen.dart';
import '../../screens/orders/table_order_sessions_screen.dart';
import '../../screens/orders/printers_setting_screen.dart';
import '../../screens/orders/kot_type_setting_screen.dart';
import '../../screens/orders/invoice_setting_screen.dart';
import '../../screens/orders/cancelled_history_screen.dart';

class OrderActionsSheet extends StatelessWidget {
  const OrderActionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrderActionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
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
              ),
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 16),

              _ActionGroup(items: [
                _ActionData(Icons.format_list_bulleted, 'KOT History', screenBuilder: (context) => const KotHistoryScreen()),
                _ActionData(Icons.description_outlined, 'Recent Transactions', screenBuilder: (context) => const RecentTransactionsScreen()),
                _ActionData(Icons.receipt_long_outlined, 'Checkout History', screenBuilder: (context) => const CheckoutHistoryScreen()),
                _ActionData(Icons.table_bar_outlined, 'Table Sessions', screenBuilder: (context) => const TableOrderSessionsScreen()),
                _ActionData(Icons.save_outlined, 'Last Saved Orders - Offline', screenBuilder: (context) => const SavedOrderScreen()),
              ]),
              const SizedBox(height: 16),

              _ActionGroup(items: [
                _ActionData(Icons.print_outlined, 'Printers Setting', screenBuilder: (context) => const PrintersSettingScreen()),
                _ActionData(Icons.layers_outlined, 'KOT Type Setting', screenBuilder: (context) => const KotTypeSettingScreen()),
                _ActionData(Icons.description_outlined, 'Invoice Setting', screenBuilder: (context) => const InvoiceSettingScreen()),
              ]),
              const SizedBox(height: 16),

              _ActionGroup(items: [
                _ActionData(Icons.cancel_outlined, 'Cancelled History', iconColor: Colors.red, screenBuilder: (context) => const CancelledHistoryScreen()),
              ]),
              const SizedBox(height: 16),

              _ActionGroup(items: [
                _ActionData(Icons.event_available_outlined, 'Reservation', screenBuilder: (context) => const AddReservationScreen()),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final WidgetBuilder screenBuilder;
  _ActionData(this.icon, this.label, {this.iconColor, required this.screenBuilder});
}

class _ActionGroup extends StatelessWidget {
  final List<_ActionData> items;
  const _ActionGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: items.map((item) {
          return InkWell(
            onTap: () {
              final navigator = Navigator.of(context, rootNavigator: true);
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 250), () {
                navigator.push(MaterialPageRoute(builder: item.screenBuilder));
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, size: 20, color: item.iconColor ?? AppTheme.textPrimary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}