/// Aggregated stats backing the Analytics "Overview" tab (backend:
/// `GET /api/dashboard`). Only models the scalar fields the UI
/// currently renders — `weeklySales`, `monthlyRevenue`, `totalOngoingOrders`
/// and the top-selling/customer/recent-orders lists are left unparsed until
/// their item shape (and a use for them) is known.
class DashboardOverview {
  final double totalRevenue;
  final double totalPurchase;
  final double totalIncome;
  final int totalOrders;
  final int totalCustomers;

  const DashboardOverview({
    required this.totalRevenue,
    required this.totalPurchase,
    required this.totalIncome,
    required this.totalOrders,
    required this.totalCustomers,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalPurchase: (json['totalPurchase'] as num?)?.toDouble() ?? 0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
    );
  }
}
