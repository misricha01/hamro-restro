/// A stock item consumed when a dish is prepared, within [Dish.stockConsumptions].
class DishStockConsumption {
  final String stockItemId;
  final double quantity;

  const DishStockConsumption({required this.stockItemId, required this.quantity});

  factory DishStockConsumption.fromJson(Map<String, dynamic> json) {
    return DishStockConsumption(
      stockItemId: json['stockItemId'].toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'stockItemId': stockItemId, 'quantity': quantity};
}

/// A menu item (backend: `/api/dish`). `unitId`, `variantIds`, `addonIds`
/// and `stockConsumptions` are optional — confirmed by a successful create
/// without them (`POST /api/unit`, needed to get a real `unitId`, currently
/// 500s on the backend). `typeOfMenuId` is also sent as null for now — the
/// app has no real "type of menu" endpoint/picker yet (the Sub-Menu picker
/// only returns a display name, not an id).
class Dish {
  final String id;
  final String dishName;
  final String? hsCode;
  final String? dishPhoto;
  final String? dishPhotoUrl;
  final String? description;
  final double? price;
  final String? unitId;
  final double? cogs;
  final String? discountType;
  final double? discount;
  final double? priceAfterDiscount;
  final List<String> variantIds;
  final List<String> addonIds;
  final String dishTypeId;
  final String? typeOfMenuId;
  final String menuCategoryId;
  final bool available;
  final List<DishStockConsumption> stockConsumptions;

  const Dish({
    required this.id,
    required this.dishName,
    this.hsCode,
    this.dishPhoto,
    this.dishPhotoUrl,
    this.description,
    this.price,
    this.unitId,
    this.cogs,
    this.discountType,
    this.discount,
    this.priceAfterDiscount,
    this.variantIds = const [],
    this.addonIds = const [],
    required this.dishTypeId,
    this.typeOfMenuId,
    required this.menuCategoryId,
    this.available = true,
    this.stockConsumptions = const [],
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    final variantIds = json['variantIds'] as List<dynamic>? ?? const [];
    final addonIds = json['addonIds'] as List<dynamic>? ?? const [];
    final stockConsumptions = json['stockConsumptions'] as List<dynamic>? ?? const [];
    // Seen as a flat media id string on create, but nested as a full media
    // object ({id, type, url, ...}) when expanded via a customer's
    // favouriteDish — handle both rather than assume one shape.
    final rawPhoto = json['dishPhoto'];
    return Dish(
      id: json['id'].toString(),
      dishName: json['dishName'] as String? ?? '',
      hsCode: json['hsCode'] as String?,
      dishPhoto: switch (rawPhoto) {
        String s => s,
        Map<String, dynamic> m => m['id']?.toString(),
        _ => null,
      },
      dishPhotoUrl: rawPhoto is Map<String, dynamic> ? rawPhoto['url'] as String? : null,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      unitId: json['unitId']?.toString(),
      cogs: (json['cogs'] as num?)?.toDouble(),
      discountType: json['discountType'] as String?,
      discount: (json['discount'] as num?)?.toDouble(),
      priceAfterDiscount: (json['priceAfterDiscount'] as num?)?.toDouble(),
      variantIds: variantIds.map((e) => e.toString()).toList(),
      addonIds: addonIds.map((e) => e.toString()).toList(),
      dishTypeId: json['dishTypeId'].toString(),
      typeOfMenuId: json['typeOfMenuId']?.toString(),
      menuCategoryId: json['menuCategoryId'].toString(),
      available: json['available'] as bool? ?? true,
      stockConsumptions: stockConsumptions.map((e) => DishStockConsumption.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
