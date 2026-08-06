import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/auth/logged_in_user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/add_new_order_sheet.dart';
import '../create_dish/add_dish_screen.dart' show AddDishScreen;
import '../create_users/add_customer_screen.dart';
import '../create_users/invite_staff_screen.dart';
import '../manage/add_table_screen.dart';
import '../manage/create_space_screen.dart';
import '../manage/manage_screen.dart';
import '../manage/restaurant_setting_screen.dart';
import 'faq_list_screen.dart';

/// "KM" from "Kritika Mishra", "H" from "Hamro" — first letter of the first
/// two words, or just the first letter if there's only one.
String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '';
  if (words.length == 1) return words[0][0].toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}

/// App landing tab. Mirrors the "Home" reference: restaurant summary,
/// onboarding checklist, daily tip, quick shortcuts, promo/tutorial banners,
/// FAQs and support contact options. Reuses existing screens for navigation
/// wherever a matching flow already exists.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _HomeHeader(user: user),
            const SizedBox(height: 16),
            const _HomeSearchBar(),
            const SizedBox(height: 24),

            _SectionHeader(
              title: 'Your Restaurant',
              actionLabel: 'View All',
              onAction: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageScreen())),
            ),
            const SizedBox(height: 12),
            _RestaurantCard(user: user, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageScreen()))),
            const SizedBox(height: 24),

            _SetupGuideCard(
              steps: [
                _SetupStep(
                  label: 'Create Restaurant',
                  completed: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RestaurantSettingScreen())),
                ),
                _SetupStep(
                  label: 'Add your first table',
                  completed: false,
                  onTap: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTableScreen()));
                    if (result != null && context.mounted) _snack(context, 'Table created successfully');
                  },
                ),
                _SetupStep(
                  label: 'Add your first dish',
                  completed: false,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDishScreen())),
                ),
                _SetupStep(
                  label: 'Invite your team members',
                  completed: false,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InviteStaffScreen())),
                ),
                _SetupStep(
                  label: 'Add Order',
                  completed: false,
                  onTap: () => AddNewOrderSheet.show(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _SectionTitle('Shortcuts'),
            const SizedBox(height: 12),
            _ShortcutsGrid(
              items: [
                _ShortcutItem(icon: Icons.receipt_long_outlined, label: 'Add Order', onTap: () => AddNewOrderSheet.show(context)),
                _ShortcutItem(icon: Icons.ramen_dining_outlined, label: 'Add Dish', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDishScreen()))),
                _ShortcutItem(icon: Icons.person_add_alt_outlined, label: 'Invite Staff', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InviteStaffScreen()))),
                _ShortcutItem(icon: Icons.table_bar_outlined, label: 'Add Table', onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTableScreen()));
                  if (result != null && context.mounted) _snack(context, 'Table created successfully');
                }),
                _ShortcutItem(icon: Icons.layers_outlined, label: 'Add Space', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateSpaceScreen()))),
                _ShortcutItem(icon: Icons.support_agent_outlined, label: 'Add Customer', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerScreen()))),
              ],
            ),
            const SizedBox(height: 24),

            _FaqCard(onViewAll: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqListScreen()))),
          ],
        ),
      ),
    );
  }
}

// ---------------- Header ----------------

class _HomeHeader extends StatelessWidget {
  final LoggedInUser? user;
  const _HomeHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Home',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
          ),
        ),
        _UserChip(user: user),
      ],
    );
  }
}

class _UserChip extends StatelessWidget {
  final LoggedInUser? user;
  const _UserChip({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.fullname.isNotEmpty == true ? user!.fullname : 'Account';
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(6)),
            child: Text(
              _initials(name),
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.none),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
      child: const TextField(
        style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
        decoration: InputDecoration(
          hintText: 'Search here',
          hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// ---------------- Section headers ----------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({required this.title, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionTitle(title)),
        OutlinedButton(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.divider),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
          ),
        ),
      ],
    );
  }
}

// ---------------- Your Restaurant card ----------------

class _RestaurantCard extends StatelessWidget {
  final LoggedInUser? user;
  final VoidCallback onTap;
  const _RestaurantCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final restaurantName = user?.restaurant?.restaurantName.isNotEmpty == true
        ? user!.restaurant!.restaurantName
        : 'Your Restaurant';
    final role = user?.role.isNotEmpty == true ? user!.role : '—';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
              child: Text(
                _initials(restaurantName),
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurantName,
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.completed.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                          'Active',
                          style: TextStyle(color: AppTheme.completed, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none),
                        ),
                      ),
                    ],
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
                        child: Text(
                          'Role: $role',
                          style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12, decoration: TextDecoration.none),
                        ),
                      ),
                    ],
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

// ---------------- Setup guide checklist ----------------

class _SetupStep {
  final String label;
  final bool completed;
  final VoidCallback onTap;
  _SetupStep({required this.label, required this.completed, required this.onTap});
}

class _SetupGuideCard extends StatelessWidget {
  final List<_SetupStep> steps;
  const _SetupGuideCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Setup your restaurant with us!',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 4),
          const Text(
            'Use this guide to get your restaurant up and running.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 8),
          for (final step in steps)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: step.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      step.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: step.completed ? AppTheme.completed : AppTheme.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        step.label,
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------- Shortcuts grid ----------------

class _ShortcutItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _ShortcutItem({required this.icon, required this.label, required this.onTap});
}

class _ShortcutsGrid extends StatelessWidget {
  final List<_ShortcutItem> items;
  const _ShortcutsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 56,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: item.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Icon(item.icon, color: AppTheme.textPrimary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// ---------------- FAQs ----------------

class _FaqData {
  final String question;
  final String answer;
  _FaqData(this.question, this.answer);
}

class _FaqCard extends StatelessWidget {
  final VoidCallback onViewAll;
  const _FaqCard({required this.onViewAll});

  static final List<_FaqData> _faqs = [
    _FaqData('What is Hamro Restro?', 'Hamro Restro is an all-in-one restaurant management software that helps you manage orders, menu, staff and more.'),
    _FaqData('How does Hamro Restro work?', 'Set up your restaurant, add your menu and tables, then start taking orders from a single dashboard.'),
    _FaqData('Is Hamro Restro secure?', 'Yes, Hamro Restro uses an RX PIN and password along with encrypted storage to keep your data safe.'),
    _FaqData("How to recover my password?/ How can I reset my pasword?", 'Go to Manage > Settings > Reset Password and follow the instructions sent to your registered email.'),
    _FaqData('How can my restaurant benefit from Hamro Restro?', 'Hamro Restro streamlines order taking, billing, inventory and staff management, saving time and reducing errors.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Expanded(child: _SectionTitle('FAQs')),
                  OutlinedButton(
                    onPressed: onViewAll,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.divider),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < _faqs.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppTheme.divider),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 14),
                iconColor: AppTheme.textSecondary,
                collapsedIconColor: AppTheme.textSecondary,
                title: Text(
                  _faqs[i].question,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _faqs[i].answer,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4, decoration: TextDecoration.none),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
