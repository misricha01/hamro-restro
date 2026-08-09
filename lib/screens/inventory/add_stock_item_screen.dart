import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/stock/stock_group_model.dart';
import '../../data/models/stock/stock_model.dart';
import '../../data/models/unit/unit_model.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/stock_group_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/unit_provider.dart';
import '../../widgets/common/select_unit_sheet.dart';
import '../../widgets/common/select_stock_group_sheet.dart';

/// "Add Stock Item" form, backed by [StockProvider.createStock]
/// (`POST /api/stock`). `Reorder Level`/`Reorder QTY` have no backend field
/// on this API — they stay as UI-only inputs and aren't sent. Also reused
/// for editing (pass [existingStock]), which calls
/// [StockProvider.updateStock] (`PATCH /api/stock/{id}`) instead — the
/// picked Unit/Stock Group are resolved from the stock item's plain
/// `unitId`/`stockGroupId` once [UnitProvider]/[StockGroupProvider] have
/// loaded (both are kicked off in [initState] if not already fetched).
class AddStockItemScreen extends StatefulWidget {
  final Stock? existingStock;

  const AddStockItemScreen({super.key, this.existingStock});

  bool get isEditing => existingStock != null;

  @override
  State<AddStockItemScreen> createState() => _AddStockItemScreenState();
}

class _AddStockItemScreenState extends State<AddStockItemScreen> {
  final _itemNameController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  final _valueController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _reorderQtyController = TextEditingController();
  final _descriptionController = TextEditingController();

  Unit? _selectedUnit;
  StockGroup? _selectedGroup;
  bool _multipleUnit = false;
  bool _showAdditionalDetails = false;
  bool _unitError = false;
  bool _prefillApplied = false;

