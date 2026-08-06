import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/orders/order_model.dart';
import '../../providers/order_provider.dart';

/// "Cabin 1 - KOT" style cart/confirmation screen reached from Quick
/// Billing's More menu or "Continue Order" bar. Operates on the same
/// cart-item-shaped maps produced by [CustomizeDishSheet] /
/// [AddCustomItemSheet] (`dishName`, `quantity`, `variant`, `addOns`,
/// `remarks`, `totalPrice`).
///
/// "Confirm Order" / "Confirm & Print" call `POST /api/order` via
/// [OrderProvider.placeOrder]. Items picked from the real catalog (via
/// [DishProvider], carrying a `dishId` in their cart map) are sent as
/// `dishId` + `quantity`; items added via `AddCustomItemSheet` have no
/// catalog id and are sent as custom line items (`customDishName`/
/// `customDishQty`/`customDishRate`).
class OrderCartScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> cart;

  /// The table this order is for. `null` means the caller has no real table
  /// context (e.g. Take Away) — confirming shows an error in that case.
  final String? tableId;

  const OrderCartScreen({super.key, required this.title, required this.cart, this.tableId});

  @override
  State<OrderCartScreen> createState() => _OrderCartScreenState();
}

class _OrderCartScreenState extends State<OrderCartScreen> {
  late final List<Map<String, dynamic>> _cart = List.of(widget.cart);
  final _guestCountController = TextEditingController();
  final _kotRemarksController = TextEditingController();

  @override
  void dispose() {
    _guestCountController.dispose();
    _kotRemarksController.dispose();
    super.dispose();
  }

  int get _totalQty => _cart.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
  double get _totalAmount => _cart.fold(0.0, (sum, item) => sum + (item['totalPrice'] as double? ?? 0));

  void _clearAll() => setState(() => _cart.clear());

  void _updateQty(int index, int delta) {
    setState(() {
      final item = _cart[index];
      final qty = (item['quantity'] as int? ?? 1);
      final unitPrice = qty == 0 ? 0.0 : (item['totalPrice'] as double? ?? 0) / qty;
      final newQty = (qty + delta).clamp(1, 999);
      _cart[index] = {...item, 'quantity': newQty, 'totalPrice': unitPrice * newQty};
    });
  }

