import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/restaurant_profile.dart';
import '../../models/restaurant_type.dart';
import '../../models/update_restaurant_request.dart';
import '../../services/restaurant_service.dart';
import '../../widgets/common/finance_form_fields.dart' show PhoneField;
import '../../widgets/common/location_picker_sheets.dart';
import '../../widgets/common/media_upload_helper.dart';

/// Result payload returned when the Restaurant Details form is saved.
/// [typeId]/[typeName] describe the selected entry from `GET
/// /type-of-restro`. Timezone and Currency still have no backing endpoint,
/// so they stay local-only until the API exposes them.
class RestaurantDetails {
  final String? logoImageSource;
  final String restaurantName;
  final String phone;
  final String timeZone;
  final String subDomain;
  final String email;
  final String? typeId;
  final String? typeName;
  final String country;
  final String district;
  final String currency;
  final String address;
  final DateTime? openingDate;
  final String facebook;
  final String instagram;
  final String youtube;
  final String tiktok;
  final String googleReview;

  const RestaurantDetails({
    this.logoImageSource,
    required this.restaurantName,
    required this.phone,
    required this.timeZone,
    required this.subDomain,
    required this.email,
    this.typeId,
    this.typeName,
    required this.country,
    required this.district,
    required this.currency,
    required this.address,
    required this.openingDate,
    required this.facebook,
    required this.instagram,
    required this.youtube,
    required this.tiktok,
    required this.googleReview,
  });
}

enum _LoadState { loading, loaded, error }

/// "Restaurant Details" screen reached from Manage > Setting > General
/// Setting: the restaurant's profile, domain, type, location and social
/// profile links, matching the reference "Edit Details" design.
///
/// Loads real data from `GET /restaurant` on open. Timezone, Type and
/// Currency aren't part of that response yet, so they stay local-only
/// fields until the backend exposes them.
class RestaurantDetailsScreen extends StatefulWidget {
  final RestaurantDetails? initial;
  const RestaurantDetailsScreen({super.key, this.initial});

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  _LoadState _loadState = _LoadState.loading;
  String? _loadError;
  List<RestaurantType> _types = [];
  bool _saving = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subDomainController = TextEditingController();
  final _emailController = TextEditingController();
  final _currencyController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _googleReviewController = TextEditingController();

  String? _logoId;
  String? _existingLogoUrl;
  String? _uploadedLogoPreviewUrl;
  String _dialCode = '+977';
  String _timeZone = 'Asia/Kathmandu';
  String _country = 'Nepal';
  String? _selectedTypeId;
  DateTime? _openingDate;

