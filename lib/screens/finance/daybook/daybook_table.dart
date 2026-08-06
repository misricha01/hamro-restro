import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Account columns shown across the Daybook / Close Daybook summary table,
/// matching the reference design's horizontally-scrollable "PMT Accounts |
/// Bank Account | Counter 1 | Owner's Account | Total | Credit (Due)" table.
const List<String> kDaybookAccountColumns = [
  'Cash',
  'Bank Account',
  'Counter 1',
  "Owner's Account",
  'Total',
  'Credit (Due)',
];

enum _DaybookRowKind { section, data, total, spacer, editable }

/// One row of the Daybook summary table. Use the named constructors instead
/// of the default one.
class DaybookRow {
  final String? label;
  final _DaybookRowKind _kind;
  final List<TextEditingController>? controllers;

  const DaybookRow._(this.label, this._kind, {this.controllers});

  /// Bold underlined section title (e.g. "Receipts", "Payments") with no
  /// values.
  const DaybookRow.section(String label) : this._(label, _DaybookRowKind.section);

  /// A plain data row showing "Rs 0" under every account column except
  /// "Credit (Due)" which is left as "-".
  const DaybookRow.data(String label) : this._(label, _DaybookRowKind.data);

  /// A subtotal/balance row rendered with a shaded background and bold text
  /// (e.g. "Total Receipts [A]", "Closing Balance [E = D + C]").
  const DaybookRow.total(String label) : this._(label, _DaybookRowKind.total);

  /// Vertical breathing room between sections.
  const DaybookRow.spacer() : this._(null, _DaybookRowKind.spacer);

  /// An editable row (Close Daybook's "Adjust Balance") with one text field
  /// per account column, in the same order as [kDaybookAccountColumns],
  /// excluding "Credit (Due)" which stays "-".
  const DaybookRow.editable(String label, List<TextEditingController> controllers)
      : this._(label, _DaybookRowKind.editable, controllers: controllers);
}

/// Horizontally-scrollable financial summary table used by both the main
/// Daybook screen and the Close Daybook screen, so the two stay visually
/// identical.
class DaybookSummaryTable extends StatelessWidget {
  final List<DaybookRow> rows;
  final List<String> columns;

  const DaybookSummaryTable({super.key, required this.rows, this.columns = kDaybookAccountColumns});

  static const double _labelWidth = 152;
  static const double _valueWidth = 108;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          columnWidths: {
            0: const FixedColumnWidth(_labelWidth),
            for (int i = 0; i < columns.length; i++) i + 1: const FixedColumnWidth(_valueWidth),
          },
          children: [
            _headerRow(),
            for (final row in rows) _buildRow(row),
          ],
        ),
      ),
    );
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: const BoxDecoration(color: AppTheme.card),
      children: [
        _cell(const SizedBox.shrink(), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
        for (final col in columns)
          _cell(
            Text(
              col,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          ),
      ],
    );
  }

  TableRow _buildRow(DaybookRow row) {
    switch (row._kind) {
      case _DaybookRowKind.spacer:
        return TableRow(
          children: [
            for (int i = 0; i <= columns.length; i++) const SizedBox(height: 18),
          ],
        );

      case _DaybookRowKind.section:
        return TableRow(
          children: [
            _cell(
              Text(
                row.label!,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            for (int i = 0; i < columns.length; i++) _cell(const SizedBox.shrink()),
          ],
        );

      case _DaybookRowKind.data:
      case _DaybookRowKind.total:
        final highlighted = row._kind == _DaybookRowKind.total;
        final textStyle = TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: highlighted ? FontWeight.bold : FontWeight.w500,
          fontSize: 13.5,
          decoration: TextDecoration.none,
        );
        return TableRow(
          decoration: highlighted ? const BoxDecoration(color: AppTheme.card) : null,
          children: [
            _cell(Text(row.label!, style: textStyle)),
            for (final col in columns)
              _cell(
                Text(
                  col == 'Credit (Due)' ? '-' : 'Rs 0',
                  style: col == 'Credit (Due)'
                      ? const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)
                      : textStyle,
                ),
              ),
          ],
        );

      case _DaybookRowKind.editable:
        return TableRow(
          children: [
            _cell(
              Text(
                row.label!,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none),
              ),
            ),
            for (int i = 0; i < columns.length; i++)
              _cell(
                columns[i] == 'Credit (Due)'
                    ? const Text('-', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none))
                    : _AdjustBalanceField(controller: row.controllers![i]),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              ),
          ],
        );
    }
  }

  Widget _cell(Widget child, {EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12)}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        padding: padding,
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider))),
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}

class _AdjustBalanceField extends StatelessWidget {
  final TextEditingController controller;
  const _AdjustBalanceField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Rs 0',
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.accent)),
      ),
    );
  }
}

/// The standard Receipts + Payments + Net/Opening/Closing balance rows shared
/// by both the Daybook and Close Daybook screens.
List<DaybookRow> buildDaybookBalanceRows({
  List<TextEditingController>? adjustBalanceControllers,
  bool includeDifference = false,
}) {
  return [
    const DaybookRow.section('Receipts'),
    const DaybookRow.data('Net Sales'),
    const DaybookRow.data('Purchase Return'),
    const DaybookRow.data('Payment In'),
    const DaybookRow.data('Income'),
    const DaybookRow.data('Balance T/F (IN)'),
    const DaybookRow.total('Total Receipts [A]'),
    const DaybookRow.section('Payments'),
    const DaybookRow.data('Purchase'),
    const DaybookRow.data('Sales Return'),
    const DaybookRow.data('Payment Out'),
    const DaybookRow.data('Expenses'),
    const DaybookRow.data('Balance T/F (OUT)'),
    const DaybookRow.total('Total Payments [B]'),
    const DaybookRow.spacer(),
    const DaybookRow.data('Net Receipts [C = A-B]'),
    const DaybookRow.data("Opening Balance (D)"),
    if (adjustBalanceControllers != null) DaybookRow.editable('Adjust Balance', adjustBalanceControllers),
    const DaybookRow.total('Closing Balance [E = D + C]'),
    if (includeDifference) ...[
      const DaybookRow.spacer(),
      const DaybookRow.data('Difference [Finance - Daybook]'),
    ],
  ];
}
