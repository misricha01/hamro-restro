/// A single row from `GET /api/checkout-history` — a fuller audit-trail
/// view of a checkout than `GET /api/checkout/{id}` exposes (adds
/// `tableCharge` on top of the usual bill fields). Response shape wasn't
/// live-verified beyond a 200 during the audit, so every field is parsed
/// defensively with the same nested-object fallbacks used by [Checkout]
/// and [SalesTransaction].
class CheckoutHistoryEntry {
  final String id;
  final String? checkoutId;
  final DateTime createdAt;
  final String checkoutStatus;
  final String? tableName;
  final String? customerName;
  final String? invoiceNumber;
  final double tableCharge;
  final double totalAmount;

  const CheckoutHistoryEntry({
    required this.id,
    this.checkoutId,
    required this.createdAt,
    required this.checkoutStatus,
    this.tableName,
    this.customerName,
    this.invoiceNumber,
    this.tableCharge = 0,
    this.totalAmount = 0,
  });

  factory CheckoutHistoryEntry.fromJson(Map<String, dynamic> json) {
    final checkout = json['checkout'] as Map<String, dynamic>?;
    final table = json['table'] ?? checkout?['table'];
    final customer = json['customer'] ?? checkout?['customer'];
    return CheckoutHistoryEntry(
      id: json['id'].toString(),
      checkoutId: (json['checkoutId'] ?? checkout?['id'])?.toString(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      checkoutStatus: json['checkoutStatus'] as String? ?? checkout?['checkoutStatus'] as String? ?? 'pending',
      tableName: json['tableName'] as String? ?? (table is Map<String, dynamic> ? table['tableName'] as String? : null),
      customerName: json['customerName'] as String? ?? (customer is Map<String, dynamic> ? customer['customerName'] as String? : null),
      invoiceNumber: json['invoiceNumber'] as String? ?? checkout?['invoiceNumber'] as String?,
      tableCharge: double.tryParse(json['tableCharge']?.toString() ?? '') ?? 0,
      totalAmount: double.tryParse((json['totalAmount'] ?? checkout?['totalAmount'])?.toString() ?? '') ?? 0,
    );
  }
}
