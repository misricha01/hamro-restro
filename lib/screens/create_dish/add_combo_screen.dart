import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/combo_offer/combo_offer_model.dart';
import '../../data/models/media/media_model.dart';
import '../../providers/combo_offer_provider.dart';
import '../../widgets/common/media_upload_helper.dart';
import 'select_combo_items_screen.dart';

/// "Add Combo Dish" form reached from the Combo Offer screen's
/// "Create New Combo Offer" button and the Menu screen's "+ Add" pills.
/// Backed by [ComboOfferProvider.createComboOffer] (`POST /api/combo-offer`).
/// Sub-Menu / Category / Dish Type / Preparation Time from the original
/// design have no backend counterpart on a combo offer (those are per-dish
/// concepts) and are dropped. Combo Photo is wired to the real
/// `comboPhoto` field via the shared media-upload flow (mirrors Add Dish's
/// Dish Photo). Start/End dates are added since the backend requires them
/// (`startsAt`/`endsAt`) but the original design didn't have fields for
/// them. Also reused for editing (pass [existingCombo]), which calls
/// [ComboOfferProvider.updateComboOffer] (`PATCH /api/combo-offer/{id}`)
/// instead.
class AddComboScreen extends StatefulWidget {
  final ComboOffer? existingCombo;

  const AddComboScreen({super.key, this.existingCombo});

  bool get isEditing => existingCombo != null;

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
  UploadedMedia? _uploadedPhoto;

  bool _nameError = false;
  bool _itemsError = false;
  bool _offerPriceError = false;

  @override
  void initState() {
    super.initState();
    final combo = widget.existingCombo;
    if (combo != null) {
      _nameController.text = combo.name;
      _offerPriceController.text = combo.offerPrice == combo.offerPrice.roundToDouble() ? combo.offerPrice.toStringAsFixed(0) : combo.offerPrice.toString();
      _hsCodeController.text = combo.hsCode ?? '';
      _descriptionController.text = combo.description ?? '';
      _selectedItemIds = List.of(combo.dishIds);
      _startsAt = combo.startsAt;
      _endsAt = combo.endsAt;
    }
  }

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

  Future<void> _pickImageSource() async {
    final media = await pickAndUploadImage(context);
    if (media != null) setState(() => _uploadedPhoto = media);
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
    final description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();
    final hsCode = _hsCodeController.text.trim().isEmpty ? null : _hsCodeController.text.trim();

    final offer = widget.isEditing
        ? await provider.updateComboOffer(
            id: widget.existingCombo!.id,
            name: name,
            description: description,
            hsCode: hsCode,
            // A newly-uploaded photo wins; otherwise keep whatever the
            // combo already had rather than clearing it.
            comboPhoto: _uploadedPhoto?.id ?? widget.existingCombo!.comboPhoto,
            dishIds: _selectedItemIds,
            offerPrice: offerPrice!,
            startsAt: _startsAt,
            endsAt: _endsAt,
          )
        : await provider.createComboOffer(
            name: name,
            description: description,
            hsCode: hsCode,
            comboPhoto: _uploadedPhoto?.id,
            dishIds: _selectedItemIds,
            offerPrice: offerPrice!,
            startsAt: _startsAt,
            endsAt: _endsAt,
          );
    if (!mounted) return;

    if (offer != null) {
      Navigator.pop(context, offer);
    } else {
      final message = widget.isEditing ? provider.updateErrorMessage : provider.createErrorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Something went wrong. Please try again.')));
    }
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComboOfferProvider>();
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
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: Text(
          widget.isEditing ? 'Edit Combo Dish' : 'Add Combo Dish',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
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
          const SizedBox(height: 24),

          const _SectionHeader(title: 'Combo Photo'),
          const SizedBox(height: 12),
          _UploadBox(
            label: _uploadedPhoto != null
                ? 'Photo uploaded'
                : (widget.existingCombo?.comboPhotoUrl != null ? 'Tap to change photo' : 'Tap here to select or upload photos'),
            previewUrl: _uploadedPhoto?.url != null
                ? '${ApiClient.mediaBaseUrl}${_uploadedPhoto!.url}'
                : (widget.existingCombo?.comboPhotoUrl != null ? '${ApiClient.mediaBaseUrl}${widget.existingCombo!.comboPhotoUrl}' : null),
            onTap: _pickImageSource,
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
                onPressed: isSaving ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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
                    : Text(widget.isEditing ? 'Update' : 'Save', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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

class _UploadBox extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? previewUrl;

  const _UploadBox({required this.label, required this.onTap, this.previewUrl});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            if (previewUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  previewUrl!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.upload_outlined, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              const Icon(Icons.upload_outlined, color: AppTheme.textSecondary),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
            ),
          ],
        ),
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
