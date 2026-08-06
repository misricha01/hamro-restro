import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/quick_billing/quick_billing_screen.dart';
import '../../screens/delivery/select_delivery_platform_screen.dart';
import '../../screens/reservation/add_reservation_screen.dart';

class AddNewOrderSheet extends StatelessWidget {
  const AddNewOrderSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddNewOrderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      _OrderOption(icon: Icons.table_bar_outlined, label: 'Dine In Order'),
      _OrderOption(icon: Icons.delivery_dining_outlined, label: 'Delivery Order'),
      _OrderOption(icon: Icons.shopping_bag_outlined, label: 'Take Away'),
      _OrderOption(icon: Icons.shopping_cart_outlined, label: 'Pick Up'),
      _OrderOption(icon: Icons.bolt_outlined, label: 'Quick Billing'),
      _OrderOption(icon: Icons.event_seat_outlined, label: 'Reservation'),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Add New Order',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: 130,
                      ),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        return _OrderOptionCard(
                          option: options[index],
                          onTap: () => _handleTap(context, options[index].label),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppTheme.card,
                      shape: BoxShape.circle,
                    ),
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

  void _handleTap(BuildContext context, String label) {
    Navigator.pop(context);
    switch (label) {
      case 'Dine In Order':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const _DineInScreen()),
        );
        break;
      case 'Delivery Order':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SelectDeliveryPlatformScreen()),
        );
        break;
      case 'Take Away':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QuickBillingScreen(title: 'Take Away'),
          ),
        );
        break;
      case 'Pick Up':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QuickBillingScreen(
              title: 'Pick Up',
              showBottomActionBar: true,
            ),
          ),
        );
        break;
      case 'Quick Billing':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuickBillingScreen()),
        );
        break;
      case 'Reservation':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddReservationScreen()),
        );
        break;
    }
  }
}

class _OrderOption {
  final IconData icon;
  final String label;

  _OrderOption({required this.icon, required this.label});
}

class _OrderOptionCard extends StatelessWidget {
  final _OrderOption option;
  final VoidCallback onTap;

  const _OrderOptionCard({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(option.icon, color: AppTheme.accent, size: 22),
                ),
                Icon(Icons.star_border, color: AppTheme.textSecondary, size: 18),
              ],
            ),
            const Spacer(),
            Text(
              option.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Dine In Order — wraps the same table/cabin list as the Table tab ----------------

class _DineInScreen extends StatelessWidget {
  const _DineInScreen();

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
              child: const Icon(Icons.close, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Dine In Order',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: const TableListTab(),
    );
  }
}