  bool _isDirty = false;
  bool _nameError = false;
  bool _phoneError = false;
  bool _subDomainError = false;
  bool _addressError = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) _applyInitial(widget.initial!);
    _fetchProfile();
  }

  void _applyInitial(RestaurantDetails initial) {
    _nameController.text = initial.restaurantName;
    _phoneController.text = initial.phone;
    _timeZone = initial.timeZone;
    _subDomainController.text = initial.subDomain;
    _emailController.text = initial.email;
    _selectedTypeId = initial.typeId;
    _country = initial.country;
    _districtController.text = initial.district;
    _currencyController.text = initial.currency;
    _addressController.text = initial.address;
    _openingDate = initial.openingDate;
    _facebookController.text = initial.facebook;
    _instagramController.text = initial.instagram;
    _youtubeController.text = initial.youtube;
    _tiktokController.text = initial.tiktok;
    _googleReviewController.text = initial.googleReview;
  }

  void _applyProfile(RestaurantProfile profile) {
    _nameController.text = profile.restaurantName;
    _logoId = profile.restaurantLogoId;
    _existingLogoUrl = profile.logoUrl == null ? null : '${ApiClient.mediaBaseUrl}${profile.logoUrl}';
    _dialCode = profile.dialCode ?? _dialCode;
    _phoneController.text = profile.localPhoneNumber ?? '';
    _subDomainController.text = profile.subDomain ?? '';
    _emailController.text = profile.email ?? '';
    _country = profile.country ?? _country;
    _districtController.text = profile.district ?? '';
    _addressController.text = profile.address ?? '';
    _openingDate = profile.openingDate ?? DateTime.now();
    _facebookController.text = profile.facebookUrl ?? '';
    _instagramController.text = profile.instagramUrl ?? '';
    _youtubeController.text = profile.youtubeUrl ?? '';
    _tiktokController.text = profile.tiktokUrl ?? '';
    _googleReviewController.text = profile.googleReviewUrl ?? '';
    // GET /restaurant doesn't return the current restaurantTypeId, so the
    // Type chips can't be pre-selected yet even though the list is real.
  }

  Future<void> _fetchProfile() async {
    setState(() => _loadState = _LoadState.loading);
    try {
      final results = await Future.wait([
        if (widget.initial == null) RestaurantService.getRestaurantProfile(),
        RestaurantService.getRestaurantTypes(),
      ]);
      if (widget.initial == null) {
        _applyProfile(results[0] as RestaurantProfile);
        _types = results[1] as List<RestaurantType>;
      } else {
        _types = results[0] as List<RestaurantType>;
      }
      setState(() => _loadState = _LoadState.loaded);
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _loadState = _LoadState.error;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _subDomainController.dispose();
    _emailController.dispose();
    _currencyController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _tiktokController.dispose();
    _googleReviewController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _pickLogo() async {
    final media = await pickAndUploadImage(context, includeLibrary: false);
    if (media != null) {
      setState(() {
        _logoId = media.id;
        _uploadedLogoPreviewUrl = media.url == null ? null : '${ApiClient.mediaBaseUrl}${media.url}';
        _isDirty = true;
      });
    }
  }

  Future<void> _pickTimeZone() async {
    final result = await TimezonePickerSheet.show(context, selected: _timeZone);
    if (result != null) setState(() { _timeZone = result; _isDirty = true; });
  }

  Future<void> _pickCountry() async {
    final result = await CountryPickerSheet.show(context, selected: _country);
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

  Future<void> _save() async {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _phoneError = _phoneController.text.trim().isEmpty;
      _subDomainError = _subDomainController.text.trim().isEmpty;
      _addressError = _addressController.text.trim().isEmpty;
    });
    if (_nameError || _phoneError || _subDomainError || _addressError) return;

    final selectedType = _types.where((t) => t.id == _selectedTypeId).firstOrNull;
    final phone = _phoneController.text.trim();

    setState(() => _saving = true);
    try {
      final updated = await RestaurantService.updateRestaurantSettings(
        UpdateRestaurantRequest(
          restaurantName: _nameController.text.trim(),
          restaurantLogoId: _logoId,
          contactNumber: phone.isEmpty ? null : '$_dialCode-$phone',
          subDomain: _subDomainController.text.trim(),
          email: _emailController.text.trim(),
          country: _country,
          district: _districtController.text.trim(),
          address: _addressController.text.trim(),
          restaurantTypeId: _selectedTypeId,
          openingDate: _openingDate == null ? null : _formatDate(_openingDate!),
          facebookUrl: _facebookController.text.trim(),
          instagramUrl: _instagramController.text.trim(),
          youtubeUrl: _youtubeController.text.trim(),
          tiktokUrl: _tiktokController.text.trim(),
          googleReviewUrl: _googleReviewController.text.trim(),
        ),
      );
      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.pop(
        context,
        RestaurantDetails(
          restaurantName: updated.restaurantName,
          phone: phone,
          timeZone: _timeZone,
          subDomain: updated.subDomain ?? '',
          email: updated.email ?? '',
          typeId: _selectedTypeId,
          typeName: selectedType?.name,
          country: updated.country ?? _country,
          district: updated.district ?? '',
          currency: _currencyController.text.trim(),
          address: updated.address ?? '',
          openingDate: updated.openingDate ?? _openingDate,
          facebook: updated.facebookUrl ?? '',
          instagram: updated.instagramUrl ?? '',
          youtube: updated.youtubeUrl ?? '',
          tiktok: updated.tiktokUrl ?? '',
          googleReview: updated.googleReviewUrl ?? '',
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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
        title: const Text(
          'Edit Details',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: switch (_loadState) {
        _LoadState.loading => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        _LoadState.error => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  Text(_loadError ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: _fetchProfile,
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                    child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                  ),
                ],
              ),
            ),
          ),
        _LoadState.loaded => _buildForm(context),
      },
      bottomNavigationBar: _loadState != _LoadState.loaded
          ? null
          : Container(
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
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _FieldLabel(label: 'Restaurant Logo Photo', required: false),
        const SizedBox(height: 8),
        _UploadBox(
          label: _uploadedLogoPreviewUrl != null
              ? 'Photo uploaded'
              : (_existingLogoUrl != null ? 'Tap to change photo' : 'Tap here to select or upload photos'),
          previewUrl: _uploadedLogoPreviewUrl ?? _existingLogoUrl,
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
        PhoneField(
          controller: _phoneController,
          countryCode: _dialCode,
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
        if (_types.isEmpty)
          const Text('No restaurant types available.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none))
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _types.map((type) {
              final selected = _selectedTypeId == type.id;
              return InkWell(
                onTap: () => setState(() { _selectedTypeId = type.id; _isDirty = true; }),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider, width: selected ? 1.4 : 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(Icons.check, color: AppTheme.primary, size: 15),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        type.name,
                        style: TextStyle(color: selected ? AppTheme.primary : AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none),
                      ),
                    ],
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

        const _FieldLabel(label: 'District', required: false),
        const SizedBox(height: 8),
        _AppTextField(controller: _districtController, hint: 'Enter District', onChanged: (_) => _markDirty()),
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

        const Text('Youtube', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
        const SizedBox(height: 8),
        _AppTextField(controller: _youtubeController, hint: 'Enter Restaurant Youtube link', keyboardType: TextInputType.url, onChanged: (_) => _markDirty()),
        const SizedBox(height: 18),

        const Text('Tiktok', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
        const SizedBox(height: 8),
        _AppTextField(controller: _tiktokController, hint: 'Enter Restaurant Tiktok link', keyboardType: TextInputType.url, onChanged: (_) => _markDirty()),
        const SizedBox(height: 18),

        const Text('Google Review', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
        const SizedBox(height: 8),
        _AppTextField(controller: _googleReviewController, hint: 'Enter Restaurant Google Review link', keyboardType: TextInputType.url, onChanged: (_) => _markDirty()),
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
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
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
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          ],
        ),
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