  static String _trimNum(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void initState() {
    super.initState();
    final stock = widget.existingStock;
    if (stock != null) {
      _itemNameController.text = stock.itemName;
      _purchasePriceController.text = _trimNum(stock.defaultPrice);
      _quantityController.text = _trimNum(stock.quantity);
      _rateController.text = _trimNum(stock.rate);
      _descriptionController.text = stock.description ?? '';
      if (stock.description != null && stock.description!.isNotEmpty) _showAdditionalDetails = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final unitProvider = context.read<UnitProvider>();
        if (unitProvider.status == LoadStatus.idle) unitProvider.fetchUnits();
        final groupProvider = context.read<StockGroupProvider>();
        if (groupProvider.status == LoadStatus.idle) groupProvider.fetchStockGroups();
      });
    }
  }

  void _tryApplyPrefill(BuildContext context) {
    final stock = widget.existingStock;
    if (stock == null || _prefillApplied) return;

    final unitProvider = context.watch<UnitProvider>();
    final groupProvider = context.watch<StockGroupProvider>();
    if (unitProvider.status != LoadStatus.loaded || groupProvider.status != LoadStatus.loaded) return;

    _prefillApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedUnit = stock.unitId == null ? null : unitProvider.units.where((u) => u.id == stock.unitId).firstOrNull;
        _selectedGroup = stock.stockGroupId == null ? null : groupProvider.groups.where((g) => g.id == stock.stockGroupId).firstOrNull;
      });
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _purchasePriceController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _valueController.dispose();
    _reorderLevelController.dispose();
    _reorderQtyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final itemName = _itemNameController.text.trim();
    setState(() => _unitError = _selectedUnit?.id == null);
    if (itemName.isEmpty || _unitError) return;

    final provider = context.read<StockProvider>();
    final defaultPrice = double.tryParse(_purchasePriceController.text.trim()) ?? 0;
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();

    final stock = widget.isEditing
        ? await provider.updateStock(
            id: widget.existingStock!.id,
            itemName: itemName,
            defaultPrice: defaultPrice,
            quantity: quantity,
            rate: rate,
            description: description,
            unitId: _selectedUnit!.id,
            stockGroupId: _selectedGroup?.id,
          )
        : await provider.createStock(
            itemName: itemName,
            defaultPrice: defaultPrice,
            quantity: quantity,
            rate: rate,
            description: description,
            unitId: _selectedUnit!.id!,
            stockGroupId: _selectedGroup?.id,
          );

    if (!mounted) return;
    if (stock != null) {
      Navigator.pop(context, stock);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    _tryApplyPrefill(context);
    final provider = context.watch<StockProvider>();
    final isSaving = widget.isEditing ? provider.isUpdating : provider.isCreating;

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
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: Text(
          widget.isEditing ? 'Edit Stock Item' : 'Add Stock Item',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            _FieldLabel(label: 'Item Name', required: true),
            const SizedBox(height: 8),
            _AppTextField(controller: _itemNameController, hint: 'Enter Item Name'),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _FieldLabel(label: 'Measuring Unit', required: true)),
                Checkbox(
                  value: _multipleUnit,
                  activeColor: AppTheme.accent,
                  onChanged: (val) => setState(() => _multipleUnit = val ?? false),
                ),
                const Text(
                  'Multiple Unit',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                SelectUnitSheet.show(
                  context,
                  onSelected: (unit) => setState(() {
                    _selectedUnit = unit;
                    _unitError = false;
                  }),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _unitError ? AppTheme.cancelled : AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedUnit != null
                            ? (_selectedUnit!.description?.isNotEmpty == true ? '${_selectedUnit!.name} (${_selectedUnit!.description})' : _selectedUnit!.name)
                            : 'Select Measuring Unit of the Item',
                        style: TextStyle(
                          color: _selectedUnit != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                          fontSize: 15,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
            if (_unitError)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Measuring Unit is required', style: TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none)),
              ),
            const SizedBox(height: 20),

            _FieldLabel(label: 'Purchase Price', required: false),
            const SizedBox(height: 8),
            _AppTextField(
              controller: _purchasePriceController,
              hint: '00.00',
              prefixText: 'Rs  ',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            _FieldLabel(label: 'Group', required: false),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                SelectStockGroupSheet.show(context, onSelected: (group) {
                  setState(() => _selectedGroup = group);
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedGroup?.groupName ?? 'Select Group for Item',
                        style: TextStyle(
                          color: _selectedGroup != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                          fontSize: 15,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Opening Stock',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quantity', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        const SizedBox(height: 8),
                        _AppTextField(controller: _quantityController, hint: '0.00', keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rate', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        const SizedBox(height: 8),
                        _AppTextField(controller: _rateController, hint: '0.00', prefixText: 'Rs ', keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Value', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        const SizedBox(height: 8),
                        _AppTextField(controller: _valueController, hint: '0.00', prefixText: 'Rs ', keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: () => setState(() => _showAdditionalDetails = !_showAdditionalDetails),
              child: Row(
                children: [
                  Text(
                    _showAdditionalDetails ? 'Hide Additional Details' : 'Additional Details',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Icon(
                    _showAdditionalDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),

            if (_showAdditionalDetails) ...[
              const SizedBox(height: 16),
              _FieldLabel(label: 'Reorder Level', required: false),
              const SizedBox(height: 8),
              _AppTextField(controller: _reorderLevelController, hint: 'Enter Reorder Level', keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              _FieldLabel(label: 'Reorder QTY', required: false),
              const SizedBox(height: 8),
              _AppTextField(controller: _reorderQtyController, hint: 'Enter Reorder QTY', keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              _FieldLabel(label: 'Description', required: false),
              const SizedBox(height: 8),
              _AppTextField(controller: _descriptionController, hint: 'Enter Description', maxLines: 4),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        widget.isEditing ? 'Update Stock Item' : 'Save Stock Item',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
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

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          decoration: TextDecoration.none,
        ),
        children: [
          TextSpan(text: label),
          if (required) const TextSpan(text: ' *', style: TextStyle(color: AppTheme.cancelled)),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final String? prefixText;
  final int maxLines;
  final TextInputType? keyboardType;

  const _AppTextField({
    this.controller,
    required this.hint,
    this.prefixText,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.accent),
        ),
      ),
    );
  }
}
