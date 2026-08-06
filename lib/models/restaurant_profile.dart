/// Restaurant profile as returned by `GET /restaurant`. There is currently
/// no update endpoint for this resource — see [RestaurantService].
class RestaurantProfile {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String restaurantName;
  final String? legalRestaurantName;
  final String? vatPanNumber;
  final String? invoiceType;
  final String? contactNumber;
  final String? subDomain;
  final String? email;
  final String? country;
  final String? district;
  final String? address;
  final DateTime? openingDate;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? tiktokUrl;
  final String? googleReviewUrl;
  final bool status;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime? verifiedDate;
  final DateTime? expiryDate;
  final String? verificationStatus;
  final String? rejectionReason;
  final String? restaurantLogoId;
  final String? logoUrl;

  const RestaurantProfile({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.restaurantName,
    this.legalRestaurantName,
    this.vatPanNumber,
    this.invoiceType,
    this.contactNumber,
    this.subDomain,
    this.email,
    this.country,
    this.district,
    this.address,
    this.openingDate,
    this.facebookUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.tiktokUrl,
    this.googleReviewUrl,
    this.status = true,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.verifiedDate,
    this.expiryDate,
    this.verificationStatus,
    this.rejectionReason,
    this.restaurantLogoId,
    this.logoUrl,
  });

  /// `contactNumber` comes back as one string ("+977-9807994059") — the
  /// dial code before the first dash, and the local number after it.
  String? get dialCode {
    final number = contactNumber;
    if (number == null || !number.contains('-')) return null;
    return number.split('-').first;
  }

  String? get localPhoneNumber {
    final number = contactNumber;
    if (number == null) return null;
    if (!number.contains('-')) return number;
    return number.substring(number.indexOf('-') + 1);
  }

  factory RestaurantProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) => value == null ? null : DateTime.tryParse(value as String);

    // `restaurantLogoId` comes back as a plain id on some responses (e.g.
    // the create/update DTOs) and as the expanded media object — with a
    // `url` — on others (e.g. the login response's nested restaurant).
    final rawLogo = json['restaurantLogoId'];
    final String? logoId;
    final String? logoUrl;
    if (rawLogo is Map<String, dynamic>) {
      logoId = rawLogo['id']?.toString();
      logoUrl = rawLogo['url'] as String?;
    } else {
      logoId = rawLogo?.toString();
      logoUrl = null;
    }

    return RestaurantProfile(
      id: json['id'].toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      restaurantName: json['restaurantName'] as String? ?? '',
      legalRestaurantName: json['legalRestaurantName'] as String?,
      vatPanNumber: json['vatPanNumber'] as String?,
      invoiceType: json['invoiceType'] as String?,
      contactNumber: json['contactNumber'] as String?,
      subDomain: json['subDomain'] as String?,
      email: json['email'] as String?,
      country: json['country'] as String?,
      district: json['district'] as String?,
      address: json['address'] as String?,
      openingDate: parseDate(json['openingDate']),
      facebookUrl: json['facebookUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      googleReviewUrl: json['googleReviewUrl'] as String?,
      status: json['status'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      verifiedDate: parseDate(json['verifiedDate']),
      expiryDate: parseDate(json['expiryDate']),
      verificationStatus: json['verificationStatus'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      restaurantLogoId: logoId,
      logoUrl: logoUrl,
    );
  }
}