  Future<void> _placeOrder({required bool andPrint}) async {
    final messenger = ScaffoldMessenger.of(context);
    final tableId = widget.tableId;
    if (tableId == null) {
      messenger.showSnackBar(const SnackBar(content: Text('No table selected for this order.')));
      return;
    }

    final provider = context.read<OrderProvider>();
    final items = _cart.map((item) {
      final quantity = item['quantity'] as int? ?? 1;
      final dishId = item['dishId'] as String?;
      if (dishId != null) {
        return NewOrderItem.dish(dishId: dishId, quantity: quantity);
      }
      final totalPrice = item['totalPrice'] as double? ?? 0;
      final unitPrice = quantity == 0 ? 0.0 : totalPrice / quantity;
      return NewOrderItem.custom(
        name: item['dishName'] as String? ?? 'Item',
        quantity: quantity,
        rate: unitPrice,
      );
    }).toList();

    final result = await provider.placeOrder(tableId: tableId, items: items);
    if (!mounted) return;

    if (result != null) {
      messenger.showSnackBar(SnackBar(content: Text(andPrint ? 'Order confirmed & sent to print' : 'Order confirmed')));
      Navigator.pop(context, <Map<String, dynamic>>[]);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(provider.placeOrderErrorMessage ?? 'Failed to place order')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _cart);
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _cart),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.chevron_left, color: AppTheme.accent),
              ),
            ),
          ),
          title: Text(
            '${widget.title} - KOT',
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                color: AppTheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
                onSelected: (value) {
                  if (value == 'clear') _clearAll();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'clear', child: Text('Clear All', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('More', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                      SizedBox(width: 4),
                      Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: _cart.isEmpty
              ? const _EmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _PillField(
                                  icon: Icons.person_outline,
                                  child: GestureDetector(
                                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assign customer coming soon'))),
                                    child: const Row(
                                      children: [
                                        Expanded(child: Text('Assign Customer', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
                                        Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _PillField(
                                  icon: Icons.groups_outlined,
                                  child: TextField(
                                    controller: _guestCountController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                                    decoration: const InputDecoration(hintText: 'eg. 5', hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none), border: InputBorder.none, isDense: true),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.cancelled, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text('Cart Items', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                              ),
                              GestureDetector(
                                onTap: _clearAll,
                                child: const Text('Clear All', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Container(
                            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
                            child: Column(
                              children: [
                                for (int i = 0; i < _cart.length; i++) ...[
                                  if (i > 0) const Divider(height: 1, color: AppTheme.divider),
                                  _CartItemTile(item: _cart[i], onIncrement: () => _updateQty(i, 1), onDecrement: () => _updateQty(i, -1)),
                                ],
                                const Divider(height: 1, color: AppTheme.divider),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Text('Total', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                                      const Spacer(),
                                      Text('QTY: $_totalQty', style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                                      const SizedBox(width: 16),
                                      Text('Rs ${_totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _kotRemarksController,
                            style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                            decoration: InputDecoration(
                              hintText: 'Add KOT Remarks',
                              hintStyle: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                              prefixIcon: const Icon(Icons.description_outlined, color: AppTheme.textSecondary, size: 20),
                              filled: true,
                              fillColor: AppTheme.card,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.divider)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accent)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<OrderProvider>(
                      builder: (context, provider, _) {
                        return Container(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                          decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: provider.isPlacing ? null : () => _placeOrder(andPrint: true),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.divider), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  child: const Text('Confirm & Print', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: provider.isPlacing ? null : () => _placeOrder(andPrint: false),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.completed, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  child: provider.isPlacing
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                      : const Text('Confirm Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PillField extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _PillField({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 18),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const _CartItemTile({required this.item, required this.onIncrement, required this.onDecrement});

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  late final _remarksController = TextEditingController(text: widget.item['remarks'] as String? ?? '');

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final quantity = item['quantity'] as int? ?? 1;
    final totalPrice = item['totalPrice'] as double? ?? 0;
    final unitPrice = quantity == 0 ? 0 : totalPrice / quantity;
    final variant = item['variant'] as String?;
    final addOns = (item['addOns'] as List?)?.cast<String>() ?? const [];
    final subtitleParts = [?variant, ...addOns];

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.restaurant_menu, color: AppTheme.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['dishName'] as String? ?? 'Item', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
                    if (subtitleParts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('${subtitleParts.join(', ')} - Rs ${unitPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('Rs ${unitPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32), icon: const Icon(Icons.remove, size: 16, color: AppTheme.textPrimary), onPressed: widget.onDecrement),
                        SizedBox(width: 22, child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none))),
                        IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32), icon: const Icon(Icons.add, size: 16, color: AppTheme.textPrimary), onPressed: widget.onIncrement),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Rs ${totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _remarksController,
                  onChanged: (v) => item['remarks'] = v,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none),
                  decoration: InputDecoration(
                    hintText: 'Add remarks to Dish',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
                    prefixIcon: const Icon(Icons.description_outlined, color: AppTheme.textSecondary, size: 18),
                    filled: true,
                    fillColor: AppTheme.card,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SquareIconButton(icon: Icons.card_giftcard_outlined, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Discount on item coming soon')))),
              const SizedBox(width: 6),
              _SquareIconButton(icon: Icons.shopping_bag_outlined, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Move item coming soon')))),
            ],
          ),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.textSecondary, size: 18),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 90, color: AppTheme.accent.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          const Text('Cart is empty', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none)),
          const SizedBox(height: 6),
          const Text('Add dishes from the menu to build a KOT.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}
