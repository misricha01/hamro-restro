/// A stock group (e.g. "Drinks", "Groceries") used to categorize [Stock]
/// items. Backend: `/api/stock-group`.
class StockGroup {
  final String id;
  final String groupName;
  final String? groupDescription;

  const StockGroup({required this.id, required this.groupName, this.groupDescription});

  factory StockGroup.fromJson(Map<String, dynamic> json) {
    return StockGroup(
      id: json['id'].toString(),
      groupName: json['groupName'] as String? ?? '',
      groupDescription: json['groupDescription'] as String?,
    );
  }
}
