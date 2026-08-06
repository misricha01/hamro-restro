/// A stock item (e.g. "Basmati Rice"). Backend: `/api/stock`. `unitId`,
/// `stockGroupId` and `supplierId` are cross-referenced by id against
/// [UnitProvider]/[StockGroupProvider]/[SupplierProvider]'s own lists,
/// mirroring how [Dish.menuCategoryId] is handled.
class Stock {
  final String id;
  final String itemName;
  final double defaultPrice;
  final double quantity;
  final double rate;
  final String? description;
  final String? unitId;
  final String? stockGroupId;
  final String? supplierId;
  final DateTime createdAt;

  const Stock({
    required this.id,
    required this.itemName,
    required this.defaultPrice,
    required this.quantity,
    required this.rate,
    this.description,
    this.unitId,
    this.stockGroupId,
    this.supplierId,
    required this.createdAt,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'].toString(),
      itemName: json['itemName'] as String? ?? '',
      defaultPrice: (json['defaultPrice'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      unitId: json['unitId']?.toString(),
      stockGroupId: json['stockGroupId']?.toString(),
      supplierId: json['supplierId']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// One stock transaction row (backend: `/api/stock/history`,
/// `/api/stock/{id}/history`) — created by both `POST /api/stock` (opening
/// stock) and `PATCH /api/stock/{id}/adjust` (add/reduce).
class StockTransaction {
  final String id;
  final String stockId;
  final String? stockGroupId;
  final String type;
  final double quantity;
  final double rate;
  final String? remark;
  final String? staffId;
  final DateTime transactionDate;

  const StockTransaction({
    required this.id,
    required this.stockId,
    this.stockGroupId,
    required this.type,
    required this.quantity,
    required this.rate,
    this.remark,
    this.staffId,
    required this.transactionDate,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'].toString(),
      stockId: (json['stockId'] ?? json['stock']?['id'])?.toString() ?? '',
      stockGroupId: json['stockGroupId']?.toString(),
      type: json['type'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      remark: json['remark'] as String?,
      staffId: json['staffId']?.toString(),
      transactionDate: DateTime.tryParse(json['transactionDate'] as String? ?? json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Stock-wide stats card (backend: `GET /api/stock/stats`) — fields are
/// parsed defensively since the response shape isn't documented in Swagger.
class StockStats {
  final int totalStocks;
  final double totalStockValue;
  final int restocksThisWeek;
  final int lowStockItems;

  const StockStats({
    required this.totalStocks,
    required this.totalStockValue,
    required this.restocksThisWeek,
    required this.lowStockItems,
  });

  factory StockStats.fromJson(Map<String, dynamic> json) {
    return StockStats(
      totalStocks: (json['totalStocks'] as num?)?.toInt() ?? 0,
      totalStockValue: (json['totalStockValue'] as num?)?.toDouble() ?? 0,
      restocksThisWeek: (json['restocksThisWeek'] as num?)?.toInt() ?? 0,
      lowStockItems: (json['lowStockItems'] as num?)?.toInt() ?? 0,
    );
  }
}
