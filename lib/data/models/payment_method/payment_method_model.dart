/// A payment mode (e.g. "CASH", "Fonepay"), shown on Cash & Banks' Modes
/// tab. Backend: `/api/payment-method`. Named `PaymentMode` (not
/// `PaymentMethod`) to avoid clashing with the unrelated, already-existing
/// `PaymentMethod` quick-select-chip class in
/// `widgets/common/finance_form_fields.dart`.
class PaymentMode {
  final String id;
  final String name;
  final String? remarks;

  const PaymentMode({required this.id, required this.name, this.remarks});

  factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      remarks: json['remarks'] as String?,
    );
  }
}
