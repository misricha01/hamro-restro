import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Collapsible section card used by KOT Setting / Invoice Setting screens
/// (Header Details, Footer Details, Line Items, etc.) so both share one
/// consistent expand/collapse card instead of duplicating the styling.
class SettingsSectionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const SettingsSectionTile({super.key, required this.title, required this.children, this.initiallyExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          iconColor: AppTheme.cancelled,
          collapsedIconColor: AppTheme.textSecondary,
          title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
          children: children,
        ),
      ),
    );
  }
}

/// A single checkable row inside a [SettingsSectionTile] (e.g. "KOT Number",
/// "Invoice No"), optionally editable and/or drag-reorderable.
///
/// When [onEdit] is set, the pencil icon opens [showFieldRenameDialog]
/// instead of just sitting there decoratively. When [dragHandle] is set
/// (supplied by a parent [ReorderableListView]), a drag handle renders on
/// the leading edge so the row can be reordered.
class SettingsCheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool editable;
  final bool highlighted;
  final ValueChanged<String>? onEdit;
  final Widget? dragHandle;

  const SettingsCheckRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.editable = false,
    this.highlighted = false,
    this.onEdit,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? AppTheme.completed : AppTheme.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: highlighted ? AppTheme.completed.withValues(alpha: 0.5) : AppTheme.divider),
          ),
          child: Row(
            children: [
              if (dragHandle != null) ...[dragHandle!, const SizedBox(width: 8)],
              Icon(value ? Icons.check_box : Icons.check_box_outline_blank, color: value ? color : AppTheme.textSecondary, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none))),
              if (editable)
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onEdit == null
                      ? null
                      : () async {
                          final renamed = await showFieldRenameDialog(context, currentLabel: label);
                          if (renamed != null) onEdit!(renamed);
                        },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rename dialog opened by [SettingsCheckRow]'s pencil icon — lets the user
/// customize a field's display label (e.g. rename "S.N" to "No.").
Future<String?> showFieldRenameDialog(BuildContext context, {required String currentLabel}) {
  final controller = TextEditingController(text: currentLabel);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Rename Field', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
        decoration: InputDecoration(
          hintText: 'Field label',
          hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
          filled: true,
          fillColor: AppTheme.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        ),
        TextButton(
          onPressed: () {
            final text = controller.text.trim();
            Navigator.pop(context, text.isEmpty ? currentLabel : text);
          },
          child: const Text('Save', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
        ),
      ],
    ),
  );
}

/// Wraps a list of reorderable [SettingsCheckRow]s in a drag-and-drop list —
/// used for the "custom" fields (Order Type, Order By, Table Subheading,
/// ...) that the reference lets you reorder, while fixed fields (KOT
/// Number, Table, Time) stay in place above it.
class ReorderableSettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;

  const ReorderableSettingsGroup({super.key, required this.children, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: onReorder,
      children: [
        for (int i = 0; i < children.length; i++)
          KeyedSubtree(key: ValueKey('reorderable-$i'), child: children[i]),
      ],
    );
  }
}

/// A small gray/lavender-tinted label bar dividing sub-groups within a
/// [SettingsSectionTile] (e.g. "Item Total", "Sub Total", "Taxable Amount"
/// inside Invoice Setting's Sub Total Calculation section).
class SettingsGroupLabel extends StatelessWidget {
  final String label;
  const SettingsGroupLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
    );
  }
}

/// A switch-based row inside a [SettingsSectionTile] (e.g. "Loyalty
/// Discount", "Service Charge"), optionally drag-reorderable via
/// [dragHandle] — the toggle counterpart to [SettingsCheckRow]'s checkbox
/// rows, used by Invoice Setting's Sub Total Calculation section.
class SettingsToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? dragHandle;

  const SettingsToggleRow({super.key, required this.label, required this.value, required this.onChanged, this.dragHandle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            if (dragHandle != null) ...[dragHandle!, const SizedBox(width: 8)],
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none))),
            Switch(value: value, activeThumbColor: Colors.white, activeTrackColor: AppTheme.completed, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
