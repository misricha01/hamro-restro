import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/delivery_rider.dart';
import '../create_dish/add_dish_screen.dart' show ImageSourceSheet;

/// "Add Rider" form, reached from the Delivery Riders screen's "Add New
/// Rider" button. Mirrors the field styling used across the Customer/Staff
/// "Create Users" forms (label + bordered field, phone field with country
/// code, bottom Reset/Save bar).
class AddRiderScreen extends StatefulWidget {
  const AddRiderScreen({super.key});

  @override
  State<AddRiderScreen> createState() => _AddRiderScreenState();
}

class _AddRiderScreenState extends State<AddRiderScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  String? _imageSource;
  VehicleType? _vehicleType;

  bool _isDirty = false;
  bool _nameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _pickImage() async {
    final result = await ImageSourceSheet.show(context, includeLibrary: false);
    if (result != null) {
      setState(() {
        _imageSource = result;
        _isDirty = true;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _phoneController.clear();
      _vehicleNumberController.clear();
      _imageSource = null;
      _vehicleType = null;
      _isDirty = false;
      _nameError = false;
    });
  }

  void _saveRider() {
    setState(() => _nameError = _nameController.text.trim().isEmpty);
    if (_nameError) return;

    final rider = DeliveryRider(
      name: _nameController.text.trim(),
      imageSource: _imageSource,
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      vehicleNumber: _vehicleNumberController.text.trim().isEmpty ? null : _vehicleNumberController.text.trim(),
      vehicleType: _vehicleType,
    );
    Navigator.pop(context, rider);
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
          'Add Rider',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                // TODO: Integrate staff list to import rider details.
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, color: AppTheme.accent, size: 18),
                  SizedBox(width: 6),
                  Text('Import from Staff', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _FieldLabel(label: 'Rider Name', required: true),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _nameController,
            hint: 'Please enter the rider name',
            errorText: _nameError ? 'Rider Name is required' : null,
            onChanged: (v) {
              _markDirty();
              if (_nameError && v.trim().isNotEmpty) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Rider Image', required: false),
          const SizedBox(height: 8),
          _UploadBox(
            label: _imageSource == null ? 'Tap here to select or upload photos' : 'Selected via $_imageSource',
            onTap: _pickImage,
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Phone number', required: false),
          const SizedBox(height: 8),
          _PhoneField(controller: _phoneController, onChanged: (_) => _markDirty()),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Vehicle Number', required: false),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _vehicleNumberController,
            hint: 'Enter vehicle number',
            keyboardType: TextInputType.text,
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 20),

          const _FieldLabel(label: 'Vehicle Type', required: false),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _VehicleTypeChip(
                  icon: Icons.two_wheeler_outlined,
                  label: 'Two Wheeler',
                  selected: _vehicleType == VehicleType.twoWheeler,
                  onTap: () => setState(() {
                    _vehicleType = VehicleType.twoWheeler;
                    _isDirty = true;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VehicleTypeChip(
                  icon: Icons.directions_car_filled_outlined,
                  label: 'Four Wheeler',
                  selected: _vehicleType == VehicleType.fourWheeler,
                  onTap: () => setState(() {
                    _vehicleType = VehicleType.fourWheeler;
                    _isDirty = true;
                  }),
                ),
              ),
            ],
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
                onPressed: _isDirty ? _resetForm : () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  _isDirty ? 'Reset' : 'Back',
                  style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _saveRider,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Rider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleTypeChip({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withValues(alpha: 0.14) : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppTheme.accent : AppTheme.textPrimary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(color: selected ? AppTheme.accent : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
            ),
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
                hintText: 'Enter phone number',
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
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cancelled)),
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
