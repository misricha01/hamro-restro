import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'manage_menu_set_screen.dart' show MenuSetItem;

/// "Dine In Service" settings screen, reached from the Manage screen's
/// Service section. Groups the Status/Menu-Set toggles and the "Other"
/// toggles shown in the reference design, each backed by a working switch.
class DineInServiceScreen extends StatefulWidget {
  const DineInServiceScreen({super.key});

  @override
  State<DineInServiceScreen> createState() => _DineInServiceScreenState();
}

class _DineInServiceScreenState extends State<DineInServiceScreen> {
  bool _statusOn = true;
  bool _viewInvoiceOn = true;
  bool _viewKotOn = true;
  bool _checkInOn = false;
  bool _requiredConfirmationOn = true;
  String _selectedMenuSet = 'Default Menuset';

  Future<void> _pickMenuSet() async {
    final result = await SelectMenuSetSheet.show(context, current: _selectedMenuSet);
    if (result != null) setState(() => _selectedMenuSet = result);
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
          'Dine In Service',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
          children: [
            const _SectionLabel(label: 'Status and Menu Set'),
            const SizedBox(height: 8),
            _ToggleCard(
              title: 'Status',
              description: 'Customer can view invoice, they will see final amount of their orders too. Active Menu Set',
              value: _statusOn,
              onChanged: (v) => setState(() => _statusOn = v),
            ),
            const SizedBox(height: 12),
            _MenuSetSelectCard(value: _selectedMenuSet, onTap: _pickMenuSet),
            const SizedBox(height: 24),

            const _SectionLabel(label: 'Other'),
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
              title: 'Check-In',
              description: 'While creating order you can add check-in option for dine-in customers details.',
              value: _checkInOn,
              onChanged: (v) => setState(() => _checkInOn = v),
            ),
            const SizedBox(height: 12),
            _ToggleCard(
              title: 'Required Order Confirmation',
              description: 'If you enable this, you will have to confirm order before it goes to kitchen.',
              value: _requiredConfirmationOn,
              onChanged: (v) => setState(() => _requiredConfirmationOn = v),
            ),
          ],
        ),
      ),
    );
  }
}

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
              Switch(
                value: value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppTheme.completed,
                onChanged: onChanged,
              ),
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

/// "Select MenuSet" bottom sheet opened from the "Default Menuset" row,
/// matching the reference design's search + Sub Menu count + checkmark list.
class SelectMenuSetSheet extends StatefulWidget {
  final String? current;
  const SelectMenuSetSheet({super.key, this.current});

  static Future<String?> show(BuildContext context, {String? current}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectMenuSetSheet(current: current),
    );
  }

  @override
  State<SelectMenuSetSheet> createState() => _SelectMenuSetSheetState();
}

class _SelectMenuSetSheetState extends State<SelectMenuSetSheet> {
  final _searchController = TextEditingController();

  final List<MenuSetItem> _items = [
    MenuSetItem(
      name: 'Default Menuset',
      initials: 'DM',
      services: const ['Dine In Service', 'Delivery Services', 'Pickup Services', 'Reservation Services', 'Takeaway Services'],
      subMenuCount: 3,
    ),
  ];

  List<MenuSetItem> get _filtered {
    if (_searchController.text.isEmpty) return _items;
    final q = _searchController.text.toLowerCase();
    return _items.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select MenuSet',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          final selected = item.name == widget.current;
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, item.name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Sub Menu: ${item.subMenuCount}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
                                  ),
                                  if (selected) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.check, color: AppTheme.cancelled, size: 18),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Total Category : ${_items.length}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                  ),
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
