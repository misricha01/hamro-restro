import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../models/delivery_day_schedule.dart';
import '../../models/delivery_partner.dart';
import '../manage/dine_in_service_screen.dart' show SelectMenuSetSheet;
import 'delivery_riders_screen.dart';
import 'delivery_time_screen.dart';

/// "Delivery Service" settings screen, reached from the Manage screen's
/// Service section ("Delivery" row). Mirrors the Dine In Service screen's
/// conventions (AppTheme colors, card styling, toggle rows) while adding the
/// Details / Manage / Delivery Partners tabs from the reference design.
class DeliveryServiceScreen extends StatefulWidget {
  const DeliveryServiceScreen({super.key});

  @override
  State<DeliveryServiceScreen> createState() => _DeliveryServiceScreenState();
}

class _DeliveryServiceScreenState extends State<DeliveryServiceScreen> {
  int _tabIndex = 0;

  // --- Details tab state -----------------------------------------------
  static const String _menuUrl = 'https://restrox226.restro.link/en/delivery-menu';
  String _businessName = 'Hamro Restro';
  String _businessPhone = '+977 9804824711';
  String _businessAddress = 'M8MM+CM7, Shankhamul Marg, Kathmandu 44600, Nepal';
  double _fixedDeliveryCharge = 0;
  double _freeDeliveryAbove = 0;
  double _minimumCartValue = 0;

  // --- Manage tab state --------------------------------------------------
  bool _statusOn = true;
  String _selectedMenuSet = 'Default Menuset';
  bool _viewInvoiceOn = true;
  bool _viewKotOn = true;
  bool _requiredConfirmationOn = true;
  bool _autoPrintDeliveryRequestOn = false;
  List<DeliveryDaySchedule> _schedule = DeliveryDaySchedule.defaultWeek();

  // --- Delivery Partners tab state ---------------------------------------
  final List<DeliveryPartner> _partners = DeliveryPartner.defaultPartners();

  Future<void> _pickMenuSet() async {
    final result = await SelectMenuSetSheet.show(context, current: _selectedMenuSet);
    if (result != null) setState(() => _selectedMenuSet = result);
  }

