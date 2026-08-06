/// A supplier (backend: `/api/supplier`). Confirmed against a real
/// `GET /api/supplier` response — `restaurantId`, `updatedAt`, `deletedAt`,
/// `creatorId` are left unparsed since the UI doesn't need them yet.
/// `transactions` is parsed defensively (it came back as an array on GET,
/// but the create validator rejected an array with "transactions must be a
/// string") — left out of create/update requests until that's resolved.
class Supplier {
  final String id;
  final String supplierName;
  final String phoneNumber;
  final String? address;
  final String? remarks;
  final bool status;
  final DateTime createdAt;
  final List<String> transactions;

  const Supplier({
    required this.id,
    required this.supplierName,
    required this.phoneNumber,
    this.address,
    this.remarks,
    this.status = true,
    required this.createdAt,
    this.transactions = const [],
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    final transactions = json['transactions'] as List<dynamic>? ?? const [];
    return Supplier(
      id: json['id'].toString(),
      supplierName: json['supplierName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String?,
      remarks: json['remarks'] as String?,
      status: json['status'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      transactions: transactions.map((e) => e.toString()).toList(),
    );
  }
}
