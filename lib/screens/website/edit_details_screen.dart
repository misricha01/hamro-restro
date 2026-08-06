import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../create_dish/add_dish_screen.dart' show ImageSourceSheet;

/// Result payload returned when the Edit Details form is saved.
class WebsiteDetails {
  final String? logoImageSource;
  final String restaurantName;
  final String phone;
  final String timeZone;
  final String subDomain;
  final String email;
  final String type;
  final String country;
  final String currency;
  final String address;
  final DateTime? openingDate;
  final String facebook;
  final String instagram;
  final String tiktok;
  final String googleReview;

  const WebsiteDetails({
    this.logoImageSource,
    required this.restaurantName,
    required this.phone,
    required this.timeZone,
    required this.subDomain,
    required this.email,
    required this.type,
    required this.country,
    required this.currency,
    required this.address,
    required this.openingDate,
    required this.facebook,
    required this.instagram,
    required this.tiktok,
    required this.googleReview,
  });
}

/// "Edit Details" screen for the Website module: restaurant profile, domain,
/// type, location and social profile links shown on the public website.
class EditDetailsScreen extends StatefulWidget {
  final WebsiteDetails? initial;
  const EditDetailsScreen({super.key, this.initial});

  @override
  State<EditDetailsScreen> createState() => _EditDetailsScreenState();
}

class _EditDetailsScreenState extends State<EditDetailsScreen> {
  static const _timeZones = ['Asia/Kathmandu', 'Asia/Kolkata', 'Asia/Dubai', 'Asia/Dhaka', 'UTC'];
  static const _countries = ['Nepal', 'India', 'United States', 'United Kingdom', 'Australia'];
  static const _types = ['FastFood', 'Resort', 'Hotel', 'Bakery', 'Cloud Kitchen', 'Bar', 'Cafe', 'Restaurant'];

  late final _nameController = TextEditingController(text: widget.initial?.restaurantName ?? 'Hamro Restro');
  late final _phoneController = TextEditingController(text: widget.initial?.phone ?? '9804824711');
  late final _subDomainController = TextEditingController(text: widget.initial?.subDomain ?? 'hamrorestro226');
  late final _emailController = TextEditingController(text: widget.initial?.email ?? '');
  late final _currencyController = TextEditingController(text: widget.initial?.currency ?? 'NPR');
  late final _addressController = TextEditingController(text: widget.initial?.address ?? 'M8MM+CM7, Shankhamul Marg, Kathmandu 44600, Nepal');
  late final _facebookController = TextEditingController(text: widget.initial?.facebook ?? '');
  late final _instagramController = TextEditingController(text: widget.initial?.instagram ?? '');
  late final _tiktokController = TextEditingController(text: widget.initial?.tiktok ?? '');
  late final _googleReviewController = TextEditingController(text: widget.initial?.googleReview ?? '');

  String? _logoImageSource;
  late String _timeZone = widget.initial?.timeZone ?? 'Asia/Kathmandu';
  late String _country = widget.initial?.country ?? 'Nepal';
  String? _type = 'Restaurant';
  DateTime? _openingDate;

  bool _isDirty = false;
  bool _nameError = false;
  bool _phoneError = false;
  bool _subDomainError = false;
  bool _addressError = false;

