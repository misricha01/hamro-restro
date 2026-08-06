/// Completed/pending/cancelled counts within [OrderDashboard.orderStatusBreakdown].
class OrderStatusBreakdown {
  final int completed;
  final int pending;
  final int cancelled;

  const OrderStatusBreakdown({required this.completed, required this.pending, required this.cancelled});

  factory OrderStatusBreakdown.fromJson(Map<String, dynamic> json) {
    return OrderStatusBreakdown(
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Dine-in specific totals within [OrderDashboard.dineInInsight].
class DineInInsight {
  final int totalOrders;
  final double totalSales;
  final int totalKot;

  const DineInInsight({required this.totalOrders, required this.totalSales, required this.totalKot});

  factory DineInInsight.fromJson(Map<String, dynamic> json) {
    return DineInInsight(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0,
      totalKot: (json['totalKot'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Aggregated stats backing the Order overview (backend:
/// `GET /api/dashboard/order`). Only models the fields the UI currently
/// renders — `topSellingTables` and `salesBySubmenu` are left unparsed until
/// their item shape (and a use for them) is known.
class OrderDashboard {
  final double totalSales;
  final int ordersServed;
  final int totalKot;
  final double averageOrderAmount;
  final OrderStatusBreakdown orderStatusBreakdown;
  final DineInInsight dineInInsight;

  const OrderDashboard({
    required this.totalSales,
    required this.ordersServed,
    required this.totalKot,
    required this.averageOrderAmount,
    required this.orderStatusBreakdown,
    required this.dineInInsight,
  });

  factory OrderDashboard.fromJson(Map<String, dynamic> json) {
    return OrderDashboard(
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0,
      ordersServed: (json['ordersServed'] as num?)?.toInt() ?? 0,
      totalKot: (json['totalKot'] as num?)?.toInt() ?? 0,
      averageOrderAmount: (json['averageOrderAmount'] as num?)?.toDouble() ?? 0,
      orderStatusBreakdown: OrderStatusBreakdown.fromJson(json['orderStatusBreakdown'] as Map<String, dynamic>? ?? const {}),
      dineInInsight: DineInInsight.fromJson(json['dineInInsight'] as Map<String, dynamic>? ?? const {}),
    );
  }
}