  Future<void> _openDeliveryTime() async {
    final result = await Navigator.push<List<DeliveryDaySchedule>>(
      context,
      MaterialPageRoute(builder: (context) => DeliveryTimeScreen(schedule: _schedule)),
    );
    if (result != null) setState(() => _schedule = result);
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
          'Delivery Service',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _DeliveryServiceTabs(
              index: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
            const Divider(height: 1, color: AppTheme.divider),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _buildDetailsTab(),
                  _buildManageTab(),
                  _buildPartnersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Details tab
  // ------------------------------------------------------------------
  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ShareMenuCard(url: _menuUrl),
        const SizedBox(height: 16),
        _InfoCard(
          name: _businessName,
          phone: _businessPhone,
          address: _businessAddress,
          onEdit: _editInformation,
        ),
        const SizedBox(height: 16),
        _ChargesCard(
          fixedCharge: _fixedDeliveryCharge,
          freeAbove: _freeDeliveryAbove,
          minimumCart: _minimumCartValue,
          onEdit: _editCharges,
        ),
      ],
    );
  }

  Future<void> _editInformation() async {
    final result = await _EditInformationSheet.show(
      context,
      name: _businessName,
      phone: _businessPhone,
      address: _businessAddress,
    );
    if (result != null) {
      setState(() {
        _businessName = result.$1;
        _businessPhone = result.$2;
        _businessAddress = result.$3;
      });
    }
  }

  Future<void> _editCharges() async {
    final result = await _EditChargesSheet.show(
      context,
      fixedCharge: _fixedDeliveryCharge,
      freeAbove: _freeDeliveryAbove,
      minimumCart: _minimumCartValue,
    );
    if (result != null) {
      setState(() {
        _fixedDeliveryCharge = result.$1;
        _freeDeliveryAbove = result.$2;
        _minimumCartValue = result.$3;
      });
    }
  }

  // ------------------------------------------------------------------
  // Manage tab
  // ------------------------------------------------------------------
  Widget _buildManageTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ToggleCard(
          title: 'Status',
          description: 'This means you are serving Delivery Service in your restaurant or not.',
          value: _statusOn,
          onChanged: (v) => setState(() => _statusOn = v),
        ),
        const SizedBox(height: 20),
        const _SectionLabel(label: 'Active Menu Set'),
        const SizedBox(height: 8),
        _MenuSetSelectCard(value: _selectedMenuSet, onTap: _pickMenuSet),
        const SizedBox(height: 24),

        const _SectionLabel(label: 'Actions'),
        const SizedBox(height: 8),
        _ToggleCard(
          title: 'View Invoice',
          description: 'Customer can view invoice, they will see final amount of their orders too.',
          value: _viewInvoiceOn,
          onChanged: (v) => setState(() => _viewInvoiceOn = v),
        ),
        const SizedBox(height: 12),
        _ToggleCard(
          title: 'View KOT',
          description: 'Customer can view KOT, they cant see amount of orders. Only see number of items.',
          value: _viewKotOn,
          onChanged: (v) => setState(() => _viewKotOn = v),
        ),
        const SizedBox(height: 12),
        _ToggleCard(
          title: 'Required Order Confirmation',
          description: 'If you enable this, you will have to confirm order before it goes to kitchen.',
          value: _requiredConfirmationOn,
          onChanged: (v) => setState(() => _requiredConfirmationOn = v),
        ),
        const SizedBox(height: 12),
        _ToggleCard(
          title: 'Auto Print Delivery Request',
          description: 'If you enable this, delivery request will be printed automatically',
          value: _autoPrintDeliveryRequestOn,
          onChanged: (v) => setState(() => _autoPrintDeliveryRequestOn = v),
        ),
        const SizedBox(height: 12),
        _NavRowCard(
          icon: Icons.access_time,
          title: 'Delivery Time',
          subtitle: 'Set delivery time to match your restaurant hours.',
          onTap: _openDeliveryTime,
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Delivery Partners tab
  // ------------------------------------------------------------------
  Widget _buildPartnersTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _partners.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final partner = _partners[index];
              return _PartnerCard(
                partner: partner,
                onToggle: (v) => setState(() => partner.enabled = v),
                onMenuTap: () => _openPartnerMenu(partner),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Total Delivery Platform : ${_partners.length}',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, decoration: TextDecoration.none),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _addPlatform,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Add New Platform',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openPartnerMenu(DeliveryPartner partner) async {
    final action = await _PartnerActionsSheet.show(context, partner: partner);
    if (!mounted || action == null) return;
    switch (action) {
      case _PartnerAction.manageRiders:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryRidersScreen()));
        break;
      case _PartnerAction.editCommission:
        final result = await _EditCommissionSheet.show(context, commission: partner.commissionPercent);
        if (result != null) setState(() => partner.commissionPercent = result);
        break;
      case _PartnerAction.remove:
        setState(() => _partners.remove(partner));
        break;
    }
  }

  Future<void> _addPlatform() async {
    final result = await _AddPlatformSheet.show(context);
    if (result != null) {
      setState(() => _partners.add(DeliveryPartner(
        name: result.$1,
        description: 'Custom delivery platform added by you.',
        icon: Icons.storefront_outlined,
        iconBackground: AppTheme.accent,
        commissionPercent: result.$2,
      )));
    }
  }
}

// ==========================================================================
// Shared small widgets
// ==========================================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({required this.title, required this.description, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
              ),
              Switch(value: value, activeThumbColor: Colors.white, activeTrackColor: AppTheme.completed, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}

