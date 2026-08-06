/// A note attached to a [Customer]. Sent on create, but hasn't been
/// observed on any `GET` response yet (list or detail) — still unconfirmed
/// whether it's dropped or just omitted from both views.
class CustomerComment {
  final String? id;
  final String comment;

  const CustomerComment({this.id, required this.comment});

  factory CustomerComment.fromJson(Map<String, dynamic> json) {
    return CustomerComment(
      id: json['id']?.toString(),
      comment: json['comment'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'comment': comment};
}

/// A customer group, e.g. "VIP". No known list/create endpoint for this
/// resource yet — only seen nested inside a [Customer].
class CustomerGroup {
  final String id;
  final String name;
  final String? description;

  const CustomerGroup({required this.id, required this.name, this.description});

  factory CustomerGroup.fromJson(Map<String, dynamic> json) {
    return CustomerGroup(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

/// A customer's favourite dish, nested on the `GET /api/customers/{id}`
/// detail response. Resolves the create-time `favouriteDishId`.
class FavouriteDish {
  final String id;
  final String dishName;

  const FavouriteDish({required this.id, required this.dishName});

  factory FavouriteDish.fromJson(Map<String, dynamic> json) {
    return FavouriteDish(id: json['id'].toString(), dishName: json['dishName'] as String? ?? '');
  }
}

/// A customer's preferred seating — confirmed to just be a [RestaurantTable]
/// reference (`{id, tableName}`), so no separate endpoint is needed for a
/// picker; resolves the create-time `preferredSeatingId`.
class PreferredSeating {
  final String id;
  final String tableName;

  const PreferredSeating({required this.id, required this.tableName});

  factory PreferredSeating.fromJson(Map<String, dynamic> json) {
    return PreferredSeating(id: json['id'].toString(), tableName: json['tableName'] as String? ?? '');
  }
}

/// A dietary type, e.g. "Veg" (backend: unknown — only seen nested here).
/// Distinct from [DishType] despite the conceptual overlap. No known
/// list/create endpoint yet. Resolves the create-time `dietaryTypeId`.
class DietaryType {
  final String id;
  final String name;

  const DietaryType({required this.id, required this.name});

  factory DietaryType.fromJson(Map<String, dynamic> json) {
    return DietaryType(id: json['id'].toString(), name: json['name'] as String? ?? '');
  }
}

/// A customer (backend: `/api/customers`). Confirmed against real
/// `GET /api/customers` (list) and `GET /api/customers/{id}` (detail)
/// responses — `restaurantId`, `updatedAt`, `deletedAt`, `creatorId` and
/// `checkouts` are left unparsed since the UI doesn't need them yet.
/// `favouriteDish`/`preferredSeating`/`dietaryType`/`customerGroup` only
/// come back as nested objects on the detail response, not the list one —
/// `comments` hasn't been observed on either.
class Customer {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String? emailAddress;
  final String? companyName;
  final String? panVatNumber;
  final String? discount;
  final String? allergies;
  final String? startPreferredTime;
  final String? endPreferredTime;
  final bool status;
  final DateTime createdAt;
  final CustomerGroup? customerGroup;
  final FavouriteDish? favouriteDish;
  final PreferredSeating? preferredSeating;
  final DietaryType? dietaryType;
  final List<CustomerComment> comments;

  const Customer({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    this.emailAddress,
    this.companyName,
    this.panVatNumber,
    this.discount,
    this.allergies,
    this.startPreferredTime,
    this.endPreferredTime,
    this.status = true,
    required this.createdAt,
    this.customerGroup,
    this.favouriteDish,
    this.preferredSeating,
    this.dietaryType,
    this.comments = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    final comments = json['comments'] as List<dynamic>? ?? const [];
    return Customer(
      id: json['id'].toString(),
      customerName: json['customerName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String?,
      companyName: json['companyName'] as String?,
      panVatNumber: json['panVatNumber'] as String?,
      discount: json['discount']?.toString(),
      allergies: json['allergies'] as String?,
      startPreferredTime: json['startPreferredTime'] as String?,
      endPreferredTime: json['endPreferredTime'] as String?,
      status: json['status'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      customerGroup: json['customerGroup'] == null ? null : CustomerGroup.fromJson(json['customerGroup'] as Map<String, dynamic>),
      favouriteDish: json['favouriteDish'] == null ? null : FavouriteDish.fromJson(json['favouriteDish'] as Map<String, dynamic>),
      preferredSeating: json['preferredSeating'] == null ? null : PreferredSeating.fromJson(json['preferredSeating'] as Map<String, dynamic>),
      dietaryType: json['dietaryType'] == null ? null : DietaryType.fromJson(json['dietaryType'] as Map<String, dynamic>),
      comments: comments.map((e) => CustomerComment.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
