/// Maps one record from `GET /api/table-order` / `GET /api/table-order/{id}`.
/// The backend documents no response schema for this endpoint (Swagger
/// shows an empty 200) -- this model was built from a live sample response
/// captured 9 Sep 2026. Only the fields needed for a session list/detail
/// view are kept; the full response also nests order -> kots -> items /
/// combos -> stock consumptions, which this model does not attempt to
/// represent.
///
/// NOTE: the backend's own field is `TableStatus` (capital T), not
/// `tableStatus` -- kept as-is rather than "corrected", since renaming it
/// silently would hide a real backend inconsistency from future readers.
class TableOrderSession {
  final String id;
  final String tableStatus;
  final DateTime? createdAt;
  final TableOrderTableInfo table;
  final TableOrderOrderInfo order;

  const TableOrderSession({
    required this.id,
    required this.tableStatus,
    required this.createdAt,
    required this.table,
    required this.order,
  });

  factory TableOrderSession.fromJson(Map<String, dynamic> json) {
    return TableOrderSession(
      id: json['id'] as String,
      tableStatus: json['TableStatus'] as String? ?? 'unknown',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      table: TableOrderTableInfo.fromJson(json['table'] as Map<String, dynamic>? ?? const {}),
      order: TableOrderOrderInfo.fromJson(json['order'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class TableOrderTableInfo {
  final String id;
  final String tableName;
  final String tableType;
  final int capacity;

  const TableOrderTableInfo({required this.id, required this.tableName, required this.tableType, required this.capacity});

  factory TableOrderTableInfo.fromJson(Map<String, dynamic> json) {
    return TableOrderTableInfo(
      id: json['id'] as String? ?? '',
      tableName: json['tableName'] as String? ?? 'Unknown table',
      tableType: json['tableType'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
    );
  }
}

class TableOrderOrderInfo {
  final String id;
  final int kotCount;

  const TableOrderOrderInfo({required this.id, required this.kotCount});

  factory TableOrderOrderInfo.fromJson(Map<String, dynamic> json) {
    final kots = json['kots'] as List<dynamic>? ?? const [];
    return TableOrderOrderInfo(id: json['id'] as String? ?? '', kotCount: kots.length);
  }
}