class _MenuSetSelectCard extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  const _MenuSetSelectCard({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            Expanded(
              child: Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _NavRowCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavRowCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Underline-style "Details / Manage / Delivery Partners" tab switcher,
/// matching the header tabs from the reference design and the selected-tab
/// styling already established by the Invite Staff screen's Email/Phone
/// switcher (bold + colored underline for the active tab).
class _DeliveryServiceTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _DeliveryServiceTabs({required this.index, required this.onChanged});

  static const _labels = ['Details', 'Manage', 'Delivery Partners'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          for (int i = 0; i < _labels.length; i++) ...[
            _tab(i),
            if (i != _labels.length - 1) const SizedBox(width: 24),
          ],
        ],
      ),
    );
  }

  Widget _tab(int i) {
    final selected = index == i;
    return GestureDetector(
      onTap: () => onChanged(i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _labels[i],
            style: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 2.5, width: _labels[i].length * 7.5, color: selected ? AppTheme.primary : Colors.transparent),
        ],
      ),
    );
  }
}

// ==========================================================================
// Details tab widgets
// ==========================================================================

class _ShareMenuCard extends StatelessWidget {
  final String url;
  const _ShareMenuCard({required this.url});

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery menu link copied')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Share Delivery Menu', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
              child: const Icon(Icons.qr_code_2_rounded, color: AppTheme.textPrimary, size: 160),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('Delivery Menu', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          ),
          const SizedBox(height: 16),
          _DashedBorderBox(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.cancelled, fontSize: 12.5, decoration: TextDecoration.none),
                  ),
                ),
                InkWell(onTap: () => _copy(context), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.copy_outlined, color: AppTheme.cancelled, size: 18))),
                InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sharing coming soon'))),
                  child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.share_outlined, color: AppTheme.cancelled, size: 18)),
                ),
                InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download coming soon'))),
                  child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.download_outlined, color: AppTheme.cancelled, size: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderBox extends StatelessWidget {
  final Widget child;
  const _DashedBorderBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: AppTheme.cancelled, radius: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}

class _InfoCard extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final VoidCallback onEdit;

  const _InfoCard({required this.name, required this.phone, required this.address, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Information Show In Menu', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
              ),
              InkWell(borderRadius: BorderRadius.circular(8), onTap: onEdit, child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.edit_outlined, color: AppTheme.accent, size: 20))),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Name', value: name),
          const SizedBox(height: 12),
          _InfoRow(label: 'Phone', value: phone),
          const SizedBox(height: 12),
          _InfoRow(label: 'Address', value: address),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 76, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none))),
        const Text(':  ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
        Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none))),
      ],
    );
  }
}

class _ChargesCard extends StatelessWidget {
  final double fixedCharge;
  final double freeAbove;
  final double minimumCart;
  final VoidCallback onEdit;

  const _ChargesCard({required this.fixedCharge, required this.freeAbove, required this.minimumCart, required this.onEdit});

  String _rs(double v) => 'Rs ${v == v.roundToDouble() ? v.toInt() : v}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Charges', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
              ),
              InkWell(borderRadius: BorderRadius.circular(8), onTap: onEdit, child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.edit_outlined, color: AppTheme.accent, size: 20))),
            ],
          ),
          const SizedBox(height: 12),
          _ChargeRow(title: 'Fixed Delivery Charges', description: 'Delivery charge of ${_rs(fixedCharge)} will be added in the bill', value: _rs(fixedCharge)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: AppTheme.divider)),
          _ChargeRow(title: 'Free Delivery Above', description: 'Home Delivery will be free for orders above ${_rs(freeAbove)}', value: _rs(freeAbove)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: AppTheme.divider)),
          _ChargeRow(title: 'Minimum Cart Value For Delivery', description: 'Minimum cart value for delivery should be ${_rs(minimumCart)}', value: _rs(minimumCart)),
        ],
      ),
    );
  }
}

class _ChargeRow extends StatelessWidget {
  final String title;
  final String description;
  final String value;
  const _ChargeRow({required this.title, required this.description, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none)),
              const SizedBox(height: 3),
              Text(description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none)),
      ],
    );
  }
}

