/// A payment entry recorded against a [Checkout]. Same shape as
/// `SalesTransactionPayment` (`GET /api/sales-transaction`) — see
/// [Checkout] for why the two are believed to read the same underlying
/// entity.
class CheckoutPayment {
  final String? id;
  final String? paymentMethodId;
  final String? paymentMethodName;
  final double amount;

  const CheckoutPayment({this.id, this.paymentMethodId, this.paymentMethodName, required this.amount});

  factory CheckoutPayment.fromJson(Map<String, dynamic> json) {
    final method = json['paymentMethod'];
    return CheckoutPayment(
      id: json['id']?.toString(),
      paymentMethodId: (json['paymentMethodId'] ?? (method is Map ? method['id'] : null))?.toString(),
      paymentMethodName: json['paymentMethodName'] as String? ?? (method is Map<String, dynamic> ? method['name'] as String? : null),
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
    );
  }
}

/// A bill/checkout for a table's active order. Backend: `POST /api/checkout`
/// ("Generates bill and initiates Checkout only") computes and returns this
/// from the table's current order — there's no client-side pricing data to
/// build a bill from ([OrderItem] carries no price at all). `PATCH
/// /api/checkout/{id}` ("Complete Checkout procedure") then records
/// payments and finalizes it.
///
/// Field shape confirmed live against `GET /api/checkout/{id}` (2026-08-09):
/// `totalAmount` is always present; `dueAmount` is only present while a
/// balance remains (`pending`/`partial`) — it comes back `null` both before
/// any payment and once the balance reaches zero (`completed`), rather than
/// `"0.00"`. There is **no `paidAmount` field on this endpoint at all**
/// (unlike the near-identical `SalesTransaction` model on
/// `GET /api/sales-transaction`, which does have one) — both are derived
/// here from summing [payments] instead of trusted to the wire.
class Checkout {
  final String id;
  final String? tableId;
  final String? tableName;
  final String checkoutStatus;
  final String? invoiceNumber;
  final int noOfGuests;
  final String? customerId;
  final String? customerName;
  final String? companyName;
  final String? companyPan;
  final String? discountType;
  final double discount;
  final String? remarks;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final List<CheckoutPayment> payments;

  const Checkout({
    required this.id,
    this.tableId,
    this.tableName,
    required this.checkoutStatus,
    this.invoiceNumber,
    this.noOfGuests = 0,
    this.customerId,
    this.customerName,
    this.companyName,
    this.companyPan,
    this.discountType,
    this.discount = 0,
    this.remarks,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.dueAmount = 0,
    this.payments = const [],
  });

  factory Checkout.fromJson(Map<String, dynamic> json) {
    final table = json['table'];
    final customer = json['customer'];
    final totalAmount = double.tryParse(json['totalAmount']?.toString() ?? '') ?? 0;
    final payments = (json['payments'] as List<dynamic>? ?? []).map((e) => CheckoutPayment.fromJson(e as Map<String, dynamic>)).toList();
    final paidAmount = payments.fold(0.0, (sum, p) => sum + p.amount);
    return Checkout(
      id: json['id'].toString(),
      tableId: (json['tableId'] ?? (table is Map ? table['id'] : null))?.toString(),
      tableName: json['tableName'] as String? ?? (table is Map<String, dynamic> ? table['tableName'] as String? : null),
      checkoutStatus: json['checkoutStatus'] as String? ?? 'pending',
      invoiceNumber: json['invoiceNumber'] as String?,
      noOfGuests: (json['noOfGuests'] as num?)?.toInt() ?? int.tryParse(json['noOfGuests']?.toString() ?? '') ?? 0,
      customerId: (json['customerId'] ?? (customer is Map ? customer['id'] : null))?.toString(),
      customerName: json['customerName'] as String? ?? (customer is Map<String, dynamic> ? customer['customerName'] as String? : null),
      companyName: json['companyName'] as String?,
      companyPan: json['companyPan'] as String?,
      discountType: json['discountType'] as String?,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0,
      remarks: json['remarks'] as String?,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      dueAmount: double.tryParse(json['dueAmount']?.toString() ?? '') ?? (totalAmount - paidAmount),
      payments: payments,
    );
  }
}
