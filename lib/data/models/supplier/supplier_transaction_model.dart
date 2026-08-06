/// A supplier ledger entry (backend: `/api/supplier-transaction`). The
/// response shape isn't documented in Swagger beyond the create/update
/// DTOs, so `paymentMethodName` is parsed defensively from a possible
/// embedded object and falls back to null (the screen then looks the name
/// up locally from the already-fetched payment-method list).
class SupplierTransaction {
  final String id;
  final String supplierId;
  final DateTime? date;
  final String particulars;
  final double? toReceived;
  final double? toPay;
  final String paymentMethodId;
  final String? paymentMethodName;
  final double totalPayment;
  final String? remarks;

  const SupplierTransaction({
    required this.id,
    required this.supplierId,
    this.date,
    required this.particulars,
    this.toReceived,
    this.toPay,
    required this.paymentMethodId,
    this.paymentMethodName,
    required this.totalPayment,
    this.remarks,
  });

  factory SupplierTransaction.fromJson(Map<String, dynamic> json) {
    final paymentMethod = json['paymentMethod'];
    return SupplierTransaction(
      id: json['id'].toString(),
      supplierId: json['supplierId']?.toString() ?? '',
      date: DateTime.tryParse((json['date'] ?? '').toString()),
      particulars: json['particulars'] as String? ?? '',
      toReceived: (json['toReceived'] as num?)?.toDouble(),
      toPay: (json['toPay'] as num?)?.toDouble(),
      paymentMethodId: (json['paymentMethodId'] ?? (paymentMethod is Map ? paymentMethod['id'] : null))?.toString() ?? '',
      paymentMethodName: paymentMethod is Map ? paymentMethod['name'] as String? : null,
      totalPayment: (json['totalPayment'] as num?)?.toDouble() ?? 0,
      remarks: json['remarks'] as String?,
    );
  }
}
