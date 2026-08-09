/// An Add-On / Extra (backend: `addons`), e.g. "Extra Cheese".
class AddOn {
  final String id;
  final String addonName;
  final double price;
  final int dishCount;

  const AddOn({required this.id, required this.addonName, required this.price, this.dishCount = 0});

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['id'].toString(),
      addonName: json['addonName'] as String? ?? '',
      // Confirmed live: unlike most numeric fields in this backend, `price`
      // comes back as a string (e.g. `"150.00"`), not a number — parse
      // defensively rather than assume a shape. See PurchaseBill.amount.
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      dishCount: (json['dishCount'] as num?)?.toInt() ?? 0,
    );
  }
}
