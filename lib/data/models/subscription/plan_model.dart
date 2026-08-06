/// A subscription plan tier (backend: `GET /api/plans`, public catalog).
/// Dynamic and per-tenant-configurable — not a fixed Free/Basic/Premium/
/// Platinum list.
class Plan {
  final String id;
  final String code;
  final String name;
  final String? description;
  final bool isPopular;
  final int displayOrder;

  const Plan({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.isPopular = false,
    this.displayOrder = 0,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'].toString(),
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

/// One billing-cycle price point for a [Plan] (backend: `GET /api/plan-prices`).
class PlanPrice {
  final String id;
  final String planId;
  final String billingCycle;
  final double price;
  final String currency;
  final int? durationDays;

  const PlanPrice({
    required this.id,
    required this.planId,
    required this.billingCycle,
    required this.price,
    this.currency = 'NPR',
    this.durationDays,
  });

  factory PlanPrice.fromJson(Map<String, dynamic> json) {
    return PlanPrice(
      id: json['id'].toString(),
      planId: json['planId'].toString(),
      billingCycle: json['billingCycle'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      currency: json['currency'] as String? ?? 'NPR',
      durationDays: (json['durationDays'] as num?)?.toInt(),
    );
  }
}

/// One of the fixed, shared feature codes every plan can grant (backend:
/// `GET /api/features`) — `valueType` is `'boolean'` (on/off) or `'limit'`
/// (numeric cap).
class PlanFeatureDef {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String valueType;

  const PlanFeatureDef({required this.id, required this.code, required this.name, this.description, this.valueType = 'boolean'});

  factory PlanFeatureDef.fromJson(Map<String, dynamic> json) {
    return PlanFeatureDef(
      id: json['id'].toString(),
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      valueType: json['valueType'] as String? ?? 'boolean',
    );
  }
}

/// A grant of one [PlanFeatureDef] onto one [Plan] (backend: `GET
/// /api/plan-features`) — `limitValue` is null for unlimited.
class PlanFeatureGrant {
  final String id;
  final String planId;
  final String featureId;
  final bool isEnabled;
  final int? limitValue;

  const PlanFeatureGrant({required this.id, required this.planId, required this.featureId, this.isEnabled = false, this.limitValue});

  factory PlanFeatureGrant.fromJson(Map<String, dynamic> json) {
    return PlanFeatureGrant(
      id: json['id'].toString(),
      planId: json['planId'].toString(),
      featureId: json['featureId'].toString(),
      isEnabled: json['isEnabled'] as bool? ?? false,
      limitValue: (json['limitValue'] as num?)?.toInt(),
    );
  }
}
