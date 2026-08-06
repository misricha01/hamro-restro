import 'table_model.dart';

/// A single line item sent to `POST /api/order`. Use [NewOrderItem.dish]
/// for a real catalog dish (real `dishId`) or [NewOrderItem.custom] for an
/// ad-hoc item with no catalog entry — the backend distinguishes them by
/// which fields are present, not by a type flag.
class NewOrderItem {
  final String? dishId;
  final int quantity;
  final String? customDishName;
  final int? customDishQty;
  final double? customDishRate;
  final String dishStatus;

  const NewOrderItem({
    this.dishId,
    required this.quantity,
    this.customDishName,
    this.customDishQty,
    this.customDishRate,
    this.dishStatus = 'pending',
  });

  factory NewOrderItem.dish({required String dishId, required int quantity, String dishStatus = 'pending'}) {
    return NewOrderItem(dishId: dishId, quantity: quantity, dishStatus: dishStatus);
  }

  factory NewOrderItem.custom({
    required String name,
    required int quantity,
    required double rate,
    String dishStatus = 'pending',
  }) {
    return NewOrderItem(
      quantity: quantity,
      customDishName: name,
      customDishQty: quantity,
      customDishRate: rate,
      dishStatus: dishStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (dishId != null) 'dishId': dishId,
      'quantity': quantity,
      if (customDishName != null) 'customDishName': customDishName,
      if (customDishQty != null) 'customDishQty': customDishQty,
      if (customDishRate != null) 'customDishRate': customDishRate,
      'dishStatus': dishStatus,
    };
  }
}

/// Result of a successful `POST /api/order` — the response only echoes back
/// ids, not a full [Order], so callers refetch via [OrderProvider.fetchOrders]
/// if they need the full entity.
class PlacedOrder {
  final String orderId;
  final String kotId;
  final String activitySessionId;

  const PlacedOrder({required this.orderId, required this.kotId, required this.activitySessionId});

  factory PlacedOrder.fromJson(Map<String, dynamic> json) {
    return PlacedOrder(
      orderId: json['orderId'].toString(),
      kotId: json['kotId'].toString(),
      activitySessionId: json['activitySessionId']?.toString() ?? '',
    );
  }
}

class AssignedStaff {
  final String id;
  final String fullname;
  final String? email;

  const AssignedStaff({required this.id, required this.fullname, this.email});

  factory AssignedStaff.fromJson(Map<String, dynamic> json) {
    return AssignedStaff(id: json['id'].toString(), fullname: json['fullname'] as String? ?? '', email: json['email'] as String?);
  }
}

class OrderDish {
  final String id;
  final String dishName;

  const OrderDish({required this.id, required this.dishName});

  factory OrderDish.fromJson(Map<String, dynamic> json) {
    return OrderDish(id: json['id'].toString(), dishName: json['dishName'] as String? ?? '');
  }
}

class OrderItem {
  final String id;
  final String? customDishName;
  final int quantity;
  final String? customDishTotal;
  final String dishStatus;
  final OrderDish? dish;

  const OrderItem({
    required this.id,
    this.customDishName,
    required this.quantity,
    this.customDishTotal,
    required this.dishStatus,
    this.dish,
  });

  String get displayName => customDishName ?? dish?.dishName ?? 'Item';

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      customDishName: json['customDishName'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      customDishTotal: json['customDishTotal']?.toString(),
      dishStatus: json['dishStatus'] as String? ?? 'pending',
      dish: json['dish'] == null ? null : OrderDish.fromJson(json['dish'] as Map<String, dynamic>),
    );
  }
}

class Kot {
  final String id;
  final String kotNumber;
  final String orderStatus;
  final List<OrderItem> items;

  const Kot({required this.id, required this.kotNumber, required this.orderStatus, required this.items});

  factory Kot.fromJson(Map<String, dynamic> json) {
    return Kot(
      id: json['id'].toString(),
      kotNumber: json['kotNumber']?.toString() ?? '',
      orderStatus: json['orderStatus'] as String? ?? 'pending',
      items: (json['items'] as List<dynamic>? ?? []).map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class Order {
  final String id;
  final DateTime createdAt;
  final AssignedStaff? assignedStaff;
  final RestaurantTable? table;
  final List<Kot> kots;

  const Order({required this.id, required this.createdAt, this.assignedStaff, this.table, required this.kots});

  int get itemCount => kots.fold(0, (sum, kot) => sum + kot.items.fold(0, (s, i) => s + i.quantity));

  /// True if any KOT on this order is still pending — used to badge the
  /// order card, since the API doesn't expose a single order-level status.
  bool get isPending => kots.any((kot) => kot.orderStatus.toLowerCase() == 'pending');

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      assignedStaff: json['assignedStaff'] == null ? null : AssignedStaff.fromJson(json['assignedStaff'] as Map<String, dynamic>),
      table: json['table'] == null ? null : RestaurantTable.fromJson(json['table'] as Map<String, dynamic>),
      kots: (json['kots'] as List<dynamic>? ?? []).map((e) => Kot.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
