import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_channel.dart';
import 'finance_form_fields.dart' show ThreeWaySegment;
import 'select_staffs_sheet.dart';

/// Staff roster for the "Notify specific staff" picker — same seeded
/// account/shape already used by the Sales & Purchase filters
/// (`kTransactionStaffOptions` in transactions_filter_sheet.dart).
const List<StaffOption> kNotifyStaffOptions = [StaffOption(name: 'Kritika Mishra', username: 'kritikamishra')];

/// One expandable notification channel row (e.g. "New Orders"). Reused for
/// every entry across every category on the Notification settings screen so
/// the layout, spacing, switch placement and interaction pattern stay
/// identical everywhere. Collapsed, it shows the icon/title/description plus
/// a priority/sound/audience summary; expanded, it reveals the editable
/// push/priority/sound/staff form with Cancel / Save Changes.
class NotificationChannelCard extends StatefulWidget {
  final NotificationChannelData data;
  final ValueChanged<NotificationChannelData>? onSaved;

  const NotificationChannelCard({super.key, required this.data, this.onSaved});

  @override
  State<NotificationChannelCard> createState() => _NotificationChannelCardState();
}

class _NotificationChannelCardState extends State<NotificationChannelCard> {
  bool _expanded = false;
  late NotifyPriority _priority;
  late NotifySound _sound;
  late bool _pushEnabled;
  late bool _notifySpecificStaff;
  late List<String> _selectedStaff;

  @override
  void initState() {
    super.initState();
    _resetDraft();
  }

  void _resetDraft() {
    _priority = widget.data.priority;
    _sound = widget.data.sound;
    _pushEnabled = widget.data.pushEnabled;
    _notifySpecificStaff = widget.data.notifySpecificStaff;
    _selectedStaff = List.of(widget.data.selectedStaff);
  }

  bool get _isDirty {
    if (_priority != widget.data.priority) return true;
    if (_sound != widget.data.sound) return true;
    if (_pushEnabled != widget.data.pushEnabled) return true;
    if (_notifySpecificStaff != widget.data.notifySpecificStaff) return true;
    if (_selectedStaff.length != widget.data.selectedStaff.length) return true;
    for (final name in _selectedStaff) {
      if (!widget.data.selectedStaff.contains(name)) return true;
    }
    return false;
  }

  void _toggleExpand() {
    setState(() {
      if (!_expanded) _resetDraft();
      _expanded = !_expanded;
    });
  }

  void _cancel() {
    setState(() {
      _resetDraft();
      _expanded = false;
    });
  }

  void _save() {
    widget.data
      ..priority = _priority
      ..sound = _sound
      ..pushEnabled = _pushEnabled
      ..notifySpecificStaff = _notifySpecificStaff
      ..selectedStaff = List.of(_selectedStaff);
    widget.onSaved?.call(widget.data);
    setState(() => _expanded = false);
  }

  void _pickStaff() {
    SelectStaffsSheet.show(
      context,
      staffs: kNotifyStaffOptions,
      initialSelected: _selectedStaff,
      onApply: (selected) => setState(() => _selectedStaff = selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    // A BoxDecoration can't combine a borderRadius with a non-uniform
    // Border, so the expanded state's green left accent is drawn as a
    // separate rounded strip layered on top of a plain (uniform-border)
    // card instead of being one of the Border's four sides.
    return Stack(
      children: [
        _buildCard(data),
        if (_expanded)
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.completed,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(NotificationChannelData data) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _expanded ? AppTheme.primary : AppTheme.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(data.icon, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                        const SizedBox(height: 3),
                        Text(data.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 14,
                          runSpacing: 4,
                          children: [
                            _SummaryChip(icon: Icons.flag_outlined, label: data.priority.label),
                            _SummaryChip(icon: Icons.volume_up_outlined, label: data.sound.label),
                            _SummaryChip(icon: Icons.people_alt_outlined, label: data.audienceLabel),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Push notifications', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none)),
                            SizedBox(height: 3),
                            Text('Turn this channel on or off for everyone.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                      Switch(value: _pushEnabled, activeThumbColor: Colors.white, activeTrackColor: AppTheme.completed, onChanged: (v) => setState(() => _pushEnabled = v)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  const Text('Priority', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none)),
                  const SizedBox(height: 3),
                  const Text('Pops up on screen so you notice it', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                  const SizedBox(height: 10),
                  ThreeWaySegment(
                    labels: const ['Low', 'Normal', 'High'],
                    selectedIndex: NotifyPriority.values.indexOf(_priority),
                    onChanged: (i) => setState(() => _priority = NotifyPriority.values[i]),
                  ),
                  const SizedBox(height: 18),

                  const Text('Alert sound', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none)),
                  const SizedBox(height: 3),
                  const Text('Tap a sound to hear it.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _SoundChip(label: NotifySound.defaultSound.label, selected: _sound == NotifySound.defaultSound, onTap: () => setState(() => _sound = NotifySound.defaultSound)),
                      const SizedBox(width: 10),
                      _SoundChip(label: NotifySound.ting.label, selected: _sound == NotifySound.ting, onTap: () => setState(() => _sound = NotifySound.ting)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  InkWell(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Follows this device's system notification settings"))),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Managed by system', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none)),
                              SizedBox(height: 3),
                              Text('On Android the delivered sound & priority follow the channel — tap to open settings.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.open_in_new, color: AppTheme.textSecondary, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Notify specific staff', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none)),
                            SizedBox(height: 3),
                            Text('Only the people you pick will be notified.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                      Switch(value: _notifySpecificStaff, activeThumbColor: Colors.white, activeTrackColor: AppTheme.completed, onChanged: (v) => setState(() => _notifySpecificStaff = v)),
                    ],
                  ),
                  if (_notifySpecificStaff) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickStaff,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                        child: Row(
                          children: [
                            const Icon(Icons.person_add_alt, color: AppTheme.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedStaff.isEmpty ? 'Click here to select staff' : '${_selectedStaff.length} Staff Selected',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: _selectedStaff.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary, decoration: TextDecoration.none),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedStaff.isEmpty) ...[
                      const SizedBox(height: 6),
                      const Text("No one selected yet — this channel won't notify anyone until you add staff.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none)),
                    ],
                  ],
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _cancel,
                        child: const Text('Cancel', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isDirty ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDirty ? AppTheme.primary : AppTheme.card,
                          disabledBackgroundColor: AppTheme.card,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text('Save Changes', style: TextStyle(color: _isDirty ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
      ],
    );
  }
}

class _SoundChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SoundChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider, width: selected ? 1.4 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, size: 16, color: selected ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: selected ? AppTheme.primary : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}
