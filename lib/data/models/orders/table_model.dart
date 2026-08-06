import '../area/area_model.dart';

/// Named `RestaurantTable` (not `Table`) to avoid clashing with Flutter's
/// own `Table` widget.
class RestaurantTable {
  final String id;
  final String tableName;
  final String? tableType;
  final int? capacity;
  final String tableStatus;
  final bool available;
  final Area? area;

  const RestaurantTable({
    required this.id,
    required this.tableName,
    this.tableType,
    this.capacity,
    required this.tableStatus,
    required this.available,
    this.area,
  });

  String get categoryName => area?.areaName ?? 'Uncategorized';

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'].toString(),
      tableName: json['tableName'] as String? ?? '',
      tableType: json['tableType'] as String?,
      capacity: (json['capacity'] as num?)?.toInt(),
      tableStatus: json['tableStatus'] as String? ?? 'Open',
      available: json['available'] as bool? ?? true,
      area: json['area'] == null ? null : Area.fromJson(json['area'] as Map<String, dynamic>),
    );
  }
}
