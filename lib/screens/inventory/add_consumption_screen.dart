import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock/stock_model.dart';
import '../../data/models/unit/unit_model.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/common/finance_form_fields.dart';
import '../../widgets/common/select_stock_sheet.dart';
import '../../widgets/common/select_unit_sheet.dart';

/// "Create Consumption" screen reached from Inventory > Consumption,
/// matching the reference design's Finished Goods (Dish/Add-Ons + dish
/// picker) and Stock Used or Reduced after Sales (repeatable Stock/Unit/
/// Qty/Amount rows) form.
///
/// There is no "consumption" concept on this backend (no dish-to-stock
/// mapping endpoint) — the closest primitive is `PATCH /api/stock/{id}/adjust`
/// with `type: 'reduce'`. "Save Consumption" loops the stock rows and calls
/// [StockProvider.adjustStock] once per row, folding the picked dish/add-on
/// name into the transaction's remark. The "Finished Goods" picker stays
/// UI-only context — it isn't sent over the network.
class AddConsumptionScreen extends StatefulWidget {
  const AddConsumptionScreen({super.key});

  @override
  State<AddConsumptionScreen> createState() => _AddConsumptionScreenState();
}

class _ConsumptionStockRow {
  final _qtyController = TextEditingController();
  final _amountController = TextEditingController();
  Stock? stock;
  Unit? unit;
  bool hasError = false;

  void dispose() {
    _qtyController.dispose();
    _amountController.dispose();
  }
}

class _AddConsumptionScreenState extends State<AddConsumptionScreen> {
  static const _dishes = ['Burger', 'Chicken Pizza', 'Iced Latte', 'Coffee', 'Water', 'Coke'];

  bool _isDish = true;
  String? _selectedDish;
  bool _dishError = false;

  final List<_ConsumptionStockRow> _rows = [_ConsumptionStockRow()];

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDish() async {
    final result = await SearchSelectSheet.show(context, title: 'Select Dish', items: _dishes, countLabel: 'Total Dish');
    if (result != null) {
      setState(() {
        _selectedDish = result;
        _dishError = false;
      });
    }
  }

  Future<void> _pickStock(_ConsumptionStockRow row) async {
    final result = await SelectStockSheet.show(context);
    if (result != null) {
      setState(() {
        row.stock = result;
        row.unit = null;
        row.hasError = false;
      });
    }
  }

  Future<void> _pickUnit(_ConsumptionStockRow row) async {
    if (row.stock == null) {
      await _BlockedSelectSheet.show(context, title: 'Select Unit', message: 'No Stock selected');
      return;
    }
    await SelectUnitSheet.show(context, onSelected: (unit) => setState(() => row.unit = unit));
  }

  void _addRow() => setState(() => _rows.add(_ConsumptionStockRow()));

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _save() async {
    setState(() => _dishError = _selectedDish == null);

    var hasRowError = false;
    for (final row in _rows) {
      row.hasError = row.stock == null || row.stock!.id.isEmpty || double.tryParse(row._qtyController.text.trim()) == null;
      if (row.hasError) hasRowError = true;
    }
    setState(() {});
    if (_dishError || hasRowError) return;

    final provider = context.read<StockProvider>();
    final remark = 'Consumed by ${_isDish ? 'dish' : 'add-on'}: $_selectedDish';
    for (final row in _rows) {
      final quantity = double.tryParse(row._qtyController.text.trim()) ?? 0;
      final amount = double.tryParse(row._amountController.text.trim());
      final rate = amount != null && quantity > 0 ? amount / quantity : row.stock!.rate;
      final ok = await provider.adjustStock(
        id: row.stock!.id,
        type: 'reduce',
        quantity: quantity,
        rate: rate,
        transactionDate: DateTime.now(),
        remark: remark,
      );
      if (ok == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.adjustErrorMessage ?? 'Something went wrong. Please try again.')));
        return;
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isAdjusting = context.watch<StockProvider>().isAdjusting;

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
          'Create Consumption',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Finished Goods', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                    const Spacer(),
                    const Text('Output', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _SmallChip(label: 'Dish', selected: _isDish, onTap: () => setState(() => _isDish = true)),
                    const SizedBox(width: 10),
                    _SmallChip(label: 'Add-Ons', selected: !_isDish, onTap: () => setState(() => _isDish = false)),
                  ],
                ),
                const SizedBox(height: 16),
                FieldLabel(label: _isDish ? 'Dish' : 'Add-On', required: true),
                const SizedBox(height: 8),
                SelectField(
                  hint: _isDish ? 'Select Dish' : 'Select Add-On',
                  value: _selectedDish,
                  onTap: _pickDish,
                  errorText: _dishError ? 'Required' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: _ConnectorMark()),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Stock Used or Reduced after Sales', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                    ),
                    const Text('Input', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
                  ],
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < _rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _StockRowCard(
                    row: _rows[i],
                    onPickStock: () => _pickStock(_rows[i]),
                    onPickUnit: () => _pickUnit(_rows[i]),
                    onDelete: () => _removeRow(i),
                  ),
                ],
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _addRow,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.divider),
                      foregroundColor: AppTheme.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add More', style: TextStyle(decoration: TextDecoration.none, fontWeight: FontWeight.w600)),
                  ),
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
                onPressed: isAdjusting ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isAdjusting ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: isAdjusting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Consumption', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockRowCard extends StatelessWidget {
  final _ConsumptionStockRow row;
  final VoidCallback onPickStock;
  final VoidCallback onPickUnit;
  final VoidCallback onDelete;

  const _StockRowCard({required this.row, required this.onPickStock, required this.onPickUnit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.delete_outline, color: AppTheme.cancelled, size: 20),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: 'Stocks', required: true),
                    const SizedBox(height: 8),
                    SelectField(hint: 'Select Stock', value: row.stock?.itemName, onTap: onPickStock, errorText: row.hasError && row.stock == null ? 'Required' : null),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: 'Unit', required: true),
                    const SizedBox(height: 8),
                    SelectField(hint: 'Select Unit', value: row.unit?.name, onTap: onPickUnit),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: 'QTY', required: true),
                    const SizedBox(height: 8),
                    AppTextField(controller: row._qtyController, hint: '0', keyboardType: TextInputType.number, errorText: row.hasError && row.stock != null ? 'Required' : null),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel(label: 'Amount', required: false),
                    const SizedBox(height: 8),
                    AppTextField(controller: row._amountController, hint: '0', prefix: 'Rs', keyboardType: TextInputType.number),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SmallChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cancelled : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.cancelled : AppTheme.divider),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
        ),
      ),
    );
  }
}

/// Small vertical-bars connector between the Finished Goods and Stock Used
/// cards, matching the reference design's divider glyph.
class _ConnectorMark extends StatelessWidget {
  const _ConnectorMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 3, height: 16, color: AppTheme.divider),
        const SizedBox(width: 4),
        Container(width: 3, height: 16, color: AppTheme.divider),
      ],
    );
  }
}

/// Small "picker blocked" sheet — used by Select Unit before a Stock is
/// chosen, matching the reference design's plain "No Stock selected" state.
class _BlockedSelectSheet extends StatelessWidget {
  final String title;
  final String message;
  const _BlockedSelectSheet({required this.title, required this.message});

  static Future<void> show(BuildContext context, {required String title, required String message}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BlockedSelectSheet(title: title, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Center(
                child: Text(message, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
