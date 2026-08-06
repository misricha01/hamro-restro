/// A paid/unpaid breakdown within [FinanceDashboard.salesSummary].
class SalesSummaryBucket {
  final int totalOrders;
  final double totalAmount;

  const SalesSummaryBucket({required this.totalOrders, required this.totalAmount});

  factory SalesSummaryBucket.fromJson(Map<String, dynamic> json) {
    return SalesSummaryBucket(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// A payment method's transaction totals within [FinanceDashboard.topPaymentMethods].
class PaymentMethodSummary {
  final String paymentMethodId;
  final String paymentMethodName;
  final int totalTransactions;
  final double totalAmount;

  const PaymentMethodSummary({
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.totalTransactions,
    required this.totalAmount,
  });

  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSummary(
      paymentMethodId: json['paymentMethodId'].toString(),
      paymentMethodName: json['paymentMethodName'] as String? ?? '',
      totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// A single payment record within [FinanceDashboard.recentPayments].
class RecentPayment {
  final String paymentId;
  final double amount;
  final String paymentMethodName;
  final DateTime createdAt;
  final String? tableName;
  final String invoiceNumber;

  const RecentPayment({
    required this.paymentId,
    required this.amount,
    required this.paymentMethodName,
    required this.createdAt,
    this.tableName,
    required this.invoiceNumber,
  });

  factory RecentPayment.fromJson(Map<String, dynamic> json) {
    return RecentPayment(
      paymentId: json['paymentId'].toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMethodName: json['paymentMethodName'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      tableName: json['tableName'] as String?,
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
    );
  }
}

/// Aggregated stats backing the Finance overview (backend:
/// `GET /api/dashboard/finance`). Only models the fields the UI currently
/// renders — `totalPaymentIn`, `totalPaymentOut` and `salesOverview` are left
/// unparsed until a use for them is known.
class FinanceDashboard {
  final double totalSales;
  final double totalPurchase;
  final double totalIncome;
  final double totalExpenses;
  final SalesSummaryBucket paid;
  final SalesSummaryBucket unpaid;
  final List<RecentPayment> recentPayments;
  final List<PaymentMethodSummary> topPaymentMethods;

  const FinanceDashboard({
    required this.totalSales,
    required this.totalPurchase,
    required this.totalIncome,
    required this.totalExpenses,
    required this.paid,
    required this.unpaid,
    required this.recentPayments,
    required this.topPaymentMethods,
  });

  factory FinanceDashboard.fromJson(Map<String, dynamic> json) {
    final summary = json['salesSummary'] as Map<String, dynamic>? ?? const {};
    final recentPayments = json['recentPayments'] as List<dynamic>? ?? const [];
    final topPaymentMethods = json['topPaymentMethods'] as List<dynamic>? ?? const [];
    return FinanceDashboard(
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0,
      totalPurchase: (json['totalPurchase'] as num?)?.toDouble() ?? 0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      paid: SalesSummaryBucket.fromJson(summary['paid'] as Map<String, dynamic>? ?? const {}),
      unpaid: SalesSummaryBucket.fromJson(summary['unpaid'] as Map<String, dynamic>? ?? const {}),
      recentPayments: recentPayments.map((e) => RecentPayment.fromJson(e as Map<String, dynamic>)).toList(),
      topPaymentMethods: topPaymentMethods.map((e) => PaymentMethodSummary.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
