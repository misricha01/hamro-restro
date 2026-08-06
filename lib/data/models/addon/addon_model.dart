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
      price: (json['price'] as num?)?.toDouble() ?? 0,
      dishCount: (json['dishCount'] as num?)?.toInt() ?? 0,
    );
  }
}
