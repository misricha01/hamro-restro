import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/combo_offer_provider.dart';
import 'select_combo_items_screen.dart';

/// "Add Combo Dish" form reached from the Combo Offer screen's
/// "Create New Combo Offer" button and the Menu screen's "+ Add" pills.
/// Backed by [ComboOfferProvider.createComboOffer] (`POST /api/combo-offer`).
/// Sub-Menu / Category / Dish Type / Preparation Time / Combo Photo from the
/// original design have no backend counterpart on a combo offer (those are
/// per-dish concepts, or — for Combo Photo — there's no media-upload flow
/// wired up anywhere in this app yet) and are dropped. Start/End dates are
/// added since the backend requires them (`startsAt`/`endsAt`) but the
/// original design didn't have fields for them.
class AddComboScreen extends StatefulWidget {
  const AddComboScreen({super.key});

  @override
  State<AddComboScreen> createState() => _AddComboScreenState();
}

class _AddComboScreenState extends State<AddComboScreen> {
  final _nameController = TextEditingController();
  final _offerPriceController = TextEditingController();
  final _hsCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _selectedItemIds = [];
  DateTime _startsAt = DateTime.now();
  DateTime _endsAt = DateTime.now().add(const Duration(days: 30));

  bool _nameError = false;
  bool _itemsError = false;
  bool _offerPriceError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _offerPriceController.dispose();
    _hsCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickItems() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (context) => SelectComboItemsScreen(initiallySelected: _selectedItemIds)),
    );
    if (result != null) {
      setState(() {
        _selectedItemIds = result;
        _itemsError = false;
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final result = await showDatePicker(
      context: context,
      initialDate: isStart ? _startsAt : _endsAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result == null) return;
    setState(() {
      if (isStart) {
        _startsAt = result;
        if (_endsAt.isBefore(_startsAt)) _endsAt = _startsAt.add(const Duration(days: 1));
      } else {
        _endsAt = result;
      }
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final offerPrice = double.tryParse(_offerPriceController.text.trim());
    setState(() {
      _nameError = name.isEmpty;
      _itemsError = _selectedItemIds.isEmpty;
      _offerPriceError = offerPrice == null;
    });
    if (_nameError || _itemsError || _offerPriceError) return;

    final provider = context.read<ComboOfferProvider>();
    final offer = await provider.createComboOffer(
      name: name,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      hsCode: _hsCodeController.text.trim().isEmpty ? null : _hsCodeController.text.trim(),
      dishIds: _selectedItemIds,
      offerPrice: offerPrice!,
      startsAt: _startsAt,
      endsAt: _endsAt,
    );
    if (!mounted) return;

    if (offer != null) {
      Navigator.pop(context, offer);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.createErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isCreating = context.watch<ComboOfferProvider>().isCreating;

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
          'Add Combo Dish',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const _FieldLabel(label: 'Combo Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Enter Combo Name',
            errorText: _nameError ? 'Required' : null,
            onChanged: (v) {
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 24),

          const _SectionHeader(title: 'Items'),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickItems,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _itemsError ? AppTheme.cancelled : Colors.transparent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedItemIds.isEmpty ? 'Add Item Details' : '${_selectedItemIds.length} Item(s) selected',
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.chevron_right, color: AppTheme.textPrimary, size: 18),
                  ),
                ],
              ),
            ),
          ),
          if (_itemsError)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Select at least one item', style: TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none)),
            ),
          const SizedBox(height: 24),

          const _FieldLabel(label: 'Offer Price', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _offerPriceController,
            hint: 'Rs.',
            keyboardType: TextInputType.number,
            errorText: _offerPriceError ? 'Required' : null,
            onChanged: (v) {
              if (_offerPriceError && v.trim().isNotEmpty) setState(() => _offerPriceError = false);
            },
          ),
          const SizedBox(height: 24),

          const _SectionHeader(title: 'Availability'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Starts At', required: true),
                    const SizedBox(height: 8),
                    _DateField(date: _startsAt, label: _formatDate(_startsAt), onTap: () => _pickDate(isStart: true)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Ends At', required: true),
                    const SizedBox(height: 8),
                    _DateField(date: _endsAt, label: _formatDate(_endsAt), onTap: () => _pickDate(isStart: false)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const _SectionHeader(title: 'Other Details'),
          const SizedBox(height: 12),
          const _FieldLabel(label: 'H.S Code', required: false),
          const SizedBox(height: 8),
          _AppTextField(controller: _hsCodeController, hint: 'Enter HS Code eg. 20.5...'),
          const SizedBox(height: 24),

          const _SectionHeader(title: 'Description'),
          const SizedBox(height: 12),
          _AppTextField(controller: _descriptionController, hint: 'Write a description...', maxLines: 4),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: isCreating ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isCreating ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isCreating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime date;
  final String label;
  final VoidCallback onTap;
  const _DateField({required this.date, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none))),
            const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppTheme.divider)),
      ],
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
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const _AppTextField({
    this.controller,
    required this.hint,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
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