/// Bottom sheet used to edit the Name/Phone/Address shown on the public
/// delivery menu. Returns a (name, phone, address) record on save.
class _EditInformationSheet extends StatefulWidget {
  final String name;
  final String phone;
  final String address;
  const _EditInformationSheet({required this.name, required this.phone, required this.address});

  static Future<(String, String, String)?> show(BuildContext context, {required String name, required String phone, required String address}) {
    return showModalBottomSheet<(String, String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditInformationSheet(name: name, phone: phone, address: address),
    );
  }

  @override
  State<_EditInformationSheet> createState() => _EditInformationSheetState();
}

class _EditInformationSheetState extends State<_EditInformationSheet> {
  late final _nameController = TextEditingController(text: widget.name);
  late final _phoneController = TextEditingController(text: widget.phone);
  late final _addressController = TextEditingController(text: widget.address);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditSheetScaffold(
      title: 'Edit Menu Information',
      onSave: () => Navigator.pop(context, (_nameController.text.trim(), _phoneController.text.trim(), _addressController.text.trim())),
      children: [
        _SheetField(label: 'Name', controller: _nameController),
        const SizedBox(height: 16),
        _SheetField(label: 'Phone', controller: _phoneController, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _SheetField(label: 'Address', controller: _addressController, maxLines: 3),
      ],
    );
  }
}

/// Bottom sheet used to edit the three delivery charge amounts.
class _EditChargesSheet extends StatefulWidget {
  final double fixedCharge;
  final double freeAbove;
  final double minimumCart;
  const _EditChargesSheet({required this.fixedCharge, required this.freeAbove, required this.minimumCart});

  static Future<(double, double, double)?> show(BuildContext context, {required double fixedCharge, required double freeAbove, required double minimumCart}) {
    return showModalBottomSheet<(double, double, double)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditChargesSheet(fixedCharge: fixedCharge, freeAbove: freeAbove, minimumCart: minimumCart),
    );
  }

  @override
  State<_EditChargesSheet> createState() => _EditChargesSheetState();
}

class _EditChargesSheetState extends State<_EditChargesSheet> {
  late final _fixedController = TextEditingController(text: widget.fixedCharge.toStringAsFixed(0));
  late final _freeAboveController = TextEditingController(text: widget.freeAbove.toStringAsFixed(0));
  late final _minimumController = TextEditingController(text: widget.minimumCart.toStringAsFixed(0));

  @override
  void dispose() {
    _fixedController.dispose();
    _freeAboveController.dispose();
    _minimumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditSheetScaffold(
      title: 'Edit Charges',
      onSave: () => Navigator.pop(
        context,
        (
          double.tryParse(_fixedController.text.trim()) ?? widget.fixedCharge,
          double.tryParse(_freeAboveController.text.trim()) ?? widget.freeAbove,
          double.tryParse(_minimumController.text.trim()) ?? widget.minimumCart,
        ),
      ),
      children: [
        _SheetField(label: 'Fixed Delivery Charges', controller: _fixedController, keyboardType: TextInputType.number, prefix: 'Rs'),
        const SizedBox(height: 16),
        _SheetField(label: 'Free Delivery Above', controller: _freeAboveController, keyboardType: TextInputType.number, prefix: 'Rs'),
        const SizedBox(height: 16),
        _SheetField(label: 'Minimum Cart Value For Delivery', controller: _minimumController, keyboardType: TextInputType.number, prefix: 'Rs'),
      ],
    );
  }
}

