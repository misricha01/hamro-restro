/// An Add-On / Extra (backend: `addons`), e.g. "Extra Cheese".
class AddOn {
  final String id;
  final String addonName;
  final double price;
  final double cogs;
  final int dishCount;

  const AddOn({required this.id, required this.addonName, required this.price, this.cogs = 0, this.dishCount = 0});

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['id'].toString(),
      // Confirmed live: the backend's field is `addOnName` (capital O),
      // not `addonName` — matches CreateAddonDTO's schema.
      addonName: json['addOnName'] as String? ?? json['addonName'] as String? ?? '',
      // Confirmed live: unlike most numeric fields in this backend, `price`
      // comes back as a string (e.g. `"150.00"`), not a number — parse
      // defensively rather than assume a shape. See PurchaseBill.amount.
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      cogs: double.tryParse(json['cogs']?.toString() ?? '') ?? 0,
      dishCount: (json['dishCount'] as num?)?.toInt() ?? 0,
    );
  }
}
