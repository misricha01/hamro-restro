/// The restaurant's current subscription (backend: `GET
/// /api/subscriptions/current`). The response shape isn't documented in
/// Swagger beyond "subscription and entitlements", so every field is parsed
/// defensively — missing/renamed fields fall back to null rather than
/// throwing, and the UI treats null as "unknown" rather than fabricating a
/// value.
class CurrentSubscription {
  final String? id;
  final String? planId;
  final String? planName;
  final String? billingCycle;
  final String? status;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;

  const CurrentSubscription({
    this.id,
    this.planId,
    this.planName,
    this.billingCycle,
    this.status,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
  });

  bool get isActive => (status ?? '').toLowerCase() == 'active';

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'];
    return CurrentSubscription(
      id: json['id']?.toString(),
      planId: (json['planId'] ?? (plan is Map ? plan['id'] : null))?.toString(),
      planName: (plan is Map ? plan['name'] as String? : null) ?? json['planName'] as String?,
      billingCycle: json['billingCycle'] as String?,
      status: json['status'] as String?,
      currentPeriodEnd: DateTime.tryParse((json['currentPeriodEnd'] ?? json['endsAt'] ?? '').toString()),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
    );
  }
}

/// One row of the restaurant's SaaS billing history (backend: `GET
/// /api/billing/invoices`) — parsed defensively for the same reason as
/// [CurrentSubscription].
class BillingInvoice {
  final String id;
  final String? number;
  final double? amount;
  final String? status;
  final DateTime? issuedAt;

  const BillingInvoice({required this.id, this.number, this.amount, this.status, this.issuedAt});

  factory BillingInvoice.fromJson(Map<String, dynamic> json) {
    return BillingInvoice(
      id: json['id'].toString(),
      number: (json['invoiceNumber'] ?? json['number'])?.toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'] as String?,
      issuedAt: DateTime.tryParse((json['issuedAt'] ?? json['createdAt'] ?? '').toString()),
    );
  }
}

/// One row of the restaurant's payment history (backend: `GET
/// /api/billing/payments`).
class BillingPayment {
  final String id;
  final double? amount;
  final String? status;
  final String? method;
  final DateTime? paidAt;

  const BillingPayment({required this.id, this.amount, this.status, this.method, this.paidAt});

  factory BillingPayment.fromJson(Map<String, dynamic> json) {
    return BillingPayment(
      id: json['id'].toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'] as String?,
      method: (json['method'] ?? json['gateway'])?.toString(),
      paidAt: DateTime.tryParse((json['paidAt'] ?? json['createdAt'] ?? '').toString()),
    );
  }
}
