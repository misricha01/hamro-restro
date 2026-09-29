import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/toggle_card.dart';
import 'dine_in_service_screen.dart' show SelectMenuSetSheet;

/// "Other Services" settings screen, reached from the Manage all services
/// list. Groups the Digital Menu Layout (Grid/List dish view) setting with
/// the Take Away / Pick Up / Reservation service toggles, each with its own
/// Active Menu Set picker, matching the reference design's "Setting" screen.
class OtherServicesScreen extends StatefulWidget {
  const OtherServicesScreen({super.key});

  @override
  State<OtherServicesScreen> createState() => _OtherServicesScreenState();
}

class _OtherServicesScreenState extends State<OtherServicesScreen> {
  bool _gridView = true;

  bool _takeAwayOn = true;
  String _takeAwayMenuSet = 'Default Menuset';

  bool _pickUpOn = true;
  String _pickUpMenuSet = 'Default Menuset';

  bool _reservationOn = true;
  String _reservationMenuSet = 'Default Menuset';
  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 59);

  Future<void> _pickMenuSet(String current, ValueChanged<String> onPicked) async {
    final result = await SelectMenuSetSheet.show(context, current: current);
    if (result != null) onPicked(result);
  }

  Future<void> _pickTime(TimeOfDay initial, ValueChanged<TimeOfDay> onPicked) async {
    final result = await showTimePicker(context: context, initialTime: initial);
    if (result != null) onPicked(result);
  }

  String _formatTime(TimeOfDay t) {
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${t.hourOfPeriod.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $period';
  }

  void _reset() {
    setState(() {
      _gridView = true;
      _takeAwayOn = true;
      _takeAwayMenuSet = 'Default Menuset';
      _pickUpOn = true;
      _pickUpMenuSet = 'Default Menuset';
      _reservationOn = true;
      _reservationMenuSet = 'Default Menuset';
      _startTime = const TimeOfDay(hour: 0, minute: 0);
      _endTime = const TimeOfDay(hour: 23, minute: 59);
    });
  }

  void _save() {
    // These service settings have no backend endpoint yet, so nothing is
    // persisted — the toggles/menu-sets/hours are local UI state only. Report
    // that honestly instead of a fake "Changes saved". Wire this to
    // PATCH /api/restaurant/settings once the settings schema is available.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving these settings is not available yet.')),
    );
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
          'Setting',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _SectionLabel(label: 'Digital Menu Layout'),
          const SizedBox(height: 8),
          _DishViewCard(isGrid: _gridView, onChanged: (v) => setState(() => _gridView = v)),
          const SizedBox(height: 24),

          const _SectionLabel(label: 'Take Away'),
          const SizedBox(height: 8),
          ToggleCard(
            title: 'Status',
            description: 'This means you are serving take away service in your restaurant or not.',
            value: _takeAwayOn,
            onChanged: (v) => setState(() => _takeAwayOn = v),
          ),
          const SizedBox(height: 12),
          const _SubLabel(label: 'Active Menu Set'),
          const SizedBox(height: 8),
          _MenuSetSelectCard(
            value: _takeAwayMenuSet,
            onTap: () => _pickMenuSet(_takeAwayMenuSet, (v) => setState(() => _takeAwayMenuSet = v)),
          ),
          const SizedBox(height: 24),

          const _SectionLabel(label: 'Pick Up'),
          const SizedBox(height: 8),
          ToggleCard(
            title: 'Status',
            description: 'This means you are serving pick up service in your restaurant or not.',
            value: _pickUpOn,
            onChanged: (v) => setState(() => _pickUpOn = v),
          ),
          const SizedBox(height: 12),
          const _SubLabel(label: 'Active Menu Set'),
          const SizedBox(height: 8),
          _MenuSetSelectCard(
            value: _pickUpMenuSet,
            onTap: () => _pickMenuSet(_pickUpMenuSet, (v) => setState(() => _pickUpMenuSet = v)),
          ),
          const SizedBox(height: 24),

          const _SectionLabel(label: 'Reservation'),
          const SizedBox(height: 8),
          ToggleCard(
            title: 'Reservation Availability',
            description: 'Accept Reservation requests during the specified hours',
            value: _reservationOn,
            onChanged: (v) => setState(() => _reservationOn = v),
          ),
          const SizedBox(height: 12),
          const _SubLabel(label: 'Active Menu Set'),
          const SizedBox(height: 8),
          _MenuSetSelectCard(
            value: _reservationMenuSet,
            onTap: () => _pickMenuSet(_reservationMenuSet, (v) => setState(() => _reservationMenuSet = v)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reservation Hours', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(label: 'Start Time', required: true),
                          const SizedBox(height: 8),
                          _TimeField(time: _formatTime(_startTime), onTap: () => _pickTime(_startTime, (t) => setState(() => _startTime = t))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(label: 'End Time', required: true),
                          const SizedBox(height: 8),
                          _TimeField(time: _formatTime(_endTime), onTap: () => _pickTime(_endTime, (t) => setState(() => _endTime = t))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _reset,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Reset', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
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
      child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
    );
  }
}

class _SubLabel extends StatelessWidget {
  final String label;
  const _SubLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
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

class _DishViewCard extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onChanged;
  const _DishViewCard({required this.isGrid, required this.onChanged});

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
                child: Text('Dish View', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
              ),
              _ViewToggleButton(icon: Icons.grid_view_rounded, label: 'Grid', selected: isGrid, onTap: () => onChanged(true)),
              const SizedBox(width: 8),
              _ViewToggleButton(icon: Icons.view_list_rounded, label: 'List', selected: !isGrid, onTap: () => onChanged(false)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Set default dish view, grid or list.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ViewToggleButton({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : AppTheme.textPrimary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
        children: [
          TextSpan(text: label),
          if (required) const TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String time;
  final VoidCallback onTap;
  const _TimeField({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                time,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
