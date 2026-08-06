import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/manage_list_controls.dart';
import '../../widgets/common/setting_rows_card.dart';
import '../orders/invoice_setting_screen.dart';
import '../orders/kot_type_setting_screen.dart';
import '../orders/printers_setting_screen.dart';
import 'billing_subscription_screen.dart';
import 'department_screen.dart';
import 'notification_settings_screen.dart';
import 'reset_delete_screen.dart';
import 'restaurant_details_screen.dart';
import 'tax_rates_screen.dart';
import 'trash_screen.dart';
import 'transfer_ownership_screen.dart';
import 'user_role_screen.dart';

/// One labelled group of settings rows (e.g. "General Setting"). Kept
/// separate from [SettingRowData] so the search filter can drop a whole
/// section when none of its rows match the query, same as a real settings
/// search would.
class _SettingSection {
  final String label;
  final Color labelColor;
  final FontWeight labelWeight;
  final List<SettingRowData> items;

  _SettingSection({
    required this.label,
    required this.items,
    this.labelColor = AppTheme.textSecondary,
    this.labelWeight = FontWeight.w600,
  });
}

/// "Restaurant Setting" screen reached from the Manage screen's "Setting"
/// quick link. Groups General Setting / Order Setting / Dangerous Area rows,
/// matching the reference design, and reuses [SettingRowsCard] (shared with
/// the Menu overview screen) plus the Manage list screens' search field.
class RestaurantSettingScreen extends StatefulWidget {
  const RestaurantSettingScreen({super.key});

  @override
  State<RestaurantSettingScreen> createState() => _RestaurantSettingScreenState();
}

class _RestaurantSettingScreenState extends State<RestaurantSettingScreen> {
  final _searchController = TextEditingController();
  bool _searchVisible = false;

  void _todo(BuildContext context) {
    // TODO: Wire up once the corresponding screen/flow exists.
  }

  List<_SettingSection> get _sections => [
    _SettingSection(
      label: 'General Setting',
      items: [
        SettingRowData(
          icon: Icons.storefront_outlined,
          title: 'Restaurant Details',
          subtitle: 'Basic details setting of Restaurant',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RestaurantDetailsScreen())),
        ),
        SettingRowData(
          icon: Icons.notifications_none_outlined,
          title: 'Notification',
          subtitle: 'Manage Notification of Restaurant',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
        ),
        SettingRowData(
          icon: Icons.folder_outlined,
          title: 'Department',
          subtitle: 'Manage sub menu & assign printer',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DepartmentScreen())),
        ),
        SettingRowData(
          icon: Icons.credit_card_outlined,
          title: 'Billing & Subscription',
          subtitle: 'Manage Invoices and Plans',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BillingSubscriptionScreen())),
        ),
        SettingRowData(
          icon: Icons.person_add_alt_outlined,
          title: 'User Role',
          subtitle: 'Assign Roles with limitations',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserRoleScreen())),
        ),
      ],
    ),
    _SettingSection(
      label: 'Order Setting',
      items: [
        SettingRowData(
          icon: Icons.description_outlined,
          title: 'Invoice Setting',
          subtitle: 'Invoice, Payment Method, Tax, Tips, Discount',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoiceSettingScreen())),
        ),
        SettingRowData(
          icon: Icons.description_outlined,
          title: 'KOT Setting',
          subtitle: 'KOT/BOT/COT and print',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KotTypeSettingScreen())),
        ),
        SettingRowData(
          icon: Icons.description_outlined,
          title: 'Tax & Rates',
          subtitle: 'Manage Tax & VATs',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TaxRatesScreen())),
        ),
        SettingRowData(
          icon: Icons.print_outlined,
          title: 'Printer',
          subtitle: 'Manage your Printer',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrintersSettingScreen())),
        ),
      ],
    ),
    _SettingSection(
      label: 'Dangerous Area',
      labelColor: AppTheme.cancelled,
      labelWeight: FontWeight.bold,
      items: [
        SettingRowData(
          icon: Icons.delete_outline,
          title: 'Trash',
          subtitle: 'Manage deleted events from here',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrashScreen())),
        ),
        SettingRowData(
          icon: Icons.sync_alt,
          title: 'Transfer Ownership',
          subtitle: 'Transfer SuperAdmin access to other',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferOwnershipScreen())),
        ),
        SettingRowData(
          icon: Icons.warning_amber_outlined,
          title: 'Reset & Delete',
          subtitle: 'Danger Area, Delete and Reseting Account',
          danger: true,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetDeleteScreen())),
        ),
      ],
    ),
  ];

  List<_SettingSection> get _filteredSections {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _sections;
    final result = <_SettingSection>[];
    for (final section in _sections) {
      final items = section.items
          .where((item) => item.title.toLowerCase().contains(q) || item.subtitle.toLowerCase().contains(q))
          .toList();
      if (items.isNotEmpty) {
        result.add(_SettingSection(label: section.label, labelColor: section.labelColor, labelWeight: section.labelWeight, items: items));
      }
    }
    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sections = _filteredSections;
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
          'Restaurant Setting',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          ManageAppBarIconButton(icon: Icons.search, active: _searchVisible, onTap: _toggleSearch),
          ManageAppBarIconButton(icon: Icons.more_horiz, bordered: true, onTap: () => _todo(context)),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searchVisible)
              ManageSearchField(
                controller: _searchController,
                onClose: _toggleSearch,
                onChanged: (_) => setState(() {}),
              ),
            Expanded(
              child: sections.isEmpty
                  ? const Center(
                      child: Text(
                        'No settings found',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
                      itemCount: sections.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final section = sections[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                section.label,
                                style: TextStyle(color: section.labelColor, fontWeight: section.labelWeight, fontSize: 14, decoration: TextDecoration.none),
                              ),
                            ),
                            SettingRowsCard(items: section.items),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
