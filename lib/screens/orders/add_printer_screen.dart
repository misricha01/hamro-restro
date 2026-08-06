import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/printer.dart';
import '../../widgets/common/finance_form_fields.dart';

/// Add/Edit Printer form. When [initial] is set, the fields are pre-filled
/// from the existing printer and the result is treated as an update instead
/// of a new printer — both flows share this one screen so Add and Edit stay
/// visually and behaviorally identical.
class AddPrinterScreen extends StatefulWidget {
  final Printer? initial;
  const AddPrinterScreen({super.key, this.initial});

  @override
  State<AddPrinterScreen> createState() => _AddPrinterScreenState();
}

class _AddPrinterScreenState extends State<AddPrinterScreen> {
  late final _nameController = TextEditingController(text: widget.initial?.name ?? '');
  late final _ipController = TextEditingController(text: widget.initial?.ipAddress ?? '');
  late String _paperWidth = widget.initial?.paperWidth ?? '80mm';
  late PrintFor _printFor = widget.initial?.printFor ?? PrintFor.kotAndBot;
  late bool _fullKot = widget.initial?.fullKot ?? true;
  late bool _kot = widget.initial?.kot ?? false;
  late bool _bot = widget.initial?.bot ?? false;
  String? _nameError;

  static const _paperWidths = ['80mm', '72mm', '58mm'];

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _nameError = _nameController.text.trim().isEmpty ? 'Printer name is required' : null);
    if (_nameError != null) return;
    Navigator.pop(
      context,
      Printer(
        name: _nameController.text.trim(),
        paperWidth: _paperWidth,
        ipAddress: _ipController.text.trim(),
        printFor: _printFor,
        fullKot: _fullKot,
        kot: _kot,
        bot: _bot,
      ),
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
        title: Text(
          widget.initial == null ? 'Add Printer' : 'Edit Printer',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const FieldLabel(label: 'Printer Name', required: true),
                  const SizedBox(height: 8),
                  AppTextField(controller: _nameController, hint: 'Ex: Cafe, Bar1, Bar2', errorText: _nameError, onChanged: (_) => setState(() => _nameError = null)),
                  const SizedBox(height: 16),

                  const FieldLabel(label: 'Paper Width', required: true),
                  const SizedBox(height: 8),
                  SelectField(
                    hint: 'Select paper width',
                    value: _paperWidth,
                    onTap: () async {
                      final picked = await SimpleListSheet.show(context, title: 'Paper Width', items: _paperWidths);
                      if (picked != null) setState(() => _paperWidth = picked);
                    },
                  ),
                  const SizedBox(height: 16),

                  const FieldLabel(label: 'IP Address', required: true),
                  const SizedBox(height: 8),
                  AppTextField(controller: _ipController, hint: 'Enter IP Address of your printer', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),

                  const Text('Select what you print in this Printer?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _PrintForChip(label: 'KOT & BOT', selected: _printFor == PrintFor.kotAndBot, onTap: () => setState(() => _printFor = PrintFor.kotAndBot)),
                      const SizedBox(width: 10),
                      _PrintForChip(label: 'Bills & Receipts', selected: _printFor == PrintFor.billsAndReceipts, onTap: () => setState(() => _printFor = PrintFor.billsAndReceipts)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_printFor == PrintFor.kotAndBot)
                    Container(
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('KOT & BOT', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                                SizedBox(height: 2),
                                Text('Assign KOT types to this printer', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppTheme.divider),
                          _KotCheckRow(label: 'Full KOT', subtitle: 'Print full KOT', value: _fullKot, onChanged: (v) => setState(() => _fullKot = v)),
                          _KotCheckRow(label: 'KOT', subtitle: 'Kitchen Order Ticket', value: _kot, onChanged: (v) => setState(() => _kot = v)),
                          _KotCheckRow(label: 'BOT', subtitle: 'Bar Order Ticket', value: _bot, onChanged: (v) => setState(() => _bot = v)),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.lightbulb_outline, color: AppTheme.accent, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This will auto-print dishes assigned to these KOT types.',
                                      style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
              child: Row(
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                  const Spacer(),
                  SizedBox(
                    width: 170,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.print_outlined, color: Colors.white, size: 18),
                      label: const Text('Save Printer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrintForChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PrintForChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.completed.withValues(alpha: 0.12) : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.completed : AppTheme.divider),
        ),
        child: Text(label, style: TextStyle(color: selected ? AppTheme.completed : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
      ),
    );
  }
}

class _KotCheckRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _KotCheckRow({required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                ],
              ),
            ),
            Checkbox(value: value, onChanged: (v) => onChanged(v ?? false), activeColor: AppTheme.completed),
          ],
        ),
      ),
    );
  }
}
