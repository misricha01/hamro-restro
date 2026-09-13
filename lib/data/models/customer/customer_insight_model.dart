/// Resolves a nested reference that may come back as a plain string, an
/// `{id, name}`-shaped object (the pattern this backend uses elsewhere, e.g.
/// [FavouriteDish]), or `null`.
String? _nameOf(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  if (value is Map<String, dynamic>) {
    final name = value['name'] ?? value['tableName'] ?? value['dishName'];
    return name?.toString();
  }
  return value.toString();
}

/// `GET /api/customers/{id}/dining-insight`.
class CustomerDiningInsight {
  final String? frequentDish;
  final String? lastVisit;
  final String? mostVisitedTime;
  final String? frequentTable;

  const CustomerDiningInsight({this.frequentDish, this.lastVisit, this.mostVisitedTime, this.frequentTable});

  factory CustomerDiningInsight.fromJson(Map<String, dynamic> json) {
    return CustomerDiningInsight(
      frequentDish: _nameOf(json['frequentDish']),
      lastVisit: json['lastVisit']?.toString(),
      mostVisitedTime: json['mostVisitedTime']?.toString(),
      frequentTable: _nameOf(json['frequentTable']),
    );
  }

  bool get isEmpty => frequentDish == null && lastVisit == null && mostVisitedTime == null && frequentTable == null;
}

/// `GET /api/customers/{id}/finance-insight`.
class CustomerFinanceInsight {
  final double totalSales;
  final double totalReturn;
  final double totalPaymentIn;
  final double totalPaymentOut;

  const CustomerFinanceInsight({
    this.totalSales = 0,
    this.totalReturn = 0,
    this.totalPaymentIn = 0,
    this.totalPaymentOut = 0,
  });

  factory CustomerFinanceInsight.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
    return CustomerFinanceInsight(
      totalSales: num_(json['totalSales']),
      totalReturn: num_(json['totalReturn']),
      totalPaymentIn: num_(json['totalPaymentIn']),
      totalPaymentOut: num_(json['totalPaymentOut']),
    );
  }
}

/// A single entry in [CustomerSpendingBehaviour.spends]. Field names are a
/// best-effort guess — this restaurant had zero spend history at the time
/// this was wired up, so the shape of a non-empty entry is unconfirmed.
/// Falls back gracefully (`?? 0` / `?? null`) if a guessed key is wrong.
class CustomerSpendEntry {
  final double amount;
  final String? date;
  final String? description;

  const CustomerSpendEntry({this.amount = 0, this.date, this.description});

  factory CustomerSpendEntry.fromJson(Map<String, dynamic> json) {
    return CustomerSpendEntry(
      amount: double.tryParse((json['amount'] ?? json['total'] ?? json['spend'])?.toString() ?? '') ?? 0,
      date: (json['date'] ?? json['createdAt'] ?? json['visitDate'])?.toString(),
      description: (json['description'] ?? json['remarks'] ?? json['note'])?.toString(),
    );
  }
}

/// `GET /api/customers/{id}/spending-behaviour`.
class CustomerSpendingBehaviour {
  final double totalSpent;
  final int totalVisit;
  final double averageSpendPerVisit;
  final List<CustomerSpendEntry> spends;

  const CustomerSpendingBehaviour({
    this.totalSpent = 0,
    this.totalVisit = 0,
    this.averageSpendPerVisit = 0,
    this.spends = const [],
  });

  factory CustomerSpendingBehaviour.fromJson(Map<String, dynamic> json) {
    final rawSpends = json['spends'] as List<dynamic>? ?? const [];
    return CustomerSpendingBehaviour(
      totalSpent: double.tryParse(json['totalSpent']?.toString() ?? '') ?? 0,
      totalVisit: int.tryParse(json['totalVisit']?.toString() ?? '') ?? 0,
      averageSpendPerVisit: double.tryParse(json['averageSpendPerVisit']?.toString() ?? '') ?? 0,
      spends: rawSpends.whereType<Map<String, dynamic>>().map(CustomerSpendEntry.fromJson).toList(),
    );
  }
}
