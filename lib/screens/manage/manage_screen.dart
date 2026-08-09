import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../notification/notification_screen.dart';
import '../create_users/invite_staff_screen.dart';
import '../create_dish/add_dish_screen.dart' show SelectAddOnsSheet;
import 'manage_dishes_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_tables_screen.dart';
import 'manage_space_screen.dart';
import 'dine_in_service_screen.dart';
import 'menu_overview_screen.dart';
import 'restaurant_setting_screen.dart';
import '../delivery/delivery_service_screen.dart';
import '../services/services_screen.dart';
import '../website/website_screen.dart';
import '../finance/daybook/daybook_screen.dart';
import '../finance/finance_features_screen.dart';
import '../finance/transactions/transactions_screen.dart';
import '../analytics/sales_analytics_screen.dart';
import '../create_users/supplier_list_screen.dart';
import '../inventory/add_consumption_screen.dart';
import '../inventory/add_stock_item_screen.dart';
import '../inventory/inventory_features_screen.dart';
import '../create_users/staff_list_screen.dart';
import '../create_users/customer_list_screen.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  void _todo(BuildContext context) {
    // TODO: Wire up once the corresponding screen/flow exists.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ManageHeader(
              onNotificationsTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
              onMoreTap: () => _todo(context),
            ),
            const SizedBox(height: 16),

            _BusinessCard(onManageOtherBusinessesTap: () => _todo(context)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _QuickLinkCard(
                    icon: Icons.person_add_alt_outlined,
                    label: 'Invite Staff',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InviteStaffScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickLinkCard(
                    icon: Icons.settings_outlined,
                    label: 'Setting',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RestaurantSettingScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: 'Menu',
              onTitleMoreTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuOverviewScreen())),
              items: [
                _ManageRowData(
                  icon: Icons.ramen_dining_outlined,
                  label: 'Dishes',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageDishesScreen())),
                ),
                _ManageRowData(
                  icon: Icons.dashboard_outlined,
                  label: 'Category',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen())),
                ),
                _ManageRowData(
                  icon: Icons.local_offer_outlined,
                  label: 'Add-Ons or Extras',
                  onTap: () => SelectAddOnsSheet.show(context),
                ),
              ],
              moreFeaturesLabel: '3 more features',
              onMoreTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuOverviewScreen())),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: 'Table & Space',
              items: [
                _ManageRowData(
                  icon: Icons.table_bar_outlined,
                  label: 'Table',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageTablesScreen())),
                ),
                _ManageRowData(
                  icon: Icons.layers_outlined,
                  label: 'Space',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageSpaceScreen())),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: 'Service',
              items: [
                _ManageRowData(
                  icon: Icons.table_restaurant_outlined,
                  label: 'Dine In',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DineInServiceScreen())),
                ),
                _ManageRowData(
                  icon: Icons.moped_outlined,
                  label: 'Delivery',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryServiceScreen())),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _SectionCard(
              items: [
                _ManageRowData(icon: Icons.public_outlined, label: 'Website', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WebsiteScreen()))),
              ],
              moreFeaturesLabel: 'Manage all services',
              moreActionLabel: 'Expand',
              onMoreTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen())),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: 'Finance',
              items: [
                _ManageRowData(icon: Icons.menu_book_outlined, label: 'Daybook', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaybookScreen()))),
                _ManageRowData(icon: Icons.show_chart, label: 'Transactions', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()))),
                _ManageRowData(icon: Icons.bar_chart_outlined, label: 'Sales & Purchase', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen()))),
              ],
              moreFeaturesLabel: '4 more features',
              onMoreTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceFeaturesScreen())),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: 'Inventory',
              items: [
                _ManageRowData(
                  icon: Icons.local_offer_outlined,
                  label: 'Stock Item',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddStockItemScreen())),
                ),
                _ManageRowData(
                  icon: Icons.people_outline,
                  label: 'Suppliers',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplierListScreen())),
                ),
                _ManageRowData(
                  icon: Icons.create_new_folder_outlined,
                  label: 'Consumption',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddConsumptionScreen())),
                ),
              ],
              moreFeaturesLabel: '3 more features',
              onMoreTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryFeaturesScreen())),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: 'Users',
              items: [
                _ManageRowData(icon: Icons.manage_accounts_outlined, label: 'Staff', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffListScreen()))),
                _ManageRowData(icon: Icons.support_agent_outlined, label: 'Customer', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerListScreen()))),
              ],
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Your Profile',
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
              ),
            ),
            _ProfileCard(onTap: () => _todo(context)),
            const SizedBox(height: 16),

            _SectionCard(
              showChevrons: false,
              items: [
                _ManageRowData(icon: Icons.help_outline, label: 'FAQs', onTap: () => _todo(context)),
                _ManageRowData(icon: Icons.thumb_up_outlined, label: 'Support & Feedback', onTap: () => _todo(context)),
                _ManageRowData(icon: Icons.podcasts_outlined, label: 'Release Notes', onTap: () => _todo(context)),
                _ManageRowData(icon: Icons.phone_iphone_outlined, label: 'About Hamro Restro', onTap: () => _todo(context)),
                _ManageRowData(icon: Icons.phone_android_outlined, label: 'Appearance', onTap: () => _todo(context)),
                _ManageRowData(icon: Icons.refresh, label: 'Check for Update', onTap: () => _todo(context)),
              ],
            ),
            const SizedBox(height: 16),

            _LogoutButton(
              isLoading: context.watch<AuthProvider>().isLoggingOut,
              onTap: () => context.read<AuthProvider>().logout(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageHeader extends StatelessWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onMoreTap;

  const _ManageHeader({required this.onNotificationsTap, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Manage',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onNotificationsTap,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.notifications_none_outlined, color: AppTheme.textPrimary, size: 26),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onMoreTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.divider),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
          ),
        ),
      ],
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final VoidCallback onManageOtherBusinessesTap;
  const _BusinessCard({required this.onManageOtherBusinessesTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'HR',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hamro Restro',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                          child: const Text(
                            'Premium (Trial)',
                            style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8)),
                          child: const Text(
                            'Your Role: SuperAdmin',
                            style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onManageOtherBusinessesTap,
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage Other Businesses',
                    style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLinkCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textPrimary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageRowData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _ManageRowData({required this.icon, required this.label, required this.onTap});
}

/// A titled card grouping related manage rows, matching the "Menu",
/// "Table & Space", "Finance", etc. sections seen throughout the screen.
/// When [title] is null it renders as an untitled card (used for the lone
/// "Website" row).
class _SectionCard extends StatelessWidget {
  final String? title;
  final List<_ManageRowData> items;
  final String? moreFeaturesLabel;
  final String moreActionLabel;
  final VoidCallback? onMoreTap;
  final VoidCallback? onTitleMoreTap;
  final bool showChevrons;

  const _SectionCard({
    this.title,
    required this.items,
    this.moreFeaturesLabel,
    this.moreActionLabel = 'View All',
    this.onMoreTap,
    this.onTitleMoreTap,
    this.showChevrons = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Container(width: 4, height: 18, decoration: BoxDecoration(color: AppTheme.cancelled, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title!,
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none),
                  ),
                ),
                if (onTitleMoreTap != null)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onTitleMoreTap,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.more_horiz, color: AppTheme.textSecondary, size: 20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          for (final item in items) ...[
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: item.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(item.icon, color: AppTheme.textPrimary, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
                      ),
                    ),
                    if (showChevrons) const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
          ],
          if (moreFeaturesLabel != null) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Divider(height: 1, color: AppTheme.divider)),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onMoreTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        moreFeaturesLabel!,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                      ),
                    ),
                    Text(
                      moreActionLabel,
                      style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'KM',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kritika Mishra',
                    style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '@kritikamishra',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  const _LogoutButton({required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cancelled.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cancelled.withValues(alpha: 0.4)),
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: AppTheme.cancelled))],
              )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppTheme.cancelled, size: 18),
            SizedBox(width: 8),
            Text('Log out', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, fontSize: 15, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}
