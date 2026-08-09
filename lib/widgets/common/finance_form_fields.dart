import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Shared form building blocks for Finance "entry" screens (Add Income, Add
/// Expense, Add Purchase, Payment In / Payment Out) so every quick-action
/// form renders identical fields instead of duplicate UI.

class FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const FieldLabel({super.key, required this.label, required this.required});

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

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final String? prefix;
  final Widget? prefixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final double borderRadius;
  final int maxLines;
  final int? minLines;

  const AppTextField({
    super.key,
    this.controller,
    required this.hint,
    this.prefix,
    this.prefixIcon,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.borderRadius = 10,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        prefixText: prefix == null ? null : '$prefix   ',
        prefixStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppTheme.accent)),
        errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppTheme.cancelled)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppTheme.cancelled)),
      ),
    );
  }
}

class SelectField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;
  final String? errorText;

  const SelectField({
    super.key,
    required this.hint,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: errorText != null ? AppTheme.cancelled : AppTheme.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(color: value != null ? AppTheme.textPrimary : AppTheme.textSecondary, decoration: TextDecoration.none),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(errorText!, style: const TextStyle(color: AppTheme.cancelled, fontSize: 12, decoration: TextDecoration.none)),
          ),
        ],
      ],
    );
  }
}

class UploadBox extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? previewUrl;

  const UploadBox({super.key, required this.label, required this.onTap, this.previewUrl});

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

class TwoWaySegment extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final ValueChanged<bool> onChanged;

  const TwoWaySegment({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: isLeftSelected ? AppTheme.primary : AppTheme.surface,
                child: Text(
                  leftLabel,
                  style: TextStyle(
                    color: isLeftSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: !isLeftSelected ? AppTheme.primary : AppTheme.surface,
                child: Text(
                  rightLabel,
                  style: TextStyle(
                    color: !isLeftSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThreeWaySegment extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ThreeWaySegment({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: selected ? AppTheme.primary : AppTheme.surface,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A payment/account method offered by [PaymentMethodChipGroup] (Cash,
/// Fonepay, Card, Nepal Pay, Bank Transfer, ...).
class PaymentMethod {
  final String code;
  final String label;
  const PaymentMethod(this.code, this.label);
}

class PaymentMethodChip extends StatelessWidget {
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PaymentMethodChip({
    super.key,
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? AppTheme.cancelled : AppTheme.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(6)),
                  child: Text(code, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(color: AppTheme.cancelled, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }
}

/// Default "Cash / Fonepay / Card / Nepal Pay / Bank Transfer" set shared by
/// every Finance entry screen that asks for a payment account.
const List<PaymentMethod> kDefaultPaymentMethods = [
  PaymentMethod('C', 'Cash'),
  PaymentMethod('F', 'Fonepay'),
  PaymentMethod('C', 'Card'),
  PaymentMethod('N', 'Nepal Pay'),
  PaymentMethod('BT', 'Bank Transfer'),
];

/// Wraps [PaymentMethod] options into the 3-per-row chip grid used by Add
/// Income / Add Expense / Payment In / Payment Out.
class PaymentMethodChipGroup extends StatelessWidget {
  final List<PaymentMethod> methods;
  final String? selected;
  final ValueChanged<String> onSelected;

  const PaymentMethodChipGroup({
    super.key,
    this.methods = kDefaultPaymentMethods,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final chipWidth = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: methods.map((method) {
            final isSelected = selected == method.label;
            return SizedBox(
              width: chipWidth,
              child: PaymentMethodChip(
                code: method.code,
                label: method.label,
                selected: isSelected,
                onTap: () => onSelected(method.label),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// "Enter Customer/Staff/Supplier Name" search field shared by every Finance
/// entry screen's Parties section.
class PartySearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const PartySearchField({super.key, required this.controller, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        suffixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
      ),
    );
  }
}

/// Generic "search + list + optional add-new action" bottom sheet shared by
/// every Finance picker (Select Modes, Select Settlement Account, Select
/// Account, ...) so each dropdown-style field reuses one sheet instead of a
/// bespoke implementation per picker.
class SearchSelectSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? countLabel;
  final String? actionLabel;
  final Future<String?> Function(BuildContext context)? onAction;

  const SearchSelectSheet({
    super.key,
    required this.title,
    required this.items,
    this.countLabel,
    this.actionLabel,
    this.onAction,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> items,
    String? countLabel,
    String? actionLabel,
    Future<String?> Function(BuildContext context)? onAction,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchSelectSheet(title: title, items: items, countLabel: countLabel, actionLabel: actionLabel, onAction: onAction),
    );
  }

  @override
  State<SearchSelectSheet> createState() => _SearchSelectSheetState();
}

class _SearchSelectSheetState extends State<SearchSelectSheet> {
  final TextEditingController _searchController = TextEditingController();
  late final List<String> _items = List.of(widget.items);

  List<String> get _filtered {
    if (_searchController.text.isEmpty) return _items;
    return _items.where((i) => i.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search here',
                          hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : GestureDetector(
                                  onTap: () => setState(() => _searchController.clear()),
                                  child: const Icon(Icons.close, color: AppTheme.cancelled, size: 20),
                                ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                              child: Text(item, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                            ),
                          );
                        },
                      ),
                    ),
                    if (widget.countLabel != null) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text('${widget.countLabel} : ${_items.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
                      ),
                    ],
                    if (widget.actionLabel != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = await widget.onAction?.call(context);
                            if (name != null && context.mounted) {
                              setState(() => _items.add(name));
                              Navigator.pop(context, name);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: Text(widget.actionLabel!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                  ),
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

/// Plain "title + close button + tappable list" bottom sheet, no search bar
/// or footer action — used by pickers whose option list is always short
/// (Select Parent, Select Group) so it stays visually lighter than
/// [SearchSelectSheet].
class SimpleListSheet extends StatelessWidget {
  final String title;
  final List<String> items;

  const SimpleListSheet({super.key, required this.title, required this.items});

  static Future<String?> show(BuildContext context, {required String title, required List<String> items}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SimpleListSheet(title: title, items: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context, item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                              child: Text(item, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                  ),
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

/// "YYYY-MM-DD" date field with a calendar icon, opening [showDatePicker] on
/// tap. Shared by every Finance entry screen's Date field.
class AppDateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const AppDateField({super.key, required this.date, required this.onTap});

  static String format(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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
            Expanded(child: Text(format(date), style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none))),
            const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Flag + country-code + number field shared by every screen that collects a
/// contact number (Restaurant Details, Invoice Setting, ...) instead of each
/// one hand-rolling its own flag/code/divider row.
class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String flagEmoji;
  final String countryCode;
  final ValueChanged<String>? onChanged;

  const PhoneField({super.key, required this.controller, this.flagEmoji = '🇳🇵', this.countryCode = '+977', this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flagEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(countryCode, style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.textSecondary),
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
