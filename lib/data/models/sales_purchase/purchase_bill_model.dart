class PurchaseBillSupplier {
  final String id;
  final String supplierName;

  const PurchaseBillSupplier({required this.id, required this.supplierName});

  factory PurchaseBillSupplier.fromJson(Map<String, dynamic> json) {
    return PurchaseBillSupplier(id: json['id'].toString(), supplierName: json['supplierName'] as String? ?? '');
  }
}

/// A supplier bill, backed by `GET /api/purchase-bill`. Only models the
/// fields the Purchase Bills list row renders, plus the extra ids needed to
/// resend `UpdatePurchaseBillDTO`'s required `customerId`/`paymentMethodId`
/// on edit — the response shape for those isn't documented in Swagger, so
/// they're parsed defensively (a possible flat `*Id` field or an embedded
/// object) and fall back to `null` rather than guessing.
class PurchaseBill {
  final String id;
  final DateTime date;
  final String billNo;
  final double amount;
  final String purchaseStatus;
  final String paymentType;
  final PurchaseBillSupplier? supplier;
  final String? customerId;
  final String? customerName;
  final String? paymentMethodId;
  final String? paymentMethodName;
  final String? imageId;
  final String? imageUrl;

  const PurchaseBill({
    required this.id,
    required this.date,
    required this.billNo,
    required this.amount,
    required this.purchaseStatus,
    required this.paymentType,
    this.supplier,
    this.customerId,
    this.customerName,
    this.paymentMethodId,
    this.paymentMethodName,
    this.imageId,
    this.imageUrl,
  });

  factory PurchaseBill.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];
    final paymentMethod = json['paymentMethod'];
    // Same "flat media id on create, nested media object when expanded"
    // shape as Dish's `dishPhoto`/Combo's `comboPhoto` — the create DTO
    // field is `imageId` rather than `image`, so the response key isn't
    // confirmed; accept either.
    final rawImage = json['image'] ?? json['imageId'];
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
      customerId: (json['customerId'] ?? (customer is Map ? customer['id'] : null))?.toString(),
      customerName: customer is Map ? customer['customerName'] as String? : null,
      paymentMethodId: (json['paymentMethodId'] ?? (paymentMethod is Map ? paymentMethod['id'] : null))?.toString(),
      paymentMethodName: paymentMethod is Map ? paymentMethod['name'] as String? : null,
      imageId: switch (rawImage) {
        String s => s,
        Map<String, dynamic> m => m['id']?.toString(),
        _ => null,
      },
      imageUrl: rawImage is Map<String, dynamic> ? rawImage['url'] as String? : null,
    );
  }
}
