import 'package:flutter/material.dart';
import 'package:restrox/screens/sms/purchase_sms_screen.dart';
import '../../core/theme/app_theme.dart';

class SmsEventItem {
  final String title;
  final String description;
  bool isEnabled;

  SmsEventItem({required this.title, required this.description, this.isEnabled = false});
}

class SmsEventsScreen extends StatefulWidget {
  const SmsEventsScreen({super.key});

  @override
  State<SmsEventsScreen> createState() => _SmsEventsScreenState();
}

class _SmsEventsScreenState extends State<SmsEventsScreen> {
  final List<SmsEventItem> _events = [
    SmsEventItem(title: 'Customer Birthday', description: 'Send birthday wishes to your customers via SMS.'),
    SmsEventItem(title: 'Delivery Order Received', description: 'New delivery order received - For Customer'),
    SmsEventItem(title: 'Delivery Order Received', description: 'New delivery order received - For Restaurant'),
    SmsEventItem(title: 'Delivery Order Completed', description: 'Send SMS to customer when delivery order is completed.'),
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
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.primary),
            ),
          ),
        ),
        title: const Text(
          'Events',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PurchaseSmsCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PurchaseSmsLoadingScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          ..._events.map((event) => _EventToggleCard(
            event: event,
            onChanged: (value) => setState(() => event.isEnabled = value),
          )),
        ],
      ),
    );
  }
}

class _PurchaseSmsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PurchaseSmsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchase SMS',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep your customer communication active, instant and professional.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF3B3FE0), Color(0xFF7B2FA0), Color(0xFFE0333B)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onTap,
                  child: const Center(
                    child: Text(
                      'Purchase SMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventToggleCard extends StatelessWidget {
  final SmsEventItem event;
  final ValueChanged<bool> onChanged;

  const _EventToggleCard({required this.event, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: event.isEnabled,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.completed,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}