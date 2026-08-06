import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'finance_form_fields.dart';

/// "Add custom Item" sheet reached from Quick Billing's More menu, for
/// billing a dish that isn't in the menu. Returns a cart-item-shaped map
/// matching [CustomizeDishSheet]'s `onAddToCart` payload so it can be
/// appended straight into the same cart list.
class AddCustomItemSheet extends StatefulWidget {
  final List<String> kotTypes;

  const AddCustomItemSheet({super.key, this.kotTypes = const ['Kitchen', 'Bar', 'Beverage']});

  static Future<Map<String, dynamic>?> show(BuildContext context, {List<String> kotTypes = const ['Kitchen', 'Bar', 'Beverage']}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCustomItemSheet(kotTypes: kotTypes),
    );
  }

  @override
  State<AddCustomItemSheet> createState() => _AddCustomItemSheetState();
}

class _AddCustomItemSheetState extends State<AddCustomItemSheet> {
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  final _qtyController = TextEditingController();
  final _remarksController = TextEditingController();
  String? _kotType;
  String? _nameError;
  String? _rateError;
  String? _qtyError;

  double get _amount {
    final rate = double.tryParse(_rateController.text) ?? 0;
    final qty = double.tryParse(_qtyController.text) ?? 0;
    return rate * qty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _qtyController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Item name is required' : null;
      _rateError = (double.tryParse(_rateController.text) ?? 0) <= 0 ? 'Enter a valid rate' : null;
      _qtyError = (double.tryParse(_qtyController.text) ?? 0) <= 0 ? 'Enter a valid quantity' : null;
    });
    if (_nameError != null || _rateError != null || _qtyError != null) return;

    Navigator.pop(context, {
      'dishName': _nameController.text.trim(),
      'quantity': double.parse(_qtyController.text).round(),
      'variant': null,
      'addOns': <String>[],
      'remarks': _remarksController.text,
      'totalPrice': _amount,
      'kotType': _kotType,
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    children: [
                      const Text('Add custom Item', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                      const SizedBox(height: 20),

                      const FieldLabel(label: 'Item Name', required: true),
                      const SizedBox(height: 8),
                      AppTextField(controller: _nameController, hint: 'Enter Item Name', errorText: _nameError, onChanged: (_) => setState(() => _nameError = null)),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FieldLabel(label: 'Rate', required: true),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: _rateController,
                                  hint: '00.00',
                                  prefix: 'Rs',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  errorText: _rateError,
                                  onChanged: (_) => setState(() => _rateError = null),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FieldLabel(label: 'QTY', required: true),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: _qtyController,
                                  hint: '00',
                                  keyboardType: TextInputType.number,
                                  errorText: _qtyError,
                                  onChanged: (_) => setState(() => _qtyError = null),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FieldLabel(label: 'Amount', required: false),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                                  child: Text('Rs ${_amount.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const FieldLabel(label: 'KOT Type', required: false),
                      const SizedBox(height: 8),
                      SelectField(
                        hint: 'Select Kot Type',
                        value: _kotType,
                        onTap: () async {
                          final picked = await SimpleListSheet.show(context, title: 'Select KOT Type', items: widget.kotTypes);
                          if (picked != null) setState(() => _kotType = picked);
                        },
                      ),
                      const SizedBox(height: 16),

                      const FieldLabel(label: 'Remarks', required: false),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _remarksController,
                        maxLines: 4,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        decoration: InputDecoration(
                          hintText: 'Enter your remarks',
                          hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          filled: true,
                          fillColor: AppTheme.card,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.divider))),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Discard', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 160,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _addItem,
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        ),
                      ),
                    ],
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
