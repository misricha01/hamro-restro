import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Shared building blocks for every collapsible Particulars/Amounts report
/// (Profit Or Loss Statement, Balance Sheet, ...) so each report reuses one
/// tree/header/summary-row implementation instead of a per-report copy.

class ReportTreeNode {
  final String label;
  final String value;
  final List<ReportTreeNode> children;
  final bool initiallyExpanded;
  const ReportTreeNode(this.label, {this.value = '-', this.children = const [], this.initiallyExpanded = true});
}

/// Pink-tinted column header shown at the top of every report tree —
/// "Particulars / Amounts" by default, or e.g. "Accounts / Amount" with
/// sort-direction carets for Trial Balance.
class ReportParticularsHeader extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool showSortIcons;
  const ReportParticularsHeader({super.key, this.leftLabel = 'Particulars', this.rightLabel = 'Amounts', this.showSortIcons = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.cancelled.withValues(alpha: 0.12),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(leftLabel, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                if (showSortIcons) const Icon(Icons.keyboard_arrow_down, color: AppTheme.textPrimary, size: 18),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(rightLabel, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
              if (showSortIcons) const Icon(Icons.keyboard_arrow_up, color: AppTheme.textPrimary, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

/// Recursive collapsible row for a [ReportTreeNode] and its children —
/// chevron + indentation per depth, tappable to expand/collapse (starts
/// expanded, matching every reference screenshot).
class ReportTreeRow extends StatefulWidget {
  final ReportTreeNode node;
  final int depth;
  const ReportTreeRow({super.key, required this.node, this.depth = 0});

  @override
  State<ReportTreeRow> createState() => _ReportTreeRowState();
}

class _ReportTreeRowState extends State<ReportTreeRow> {
  late bool _expanded = widget.node.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.children.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: hasChildren ? () => setState(() => _expanded = !_expanded) : null,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0 + widget.depth * 18, 12, 16, 12),
            child: Row(
              children: [
                if (hasChildren)
                  Icon(_expanded ? Icons.keyboard_arrow_down : Icons.chevron_right, color: AppTheme.textSecondary, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.node.label,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: widget.depth == 0 ? FontWeight.w700 : FontWeight.w500, decoration: TextDecoration.none),
                  ),
                ),
                Text(widget.node.value, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppTheme.divider),
        if (hasChildren && _expanded)
          for (final child in widget.node.children) ReportTreeRow(node: child, depth: widget.depth + 1),
      ],
    );
  }
}

/// Highlighted (or plain) full-width summary row for a report's totals —
/// "Gross Profit or Loss", "Difference", etc.
class ReportStatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;
  const ReportStatRow({super.key, required this.label, required this.value, this.highlighted = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: highlighted ? AppTheme.card : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none)),
          ),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}
