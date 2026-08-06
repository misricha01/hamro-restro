import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QuickBillingActionsSheet extends StatefulWidget {
  final bool categoryPanelVisible;
  final ValueChanged<bool> onCategoryPanelToggle;
  final VoidCallback onAddCustomItem;
  final VoidCallback onCartTap;

  const QuickBillingActionsSheet({
    super.key,
    required this.categoryPanelVisible,
    required this.onCategoryPanelToggle,
    required this.onAddCustomItem,
    required this.onCartTap,
  });

  static Future<void> show(
      BuildContext context, {
        required bool categoryPanelVisible,
        required ValueChanged<bool> onCategoryPanelToggle,
        required VoidCallback onAddCustomItem,
        required VoidCallback onCartTap,
      }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return QuickBillingActionsSheet(
            categoryPanelVisible: categoryPanelVisible,
            onCategoryPanelToggle: onCategoryPanelToggle,
            onAddCustomItem: onAddCustomItem,
            onCartTap: onCartTap,
          );
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
  State<QuickBillingActionsSheet> createState() => _QuickBillingActionsSheetState();
}

class _QuickBillingActionsSheetState extends State<QuickBillingActionsSheet> {
  late bool _categoryPanelVisible;

  @override
  void initState() {
    super.initState();
    _categoryPanelVisible = widget.categoryPanelVisible;
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
          'Actions',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.add,
                    label: 'Add Custom Item',
                    onTap: () {
                      Navigator.pop(context);
                      widget.onAddCustomItem();
                    },
                  ),
                  const Divider(height: 1, color: AppTheme.divider, indent: 68),
                  _ActionTile(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Cart',
                    onTap: () {
                      Navigator.pop(context);
                      widget.onCartTap();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dashboard_outlined, color: AppTheme.textPrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Category Panel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Switch(
                    value: _categoryPanelVisible,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppTheme.completed,
                    onChanged: (value) {
                      setState(() => _categoryPanelVisible = value);
                      widget.onCategoryPanelToggle(value);
                    },
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.textPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
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