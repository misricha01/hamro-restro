class SalesTransactionPayment {
  final String id;
  final String paymentMethodName;
  final double amount;

  const SalesTransactionPayment({required this.id, required this.paymentMethodName, required this.amount});

  factory SalesTransactionPayment.fromJson(Map<String, dynamic> json) {
    return SalesTransactionPayment(
      id: json['id'].toString(),
      paymentMethodName: json['paymentMethodName'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
    );
  }
}

/// A checkout record (paid, partial or pending), backed by
/// `GET /api/sales-transaction`. Only models the summary fields the Sales
/// Invoice list row renders — the nested `orders`/dish-item breakdown isn't
/// parsed until a detail screen needs it.
class SalesTransaction {
  final String id;
  final DateTime createdAt;
  final String invoiceNumber;
  final String checkoutStatus;
  final String? tableName;
  final String? customerName;
  final String? assignedStaffName;
  final int noOfGuests;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final List<SalesTransactionPayment> payments;

  const SalesTransaction({
    required this.id,
    required this.createdAt,
    required this.invoiceNumber,
    required this.checkoutStatus,
    this.tableName,
    this.customerName,
    this.assignedStaffName,
    required this.noOfGuests,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.payments,
  });

  factory SalesTransaction.fromJson(Map<String, dynamic> json) {
    return SalesTransaction(
      id: json['id'].toString(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      checkoutStatus: json['checkoutStatus'] as String? ?? 'pending',
      tableName: json['tableName'] as String?,
      customerName: json['customerName'] as String?,
      assignedStaffName: json['assignedStaffName'] as String?,
      noOfGuests: (json['noOfGuests'] as num?)?.toInt() ?? 0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '') ?? 0,
      paidAmount: double.tryParse(json['paidAmount']?.toString() ?? '') ?? 0,
      dueAmount: double.tryParse(json['dueAmount']?.toString() ?? '') ?? 0,
      payments: (json['payments'] as List<dynamic>? ?? [])
          .map((e) => SalesTransactionPayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
