import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DishVariant {
  final String label;
  final double price;
  DishVariant({required this.label, required this.price});
}

class DishAddOn {
  final String name;
  final double price;
  final IconData icon;
  DishAddOn({required this.name, required this.price, required this.icon});
}

class CustomizeDishSheet extends StatefulWidget {
  final String dishName;
  final IconData dishIcon;
  final double basePrice;
  final List<DishVariant> variants;
  final List<DishAddOn> addOns;
  final void Function(Map<String, dynamic> orderData) onAddToCart;

  /// The real catalog dish id, when [dishName] came from [DishProvider]
  /// rather than local dummy data. Threaded into the `onAddToCart` payload
  /// so order placement can send `dishId` instead of a custom line item.
  final String? dishId;

  const CustomizeDishSheet({
    super.key,
    required this.dishName,
    required this.dishIcon,
    required this.basePrice,
    this.variants = const [],
    this.addOns = const [],
    required this.onAddToCart,
    this.dishId,
  });

  static Future<void> show(
      BuildContext context, {
        required String dishName,
        required IconData dishIcon,
        required double basePrice,
        List<DishVariant> variants = const [],
        List<DishAddOn> addOns = const [],
        required void Function(Map<String, dynamic> orderData) onAddToCart,
        String? dishId,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomizeDishSheet(
        dishName: dishName,
        dishIcon: dishIcon,
        basePrice: basePrice,
        variants: variants,
        addOns: addOns,
        onAddToCart: onAddToCart,
        dishId: dishId,
      ),
    );
  }

  @override
  State<CustomizeDishSheet> createState() => _CustomizeDishSheetState();
}

class _CustomizeDishSheetState extends State<CustomizeDishSheet> {
  int _quantity = 1;
  int? _selectedVariantIndex;
  final Set<int> _selectedAddOnIndexes = {};
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.variants.isNotEmpty) _selectedVariantIndex = 0;
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  double get _unitPrice {
    if (widget.variants.isNotEmpty && _selectedVariantIndex != null) {
      return widget.variants[_selectedVariantIndex!].price;
    }
    return widget.basePrice;
  }

  double get _addOnsTotal {
    double total = 0;
    for (final i in _selectedAddOnIndexes) {
      total += widget.addOns[i].price;
    }
    return total;
  }

  double get _totalPrice => (_unitPrice + _addOnsTotal) * _quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Customize Dish',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.card,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: AppTheme.accent, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dish row with quantity counter
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(widget.dishIcon, color: AppTheme.accent, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              widget.dishName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          _QuantityStepper(
                            quantity: _quantity,
                            onDecrement: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                            onIncrement: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),

                    if (widget.variants.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Select Variants',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: widget.variants.asMap().entries.map((entry) {
                          final index = entry.key;
                          final variant = entry.value;
                          final isSelected = _selectedVariantIndex == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedVariantIndex = index),
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: index != widget.variants.length - 1 ? 10 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primary : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primary : AppTheme.divider,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      variant.label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Rs ${variant.price.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white70 : AppTheme.accent,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    if (widget.addOns.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Add-Ons or Extras',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Choose your taste.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.addOns.asMap().entries.map((entry) {
                        final index = entry.key;
                        final addOn = entry.value;
                        final isSelected = _selectedAddOnIndexes.contains(index);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.divider),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(addOn.icon, size: 22, color: AppTheme.textSecondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  addOn.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.textPrimary,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              Text(
                                'Rs ${addOn.price.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedAddOnIndexes.remove(index);
                                    } else {
                                      _selectedAddOnIndexes.add(index);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelected ? Icons.check : Icons.add,
                                        size: 15,
                                        color: isSelected ? Colors.white : AppTheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isSelected ? 'Added' : 'Add',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : AppTheme.primary,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 20),
                    const Text(
                      'Remarks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _remarksController,
                      maxLines: 4,
                      style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                      decoration: InputDecoration(
                        hintText: 'Enter Remarks',
                        hintStyle: const TextStyle(
                          color: AppTheme.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: AppTheme.divider),

            // Bottom bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onAddToCart({
                            'dishName': widget.dishName,
                            'quantity': _quantity,
                            'variant': _selectedVariantIndex != null
                                ? widget.variants[_selectedVariantIndex!].label
                                : null,
                            'addOns': _selectedAddOnIndexes
                                .map((i) => widget.addOns[i].name)
                                .toList(),
                            'remarks': _remarksController.text,
                            'totalPrice': _totalPrice,
                            if (widget.dishId != null) 'dishId': widget.dishId,
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Add to Cart Rs ${_totalPrice.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            decoration: TextDecoration.none,
                          ),
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

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrement,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              decoration: TextDecoration.none,
            ),
          ),
          InkWell(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
