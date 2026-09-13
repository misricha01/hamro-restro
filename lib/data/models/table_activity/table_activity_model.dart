/// The `table`/`changed_table` reference nested on a [TableActivityEntry].
class TableActivityTableRef {
  final String id;
  final String tableName;
  final String? tableType;

  const TableActivityTableRef({required this.id, required this.tableName, this.tableType});

  factory TableActivityTableRef.fromJson(Map<String, dynamic> json) {
    return TableActivityTableRef(
      id: json['id'].toString(),
      tableName: json['tableName'] as String? ?? '',
      tableType: json['tableType'] as String?,
    );
  }
}

/// A single row from `GET /api/table-activity` — one event in a table's
/// session history (order placed, checkout initiated/completed, table
/// moved/merged). There's no `tableId` query filter on the backend, so
/// callers fetch a page and filter client-side by `table.id`.
class TableActivityEntry {
  final String id;
  final DateTime createdAt;
  final String activitySessionId;
  final bool isActive;
  final String activityType;
  final String description;
  final TableActivityTableRef? table;
  final TableActivityTableRef? changedTable;

  const TableActivityEntry({
    required this.id,
    required this.createdAt,
    required this.activitySessionId,
    required this.isActive,
    required this.activityType,
    required this.description,
    this.table,
    this.changedTable,
  });

  factory TableActivityEntry.fromJson(Map<String, dynamic> json) {
    return TableActivityEntry(
      id: json['id'].toString(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      activitySessionId: json['activitySessionId']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      activityType: json['activity_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      table: json['table'] == null ? null : TableActivityTableRef.fromJson(json['table'] as Map<String, dynamic>),
      changedTable: json['changed_table'] == null ? null : TableActivityTableRef.fromJson(json['changed_table'] as Map<String, dynamic>),
    );
  }
}
