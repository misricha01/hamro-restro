import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AddDishScreen extends StatefulWidget {
  const AddDishScreen({super.key});

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _hsCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedSubMenu;
  String? _selectedCategory;
  String? _selectedDishType;
  String? _selectedKitchen;
  bool _multiplePriceEnabled = false;

  double get _listedPrice {
    final actual = double.tryParse(_priceController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    return (actual - discount).clamp(0, double.infinity);
  }

  double get _grossProfit => _listedPrice; // placeholder calc, adjust when cost data is available

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _hsCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text(
          'Add Dish',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Dish Name', required: true),
                    const SizedBox(height: 8),
                    _StyledTextField(
                      controller: _nameController,
                      hintText: 'Enter Dish Name',
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Sub-Menu', required: true),
                              const SizedBox(height: 8),
                              _DropdownField(
                                value: _selectedSubMenu,
                                hint: 'Select Sub-Menu',
                                items: const ['Lunch', 'Dinner', 'Beverages'],
                                onChanged: (v) => setState(() => _selectedSubMenu = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Category', required: true),
                              const SizedBox(height: 8),
                              _DropdownField(
                                value: _selectedCategory,
                                hint: 'Select Category',
                                items: const ['Starter', 'Main Course', 'Dessert'],
                                onChanged: (v) => setState(() => _selectedCategory = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Actual Price', required: true),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                controller: _priceController,
                                hintText: 'Rs.',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Discount'),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                controller: _discountController,
                                hintText: 'Rs.',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Listed Price: Rs ${_listedPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gross Profit: Rs ${_grossProfit.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.completed,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO: Open stock consumption setup
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.textSecondary),
                        label: const Text(
                          'Setup Stock Consumption',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _multiplePriceEnabled,
                                  activeColor: AppTheme.primary,
                                  onChanged: (v) => setState(() => _multiplePriceEnabled = v ?? false),
                                ),
                                const Text(
                                  'Multiple Price?',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // TODO: Open Add Variants flow
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Add Variants',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.chevron_right, color: AppTheme.textPrimary, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _SectionHeader(title: 'Image'),
                    const SizedBox(height: 12),
                    _FieldLabel(text: 'Dish Photo'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        // TODO: pick/upload dish photo
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.cloud_upload_outlined, color: AppTheme.textSecondary, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Tap here to select or upload photos',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _SectionHeader(title: 'Other Details'),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Dish Type'),
                              const SizedBox(height: 8),
                              _DropdownField(
                                value: _selectedDishType,
                                hint: 'Select type',
                                items: const ['Veg', 'Non-Veg', 'Vegan'],
                                onChanged: (v) => setState(() => _selectedDishType = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Kitchen'),
                              const SizedBox(height: 8),
                              _DropdownField(
                                value: _selectedKitchen,
                                hint: 'Select',
                                items: const ['Main Kitchen', 'Bar', 'Bakery'],
                                onChanged: (v) => setState(() => _selectedKitchen = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel(text: 'Add-Ons or Extras'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        // TODO: Open Add-Ons management flow
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Add-Ons - Click Here',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.chevron_right, color: AppTheme.textPrimary, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'H.S Code'),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                controller: _hsCodeController,
                                hintText: 'Enter HS Code eg. 20.5...',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Preparation Time'),
                              const SizedBox(height: 8),
                              const _PreparationTimeField(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _SectionHeader(title: 'Description'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppTheme.divider)),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.format_bold, color: AppTheme.textSecondary, size: 18),
                                SizedBox(width: 12),
                                Icon(Icons.format_italic, color: AppTheme.textSecondary, size: 18),
                                SizedBox(width: 12),
                                Icon(Icons.format_underline, color: AppTheme.textSecondary, size: 18),
                                SizedBox(width: 12),
                                Icon(Icons.format_clear, color: AppTheme.textSecondary, size: 18),
                                SizedBox(width: 12),
                                Icon(Icons.format_align_left, color: AppTheme.textSecondary, size: 18),
                                SizedBox(width: 12),
                                Icon(Icons.format_align_center, color: AppTheme.textSecondary, size: 18),
                                SizedBox(width: 12),
                                Icon(Icons.format_align_right, color: AppTheme.textSecondary, size: 18),
                                Spacer(),
                                Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
                              ],
                            ),
                          ),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 5,
                            style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                            decoration: const InputDecoration(
                              hintText: 'Write dish description...',
                              hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                10 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
                      onPressed: () {
                        // TODO: Save dish via API
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
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
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppTheme.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: AppTheme.divider)),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel({required this.text, this.required = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          decoration: TextDecoration.none,
        ),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 1,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accent),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
          dropdownColor: AppTheme.card,
          style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PreparationTimeField extends StatelessWidget {
  const _PreparationTimeField();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: Text('0', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                ),
                Text('hr', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(':', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: Text('00', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                ),
                Text('m', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}