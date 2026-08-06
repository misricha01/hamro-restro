import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/area/area_model.dart';
import '../../data/models/orders/table_model.dart';
import '../../providers/table_provider.dart';
import '../../widgets/common/select_space_sheet.dart';
import '../../widgets/common/select_table_type_sheet.dart';

/// "Create Table" form reached from the Home Screen's "Add your first
/// table" setup step. Mirrors [CreateSpaceScreen]'s field + bottom action
/// bar pattern, adding the Table Type / Capacity / Space selectors and the
/// optional Charge amount shown in the reference design. Saves via
/// [TableProvider.createTable].
///
/// Pass [editingTable] to reuse this same form for editing an existing table
/// (title/button copy and save behavior switch to [TableProvider.updateTable];
/// tableStatus/available aren't editable here so the existing table's values
/// are carried through unchanged).
class AddTableScreen extends StatefulWidget {
  final RestaurantTable? editingTable;
  const AddTableScreen({super.key, this.editingTable});

  @override
  State<AddTableScreen> createState() => _AddTableScreenState();
}

class _AddTableScreenState extends State<AddTableScreen> {
  late final _nameController = TextEditingController(text: widget.editingTable?.tableName ?? '');
  late final _chargeController = TextEditingController();
  bool _nameError = false;
  bool _chargeError = false;

  late String? _tableType = widget.editingTable?.tableType;
  Area? _space;
  late int _capacity = widget.editingTable?.capacity ?? 4;
  bool _enableCharge = false;

  bool get _isEditing => widget.editingTable != null;

  @override
  void initState() {
    super.initState();
    _space = widget.editingTable?.area;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _chargeController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _nameController.clear();
      _chargeController.clear();
      _nameError = false;
      _chargeError = false;
      _tableType = null;
      _space = null;
      _capacity = 4;
      _enableCharge = false;
    });
  }

  void _selectTableType() {
    SelectTableTypeSheet.show(context, onSelected: (type) => setState(() => _tableType = type));
  }

  void _selectSpace() {
    SelectSpaceSheet.show(context, onSelected: (space) => setState(() => _space = space));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final charge = _enableCharge ? double.tryParse(_chargeController.text.trim()) : null;
    final chargeMissing = _enableCharge && charge == null;
    setState(() {
      _nameError = name.isEmpty;
      _chargeError = chargeMissing;
    });
    if (_nameError || _chargeError) return;

    final provider = context.read<TableProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final table = _isEditing
        ? await provider.updateTable(
            id: widget.editingTable!.id,
            tableName: name,
            tableType: _tableType,
            capacity: _capacity,
            areaId: _space?.id,
            charge: charge,
            tableStatus: widget.editingTable!.tableStatus,
            available: widget.editingTable!.available,
          )
        : await provider.createTable(
            tableName: name,
            tableType: _tableType,
            capacity: _capacity,
            areaId: _space?.id,
            charge: charge,
          );
    if (!mounted) return;

    if (table != null) {
      messenger.showSnackBar(SnackBar(content: Text(_isEditing ? 'Table updated successfully' : 'Table created successfully')));
      Navigator.pop(context, table);
    } else {
      final error = _isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      messenger.showSnackBar(SnackBar(content: Text(error ?? 'Failed to save table')));
    }
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
        title: Text(
          _isEditing ? 'Edit Table' : 'Create Table',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const _FieldLabel(label: 'Table Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Table Name',
            errorText: _nameError ? 'Required' : null,
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Table Type', required: false),
                    const SizedBox(height: 8),
                    _SelectField(hint: 'Select Table Types', value: _tableType, onTap: _selectTableType),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 132,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Capacity', required: false),
                    const SizedBox(height: 8),
                    _CapacityStepper(value: _capacity, onChanged: (v) => setState(() => _capacity = v)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _FieldLabel(label: 'Space', required: false),
          const SizedBox(height: 8),
          _SelectField(hint: 'Select Space', value: _space?.areaName, onTap: _selectSpace),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Enable Charge',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
                ),
              ),
              Switch(
                value: _enableCharge,
                activeThumbColor: Colors.white,
                activeTrackColor: AppTheme.completed,
                onChanged: (v) => setState(() {
                  _enableCharge = v;
                  if (!v) _chargeError = false;
                }),
              ),
            ],
          ),
          if (_enableCharge) ...[
            const SizedBox(height: 16),
            const _FieldLabel(label: 'Charge', required: true),
            const SizedBox(height: 8),
            _AppTextField(
              controller: _chargeController,
              hint: '0',
              prefixText: 'Rs   ',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              errorText: _chargeError ? 'Enter a valid amount' : null,
              onChanged: (v) {
                if (_chargeError && double.tryParse(v.trim()) != null) setState(() => _chargeError = false);
              },
            ),
          ],
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
              child: Consumer<TableProvider>(
                builder: (context, provider, _) {
                  final busy = _isEditing ? provider.isUpdating : provider.isCreating;
                  return ElevatedButton(
                    onPressed: busy ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(_isEditing ? 'Update Table' : 'Save Table', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  );
                },
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
        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none),
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
  final String? errorText;
  final String? prefixText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _AppTextField({
    this.controller,
    required this.hint,
    this.errorText,
    this.prefixText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        errorText: errorText,
        errorStyle: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _SelectField({required this.hint, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: value != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontSize: 14.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _CapacityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CapacityStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: value > 1 ? () => onChanged(value - 1) : null,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.remove, color: value > 1 ? AppTheme.textPrimary : AppTheme.textSecondary, size: 18),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onChanged(value + 1),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.add, color: AppTheme.textPrimary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
