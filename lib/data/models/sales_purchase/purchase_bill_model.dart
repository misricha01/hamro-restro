class PurchaseBillSupplier {
  final String id;
  final String supplierName;

  const PurchaseBillSupplier({required this.id, required this.supplierName});

  factory PurchaseBillSupplier.fromJson(Map<String, dynamic> json) {
    return PurchaseBillSupplier(id: json['id'].toString(), supplierName: json['supplierName'] as String? ?? '');
  }
}

/// A supplier bill, backed by `GET /api/purchase-bill`. Only models the
/// fields the Purchase Bills list row renders.
class PurchaseBill {
  final String id;
  final DateTime date;
  final String billNo;
  final double amount;
  final String purchaseStatus;
  final String paymentType;
  final PurchaseBillSupplier? supplier;

  const PurchaseBill({
    required this.id,
    required this.date,
    required this.billNo,
    required this.amount,
    required this.purchaseStatus,
    required this.paymentType,
    this.supplier,
  });

  factory PurchaseBill.fromJson(Map<String, dynamic> json) {
    return PurchaseBill(
      id: json['id'].toString(),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      billNo: json['billNo'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      purchaseStatus: json['purchaseStatus'] as String? ?? 'pending',
      // Unconfirmed whether the backend sends `payment_type` (snake_case,
      // inconsistent with every other field here) or `paymentType` — accept
      // either rather than guessing and silently losing the value.
      paymentType: (json['payment_type'] ?? json['paymentType']) as String? ?? '',
      supplier: json['supplier'] == null ? null : PurchaseBillSupplier.fromJson(json['supplier'] as Map<String, dynamic>),
    );
  }
}
