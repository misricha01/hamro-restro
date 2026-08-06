/// A "Space" in the app UI — called `area` on the backend.
class Area {
  final String id;
  final String areaName;
  final String? description;

  const Area({required this.id, required this.areaName, this.description});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'].toString(),
      areaName: (json['areaName'] as String?)?.trim().isNotEmpty == true ? json['areaName'] as String : 'Uncategorized',
      description: json['description'] as String?,
    );
  }
}
