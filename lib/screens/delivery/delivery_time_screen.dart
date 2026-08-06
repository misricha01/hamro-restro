import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/delivery_day_schedule.dart';

/// "Delivery Time" screen, reached from Delivery Service > Manage > "Delivery
/// Time". Lets the restaurant set Sunday-Saturday serving windows using a
/// 12-hour hour/minute + AM/PM dropdown selector, matching the reference
/// design. Changes are only applied to the caller when "Save Changes" is
/// pressed; "Back" discards edits.
class DeliveryTimeScreen extends StatefulWidget {
  final List<DeliveryDaySchedule> schedule;
  const DeliveryTimeScreen({super.key, required this.schedule});

  @override
  State<DeliveryTimeScreen> createState() => _DeliveryTimeScreenState();
}

class _DeliveryTimeScreenState extends State<DeliveryTimeScreen> {
  late final List<DeliveryDaySchedule> _days = widget.schedule.map((d) => d.copy()).toList();

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
          'Delivery Time',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: _days.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _DayScheduleCard(
            schedule: _days[index],
            onChanged: () => setState(() {}),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
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
                onPressed: () => Navigator.pop(context, _days),
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

class _DayScheduleCard extends StatelessWidget {
  final DeliveryDaySchedule schedule;
  final VoidCallback onChanged;

  const _DayScheduleCard({required this.schedule, required this.onChanged});

  bool get _timeFieldsEnabled => !schedule.isClosed && !schedule.is24hrOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(schedule.day, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChoiceChip(
                  label: 'Closed',
                  color: AppTheme.cancelled,
                  selected: schedule.isClosed,
                  onTap: () {
                    schedule.isClosed = !schedule.isClosed;
                    if (schedule.isClosed) schedule.is24hrOpen = false;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChoiceChip(
                  label: '24hr Open',
                  color: AppTheme.completed,
                  selected: schedule.is24hrOpen,
                  onTap: () {
                    schedule.is24hrOpen = !schedule.is24hrOpen;
                    if (schedule.is24hrOpen) schedule.isClosed = false;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Opens At', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          _TimeRow(
            enabled: _timeFieldsEnabled,
            hour: schedule.openHour,
            minute: schedule.openMinute,
            meridiem: schedule.openMeridiem,
            onHourChanged: (v) {
              schedule.openHour = v;
              onChanged();
            },
            onMinuteChanged: (v) {
              schedule.openMinute = v;
              onChanged();
            },
            onMeridiemChanged: (v) {
              schedule.openMeridiem = v;
              onChanged();
            },
          ),
          const SizedBox(height: 16),
          const Text('Closes At', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          _TimeRow(
            enabled: _timeFieldsEnabled,
            hour: schedule.closeHour,
            minute: schedule.closeMinute,
            meridiem: schedule.closeMeridiem,
            onHourChanged: (v) {
              schedule.closeHour = v;
              onChanged();
            },
            onMinuteChanged: (v) {
              schedule.closeMinute = v;
              onChanged();
            },
            onMeridiemChanged: (v) {
              schedule.closeMeridiem = v;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

/// "Closed" / "24hr Open" style checkbox pill used to mark a day's status.
class _ChoiceChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color.withValues(alpha: 0.5) : AppTheme.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              color: selected ? color : AppTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(color: selected ? color : AppTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 14, decoration: TextDecoration.none),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hour / minute number boxes plus a 12-hour AM-PM dropdown, matching the
/// "Opens At" / "Closes At" rows in the reference design.
class _TimeRow extends StatelessWidget {
  final bool enabled;
  final int hour;
  final int minute;
  final String meridiem;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final ValueChanged<String> onMeridiemChanged;

  const _TimeRow({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.meridiem,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onMeridiemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NumberBox(
            value: hour,
            min: 1,
            max: 12,
            enabled: enabled,
            onChanged: onHourChanged,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(':', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none)),
        ),
        Expanded(
          child: _NumberBox(
            value: minute,
            min: 0,
            max: 59,
            enabled: enabled,
            onChanged: onMinuteChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MeridiemDropdown(value: meridiem, enabled: enabled, onChanged: onMeridiemChanged),
        ),
      ],
    );
  }
}

class _NumberBox extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _NumberBox({required this.value, required this.min, required this.max, required this.enabled, required this.onChanged});

  @override
  State<_NumberBox> createState() => _NumberBoxState();
}

class _NumberBoxState extends State<_NumberBox> {
  late final TextEditingController _controller = TextEditingController(text: '${widget.value}');

  @override
  void didUpdateWidget(covariant _NumberBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = '${widget.value}';
    if (_controller.text != text) _controller.text = text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit(String raw) {
    final parsed = int.tryParse(raw);
    if (parsed == null) {
      _controller.text = '${widget.value}';
      return;
    }
    final clamped = parsed.clamp(widget.min, widget.max);
    widget.onChanged(clamped);
    if (clamped != parsed) _controller.text = '$clamped';
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      onChanged: _commit,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: TextStyle(color: widget.enabled ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
      ),
    );
  }
}

/// AM/PM selector rendered as a real dropdown, per the requirement that the
/// 12-hour meridiem control be a dropdown rather than a toggle or sheet.
class _MeridiemDropdown extends StatelessWidget {
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _MeridiemDropdown({required this.value, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: false,
          dropdownColor: AppTheme.card,
          icon: Icon(Icons.keyboard_arrow_down, color: enabled ? AppTheme.textSecondary : AppTheme.divider),
          style: TextStyle(color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
          items: const [
            DropdownMenuItem(value: 'AM', child: Text('AM')),
            DropdownMenuItem(value: 'PM', child: Text('PM')),
          ],
          onChanged: enabled ? (v) => onChanged(v!) : null,
        ),
      ),
    );
  }
}
