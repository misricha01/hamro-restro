/// A dish variant (e.g. "Large Pizza") — a standalone, reusable entity
/// attached to a [Dish] via its own `variantIds` list rather than the
/// variant holding a `dishId`. Backend: `/api/variant`.
class Variant {
  final String id;
  final String variantName;
  final String? unitId;
  final double actualPrice;
  final double discount;
  final double cogs;

  const Variant({
    required this.id,
    required this.variantName,
    this.unitId,
    required this.actualPrice,
    required this.discount,
    required this.cogs,
  });

  double get listedPrice {
    final result = actualPrice - discount;
    return result < 0 ? 0 : result;
  }

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'].toString(),
      variantName: json['variantName'] as String? ?? '',
      unitId: json['unitId']?.toString(),
      actualPrice: (json['actualPrice'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      cogs: (json['cogs'] as num?)?.toDouble() ?? 0,
    );
  }
}
