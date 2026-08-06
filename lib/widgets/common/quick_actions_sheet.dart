import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/quick_billing/quick_billing_screen.dart';
import '../../screens/delivery/select_delivery_platform_screen.dart';
import 'add_new_order_sheet.dart';
import '../../screens/create_dish/add_dish_screen.dart';
import '../../screens/finance/add_expense_screen.dart';
import '../../screens/finance/add_income_screen.dart';
import '../../screens/finance/add_purchase_screen.dart';
import '../../screens/inventory/add_stock_group_screen.dart';
import '../../screens/create_users/add_customer_screen.dart';
import '../../screens/create_users/add_supplier_screen.dart';
import '../../screens/create_users/invite_staff_screen.dart';


class QuickActionsSheet extends StatelessWidget {
  const QuickActionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const QuickActionsSheet();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

          final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
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
              child: const Icon(Icons.close, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                  decoration: InputDecoration(
                    hintText: 'Search here',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary,
                      decoration: TextDecoration.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: [
                    _SectionTitle('Menu'),
                    _IconRow(items: [
                      _QuickItem(Icons.ramen_dining_outlined, 'Create Dishes', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddDishScreen()),
                        );
                      }),
                      _QuickItem(Icons.dashboard_outlined, 'Create Category', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
                        );
                      }),
                      _QuickItem(Icons.menu_book_outlined, 'Create Sub Menu', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddSubMenuScreen()),
                        );
                      }),
                    ]),
                    const SizedBox(height: 24),

                    _SectionTitle('Finance'),
                    _IconRow(items: [
                      _QuickItem(Icons.description_outlined, 'Add Income', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddIncomeScreen()),
                        );
                      }),
                      _QuickItem(Icons.crop_free_outlined, 'Add Expense', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
                        );
                      }),
                      _QuickItem(Icons.view_column_outlined, 'Add Purchase', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddPurchaseScreen()),
                        );
                      }),
                    ]),
                    const SizedBox(height: 24),

                    _SectionTitle('Inventory'),
                    _IconRow(items: [
                      _QuickItem(Icons.north_east_outlined, 'Add Stock Group', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddStockGroupScreen()),
                        );
                      }),
                      _QuickItem(Icons.inventory_2_outlined, 'Create New Stock', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddStockItemScreen()),
                        );
                      }),
                    ]),
                    const SizedBox(height: 24),

                    _SectionTitle('Create Users'),
                    _IconRow(items: [
                      _QuickItem(Icons.person_outline, 'Customer', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
                        );
                      }),
                      _QuickItem(Icons.support_agent_outlined, 'Supplier', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
                        );
                      }),
                      _QuickItem(Icons.manage_accounts_outlined, 'Staff', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InviteStaffScreen()),
                        );
                      }),
                    ]),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Bottom action buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AddNewOrderSheet.show(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add New Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _OutlinedActionButton(
                      icon: Icons.add,
                      label: 'Quick Billing',
                      color: const Color(0xFF4CAF50),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const QuickBillingScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OutlinedActionButton(
                      icon: Icons.add,
                      label: 'Delivery Order',
                      color: AppTheme.accent,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectDeliveryPlatformScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  _QuickItem(this.icon, this.label, {this.onTap});
}

class _IconRow extends StatelessWidget {
  final List<_QuickItem> items;
  const _IconRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onTap ?? () {},
              child: Column(
                children: [
                  Icon(item.icon, color: AppTheme.textPrimary, size: 26),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OutlinedActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.card,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}