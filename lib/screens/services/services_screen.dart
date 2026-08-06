import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/setting_rows_card.dart';
import '../analytics/finance_screen.dart';
import '../website/website_screen.dart';
import '../sms/sms_screen.dart';
import '../manage/other_services_screen.dart';

/// "Services" screen, reached from the Manage screen's "Manage all services"
/// row below the Service section. Lists every service module (Dine In,
/// Delivery, Website, SMS, and more to come) in one place.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _dineInOn = true;
  bool _deliveryOn = true;

  void _todo(BuildContext context) {
    // TODO: Wire up once the corresponding screen/flow exists.
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
        title: const Text(
          'Services',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _todo(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SettingRowsCard(
              items: [
                SettingRowData(
                  icon: Icons.ramen_dining_outlined,
                  title: 'Dine In Service',
                  subtitle: 'Active Menu:  : Default Menuset',
                  toggleValue: _dineInOn,
                  onToggleChanged: (v) => setState(() => _dineInOn = v),
                  onTap: () => setState(() => _dineInOn = !_dineInOn),
                ),
                SettingRowData(
                  icon: Icons.moped_outlined,
                  title: 'Delivery Services',
                  subtitle: 'Active Menu:  : Default Menuset',
                  toggleValue: _deliveryOn,
                  onToggleChanged: (v) => setState(() => _deliveryOn = v),
                  onTap: () => setState(() => _deliveryOn = !_deliveryOn),
                ),
                SettingRowData(
                  icon: Icons.public_outlined,
                  title: 'Website',
                  subtitle: 'Turn visitors into customers with your website.',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WebsiteScreen())),
                ),
                SettingRowData(
                  icon: Icons.chat_bubble_outline,
                  title: 'SMS',
                  subtitle: 'Reach customers through text messages',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SmsScreen())),
                ),
                SettingRowData(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Finance',
                  subtitle: 'Track sales, payments and transaction history.',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceScreen())),
                ),
                SettingRowData(
                  icon: Icons.miscellaneous_services_outlined,
                  title: 'Other Services',
                  subtitle: 'Manage takeaway, pickup, and reservation services.',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OtherServicesScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
