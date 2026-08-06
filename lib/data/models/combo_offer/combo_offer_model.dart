/// A combo offer (e.g. "Family combo"). Backend: `/api/combo-offer`.
class ComboOffer {
  final String id;
  final String name;
  final String? description;
  final String? hsCode;
  final String? comboPhoto;
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
    this.dishIds = const [],
    required this.offerPrice,
    required this.startsAt,
    required this.endsAt,
  });

  factory ComboOffer.fromJson(Map<String, dynamic> json) {
    final dishIds = json['dishIds'] as List<dynamic>? ?? const [];
    return ComboOffer(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      hsCode: json['hsCode'] as String?,
      comboPhoto: json['comboPhoto']?.toString(),
      dishIds: dishIds.map((e) => e.toString()).toList(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0,
      startsAt: DateTime.tryParse(json['startsAt'] as String? ?? '') ?? DateTime.now(),
      endsAt: DateTime.tryParse(json['endsAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