/// Shared bottom-sheet chrome (title + close + Save button) used by the
/// Details tab's edit sheets.
class _EditSheetScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;

  const _EditSheetScaffold({required this.title, required this.children, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: AppTheme.accent, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...children,
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? prefix;
  final int maxLines;

  const _SheetField({required this.label, required this.controller, this.keyboardType, this.prefix, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          decoration: InputDecoration(
            prefixText: prefix == null ? null : '$prefix   ',
            prefixStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
            filled: true,
            fillColor: AppTheme.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// Delivery Partners tab widgets
// ==========================================================================

class _PartnerCard extends StatelessWidget {
  final DeliveryPartner partner;
  final ValueChanged<bool> onToggle;
  final VoidCallback onMenuTap;

  const _PartnerCard({required this.partner, required this.onToggle, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: partner.iconBackground, borderRadius: BorderRadius.circular(10)),
                child: Icon(partner.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(partner.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                    const SizedBox(height: 3),
                    Text(partner.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onMenuTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.more_horiz, color: AppTheme.textSecondary, size: 18),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: AppTheme.divider)),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
                  children: [
                    const TextSpan(text: 'Commission '),
                    TextSpan(text: '${partner.commissionPercent}%', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              if (!partner.isBuiltIn)
                Switch(value: partner.enabled, activeThumbColor: Colors.white, activeTrackColor: AppTheme.completed, onChanged: onToggle),
            ],
          ),
        ],
      ),
    );
  }
}

enum _PartnerAction { manageRiders, editCommission, remove }

class _PartnerActionsSheet extends StatelessWidget {
  final DeliveryPartner partner;
  const _PartnerActionsSheet({required this.partner});

  static Future<_PartnerAction?> show(BuildContext context, {required DeliveryPartner partner}) {
    return showModalBottomSheet<_PartnerAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PartnerActionsSheet(partner: partner),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDirectOrder = partner.name == 'Direct Order';
    return Container(
      decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              if (isDirectOrder)
                _actionTile(context, Icons.two_wheeler_outlined, 'Manage Delivery Riders', () => Navigator.pop(context, _PartnerAction.manageRiders)),
              _actionTile(context, Icons.percent, 'Edit Commission', () => Navigator.pop(context, _PartnerAction.editCommission)),
              if (!partner.isBuiltIn)
                _actionTile(context, Icons.delete_outline, 'Remove Platform', () => Navigator.pop(context, _PartnerAction.remove), danger: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? AppTheme.cancelled : AppTheme.textPrimary;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

class _EditCommissionSheet extends StatefulWidget {
  final int commission;
  const _EditCommissionSheet({required this.commission});

  static Future<int?> show(BuildContext context, {required int commission}) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditCommissionSheet(commission: commission),
    );
  }

  @override
  State<_EditCommissionSheet> createState() => _EditCommissionSheetState();
}

class _EditCommissionSheetState extends State<_EditCommissionSheet> {
  late final _controller = TextEditingController(text: '${widget.commission}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditSheetScaffold(
      title: 'Edit Commission',
      onSave: () => Navigator.pop(context, int.tryParse(_controller.text.trim()) ?? widget.commission),
      children: [
        _SheetField(label: 'Commission Percentage', controller: _controller, keyboardType: TextInputType.number),
      ],
    );
  }
}

class _AddPlatformSheet extends StatefulWidget {
  const _AddPlatformSheet();

  static Future<(String, int)?> show(BuildContext context) {
    return showModalBottomSheet<(String, int)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddPlatformSheet(),
    );
  }

  @override
  State<_AddPlatformSheet> createState() => _AddPlatformSheetState();
}

class _AddPlatformSheetState extends State<_AddPlatformSheet> {
  final _nameController = TextEditingController();
  final _commissionController = TextEditingController(text: '0');
  bool _nameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    Navigator.pop(context, (name, int.tryParse(_commissionController.text.trim()) ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return _EditSheetScaffold(
      title: 'Add New Platform',
      onSave: _submit,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform Name', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (v) {
                if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
              },
              style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
              decoration: InputDecoration(
                hintText: 'Enter platform name',
                hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                errorText: _nameError ? 'Platform name is required' : null,
                errorStyle: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none),
                filled: true,
                fillColor: AppTheme.card,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SheetField(label: 'Commission Percentage', controller: _commissionController, keyboardType: TextInputType.number),
      ],
    );
  }
}
