/// A combo offer (e.g. "Family combo"). Backend: `/api/combo-offer`.
class ComboOffer {
  final String id;
  final String name;
  final String? description;
  final String? hsCode;
  final String? comboPhoto;
  final String? comboPhotoUrl;
  final List<String> dishIds;
  final double offerPrice;
  final DateTime startsAt;
  final DateTime endsAt;

  const ComboOffer({
    required this.id,
    required this.name,
    this.description,
    this.hsCode,
    this.comboPhoto,
    this.comboPhotoUrl,
    this.dishIds = const [],
    required this.offerPrice,
    required this.startsAt,
    required this.endsAt,
  });

  factory ComboOffer.fromJson(Map<String, dynamic> json) {
    // The backend returns `items: [{dishId, variantId, quantity, dish}]`
    // rather than a flat `dishIds` list (verified live 2026-09-29); fall back
    // to `dishIds` in case an older response shape still carries it.
    final items = json['items'] as List<dynamic>?;
    final dishIds = items != null
        ? items.map((e) => (e as Map<String, dynamic>)['dishId']).whereType<Object>().toList()
        : json['dishIds'] as List<dynamic>? ?? const [];
    // Same "flat media id on create, nested media object when expanded"
    // shape seen on Dish's `dishPhoto` — handle both. See DishModel.
    final rawPhoto = json['comboPhoto'];
    return ComboOffer(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      hsCode: json['hsCode'] as String?,
      comboPhoto: switch (rawPhoto) {
        String s => s,
        Map<String, dynamic> m => m['id']?.toString(),
        _ => null,
      },
      comboPhotoUrl: rawPhoto is Map<String, dynamic> ? rawPhoto['url'] as String? : null,
      dishIds: dishIds.map((e) => e.toString()).toList(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0,
      startsAt: DateTime.tryParse(json['startsAt'] as String? ?? '') ?? DateTime.now(),
      endsAt: DateTime.tryParse(json['endsAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
