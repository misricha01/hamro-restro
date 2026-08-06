import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/delivery_rider.dart';
import '../../widgets/common/setting_rows_card.dart';
import 'add_rider_screen.dart';

/// "Delivery Riders" screen, reached from Delivery Service > Delivery
/// Partners > Direct Order's "..." menu. Shows the empty state from the
/// reference design until a rider has been added.
class DeliveryRidersScreen extends StatefulWidget {
  const DeliveryRidersScreen({super.key});

  @override
  State<DeliveryRidersScreen> createState() => _DeliveryRidersScreenState();
}

class _DeliveryRidersScreenState extends State<DeliveryRidersScreen> {
  final List<DeliveryRider> _riders = [];

  Future<void> _addRider() async {
    final result = await Navigator.push<DeliveryRider>(
      context,
      MaterialPageRoute(builder: (context) => const AddRiderScreen()),
    );
    if (result != null) setState(() => _riders.add(result));
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
          'Delivery Riders',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: _riders.isEmpty
            ? _EmptyState(onAdd: _addRider)
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _riders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final rider = _riders[index];
                        final details = [
                          if (rider.vehicleType != null) rider.vehicleType!.label,
                          if (rider.vehicleNumber != null && rider.vehicleNumber!.isNotEmpty) rider.vehicleNumber!,
                          if (rider.phoneNumber != null && rider.phoneNumber!.isNotEmpty) rider.phoneNumber!,
                        ].join(' • ');
                        return SettingRowsCard(items: [
                          SettingRowData(
                            icon: Icons.two_wheeler_outlined,
                            title: rider.name,
                            subtitle: details.isEmpty ? 'No details added' : details,
                            onTap: () {},
                          ),
                        ]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Total Riders : ${_riders.length}',
                      style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, decoration: TextDecoration.none),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _addRider,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Add New Rider',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: AppTheme.cancelled.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(Icons.two_wheeler_outlined, color: AppTheme.cancelled, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Riders Yet',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first delivery rider by tapping the button below.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Add New Rider',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
