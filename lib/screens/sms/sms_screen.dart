import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/setting_rows_card.dart';
import 'sms_events_screen.dart';
import 'purchase_history_screen.dart';
import 'sms_log_screen.dart';
import 'purchase_sms_screen.dart';

/// "SMS" service module screen, reached from the Services screen. Shows
/// balance/usage stats at a glance and links into SMS Log, Events and
/// Purchase History.
class SmsScreen extends StatelessWidget {
  const SmsScreen({super.key});

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
          'SMS',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                Expanded(child: _SmsStatCard(icon: Icons.currency_rupee, color: AppTheme.completed, value: 'Rs 10', label: 'Available Balance')),
                const SizedBox(width: 12),
                Expanded(child: _SmsStatCard(icon: Icons.chat_bubble_outline, color: AppTheme.accent, value: '0', label: "Today's SMS")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _SmsStatCard(icon: Icons.forum_outlined, color: AppTheme.primary, value: '0', label: "Yesterday's SMS")),
                const SizedBox(width: 12),
                Expanded(child: _SmsStatCard(icon: Icons.receipt_long_outlined, color: AppTheme.cancelled, value: 'Rs 0', label: 'Total Transaction')),
              ],
            ),
            const SizedBox(height: 20),

            SettingRowsCard(
              items: [
                SettingRowData(
                  icon: Icons.description_outlined,
                  title: 'SMS Log',
                  subtitle: 'View all SMS activity',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SmsLogScreen())),
                ),
                SettingRowData(
                  icon: Icons.star_border,
                  title: 'Events',
                  subtitle: 'Set up automated SMS for events and occasions',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SmsEventsScreen())),
                ),
                SettingRowData(
                  icon: Icons.attach_money,
                  title: 'Purchase History',
                  subtitle: 'Check your SMS package purchase records',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PurchaseHistoryScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PurchaseSmsLoadingScreen())),
            child: const Text('Purchase SMS'),
          ),
        ),
      ),
    );
  }
}

class _SmsStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _SmsStatCard({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),


          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}