  @override
  void initState() {
    super.initState();
    _logoImageSource = widget.initial?.logoImageSource;
    _type = widget.initial?.type ?? 'Restaurant';
    _openingDate = widget.initial?.openingDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _subDomainController.dispose();
    _emailController.dispose();
    _currencyController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _googleReviewController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _pickLogo() async {
    final result = await ImageSourceSheet.show(context, includeLibrary: false);
    if (result != null) setState(() { _logoImageSource = result; _isDirty = true; });
  }

  Future<void> _pickTimeZone() async {
    final result = await _SimpleSelectSheet.show(context, title: 'Restaurant Time Zone', options: _timeZones, selected: _timeZone);
    if (result != null) setState(() { _timeZone = result; _isDirty = true; });
  }

  Future<void> _pickCountry() async {
    final result = await _SimpleSelectSheet.show(context, title: 'Country', options: _countries, selected: _country);
    if (result != null) setState(() { _country = result; _isDirty = true; });
  }

  Future<void> _pickOpeningDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _openingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() { _openingDate = result; _isDirty = true; });
  }

  String _formatDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _save() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _phoneError = _phoneController.text.trim().isEmpty;
      _subDomainError = _subDomainController.text.trim().isEmpty;
      _addressError = _addressController.text.trim().isEmpty;
    });
    if (_nameError || _phoneError || _subDomainError || _addressError) return;

    final details = WebsiteDetails(
      logoImageSource: _logoImageSource,
      restaurantName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      timeZone: _timeZone,
      subDomain: _subDomainController.text.trim(),
      email: _emailController.text.trim(),
      type: _type ?? 'Restaurant',
      country: _country,
      currency: _currencyController.text.trim(),
      address: _addressController.text.trim(),
      openingDate: _openingDate,
      facebook: _facebookController.text.trim(),
      instagram: _instagramController.text.trim(),
      tiktok: _tiktokController.text.trim(),
      googleReview: _googleReviewController.text.trim(),
    );
    Navigator.pop(context, details);
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
        title: const Text(
          'Edit Details',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _FieldLabel(label: 'Restaurant Logo Photo', required: false),
          const SizedBox(height: 8),
          _UploadBox(
            label: _logoImageSource == null ? 'Tap here to select or upload photos' : 'Selected via $_logoImageSource',
            onTap: _pickLogo,
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Restaurant Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Enter Restaurant Name',
            errorText: _nameError ? 'Restaurant Name is required' : null,
            onChanged: (v) {
              _markDirty();
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Phone Number', required: true),
          const SizedBox(height: 8),
          _PhoneField(
            controller: _phoneController,
            onChanged: (v) {
              _markDirty();
              if (_phoneError && v.trim().isNotEmpty) setState(() => _phoneError = false);
            },
          ),
          if (_phoneError) const Padding(padding: EdgeInsets.only(top: 6, left: 4), child: Text('Phone Number is required', style: TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none))),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Restaurant Time Zone', required: true),
          const SizedBox(height: 8),
          _DropdownField(value: _timeZone, onTap: _pickTimeZone),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Sub Domain', required: true),
          const SizedBox(height: 8),
          TextField(
            controller: _subDomainController,
            onChanged: (v) {
              _markDirty();
              if (_subDomainError && v.trim().isNotEmpty) setState(() => _subDomainError = false);
              setState(() {});
            },
            style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('.restro.link', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                    const SizedBox(width: 6),
                    if (_subDomainController.text.trim().isNotEmpty) const Icon(Icons.check_circle, color: AppTheme.completed, size: 18),
                  ],
                ),
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              errorText: _subDomainError ? 'Sub Domain is required' : null,
              errorStyle: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none),
              filled: true,
              fillColor: AppTheme.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
            ),
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Email', required: false),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _emailController,
            hint: 'Enter Your Email Address',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Type', required: true),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _types.map((type) {
              final selected = _type == type;
              return InkWell(
                onTap: () => setState(() { _type = type; _isDirty = true; }),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.accent.withValues(alpha: 0.15) : AppTheme.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider, width: selected ? 1.4 : 1),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(color: selected ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Country', required: true),
                    const SizedBox(height: 8),
                    _DropdownField(value: _country, onTap: _pickCountry),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Currency', required: true),
                    const SizedBox(height: 8),
                    _AppTextField(controller: _currencyController, hint: 'NPR', onChanged: (_) => _markDirty()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Restaurant Address', required: true),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _addressController,
                  onChanged: (v) {
                    _markDirty();
                    if (_addressError && v.trim().isNotEmpty) setState(() => _addressError = false);
                  },
                  style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    hintText: 'Search Restaurant Address',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                    errorText: _addressError ? 'Restaurant Address is required' : null,
                    errorStyle: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none),
                    filled: true,
                    fillColor: AppTheme.card,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Map picker coming soon'))),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                  child: const Icon(Icons.map_outlined, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Transaction Opening Date', required: true),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickOpeningDate,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _openingDate == null ? 'Pick Transaction Opening Date' : _formatDate(_openingDate!),
                    style: TextStyle(color: _openingDate == null ? AppTheme.textSecondary : AppTheme.textPrimary, decoration: TextDecoration.none),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          const Text('Social Profile', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          const SizedBox(height: 16),

          const Text('Facebook', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          _AppTextField(controller: _facebookController, hint: 'Enter Restaurant Facebook link', keyboardType: TextInputType.url, onChanged: (_) => _markDirty()),
          const SizedBox(height: 18),

          const Text('Instagram', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          _AppTextField(controller: _instagramController, hint: 'Enter Restaurant Instagram link', keyboardType: TextInputType.url, onChanged: (_) => _markDirty()),
          const SizedBox(height: 18),

          const Text('Tiktok', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          _AppTextField(controller: _tiktokController, hint: 'Enter Restaurant Tiktok link', keyboardType: TextInputType.url, onChanged: (_) => _markDirty()),
          const SizedBox(height: 18),

          const Text('Google Review', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
          const SizedBox(height: 8),
          _AppTextField(controller: _googleReviewController, hint: 'Enter Restaurant Google Review link', keyboardType: TextInputType.url, onChanged: (_) => _markDirty()),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _AppTextField({this.controller, required this.hint, this.errorText, this.keyboardType, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
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
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _UploadBox({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            const Icon(Icons.upload_outlined, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          ],
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _PhoneField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇳🇵', style: TextStyle(fontSize: 18)),
                SizedBox(width: 6),
                Text('+977', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.textSecondary),
              ],
            ),
          ),
          Container(width: 1, height: 24, color: AppTheme.divider),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              onChanged: onChanged,
              style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
              decoration: const InputDecoration(
                hintText: 'Enter Phone Number',
                hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  const _DropdownField({required this.value, required this.onTap});

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
            Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none))),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Generic single-select bottom sheet used for Time Zone / Country pickers.
class _SimpleSelectSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;

  const _SimpleSelectSheet({required this.title, required this.options, required this.selected});

  static Future<String?> show(BuildContext context, {required String title, required List<String> options, required String selected}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SimpleSelectSheet(title: title, options: options, selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
              const SizedBox(height: 12),
              for (final option in options)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.pop(context, option),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(option, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        ),
                        if (option == selected) const Icon(Icons.check, color: AppTheme.accent, size: 20),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
