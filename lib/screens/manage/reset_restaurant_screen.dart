import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/restaurant_identity_header.dart';
import '../../widgets/common/subscription_usage_grid.dart';

const _kResetOptions = ['menu', 'table', 'finance', 'space', 'customer', 'suppliers', 'inventory', 'website', 'staff', 'order', 'activity'];

/// "Reset Restaurant" confirmation screen reached from Reset & Delete,
/// matching the reference's usage snapshot + whole-vs-partial reset choice.
class ResetRestaurantScreen extends StatefulWidget {
  const ResetRestaurantScreen({super.key});

  @override
  State<ResetRestaurantScreen> createState() => _ResetRestaurantScreenState();
}

class _ResetRestaurantScreenState extends State<ResetRestaurantScreen> {
  bool _resetWhole = false;
  final Set<String> _selected = {};

  Future<void> _resetIt() async {
    if (!_resetWhole && _selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select what to reset, or turn on "Reset whole restaurant?"')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset this data?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: const Text('This cannot be undone.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restaurant data reset')));
      Navigator.pop(context);
    }
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
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text('Reset Restaurant', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            const RestaurantIdentityHeader(),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
              child: const SubscriptionUsageGrid(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reset whole restaurant?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                        SizedBox(height: 2),
                        Text('It will reset every data of restaurant.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _resetWhole,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppTheme.cancelled,
                    onChanged: (v) => setState(() { _resetWhole = v; if (v) _selected.clear(); }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
                children: [
                  TextSpan(text: 'Or, Select what you want to reset '),
                  TextSpan(text: '*', style: TextStyle(color: AppTheme.cancelled)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: _resetWhole ? 0.4 : 1,
              child: IgnorePointer(
                ignoring: _resetWhole,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _kResetOptions.map((option) {
                    final selected = _selected.contains(option);
                    return InkWell(
                      onTap: () => setState(() => selected ? _selected.remove(option) : _selected.add(option)),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider, width: selected ? 1.4 : 1),
                        ),
                        child: Text(option, style: TextStyle(color: selected ? AppTheme.primary : AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _resetIt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cancelled,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Reset it', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
