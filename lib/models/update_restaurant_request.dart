/// Request body for `PATCH /api/restaurant/settings`.
///
/// Excludes `defaultAdminFullname` / `defaultAdminEmail` /
/// `defaultAdminPassword` — those only make sense on `POST
/// /restaurant/create-restro` (creating a brand-new restaurant with its
/// first admin), not when updating an existing one's settings.
class UpdateRestaurantRequest {
  final String restaurantName;
  final String? legalRestaurantName;
  final String? vatPanNumber;
  final String? invoiceType;
  final String? restaurantLogoId;
  final String? contactNumber;
  final String? subDomain;
  final String? email;
  final String? country;
  final String? district;
  final String? address;
  final String? restaurantTypeId;
  final String? openingDate;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? tiktokUrl;
  final String? googleReviewUrl;
  final bool status;

  const UpdateRestaurantRequest({
    required this.restaurantName,
    this.legalRestaurantName,
    this.vatPanNumber,
    this.invoiceType,
    this.restaurantLogoId,
    this.contactNumber,
    this.subDomain,
    this.email,
    this.country,
    this.district,
    this.address,
    this.restaurantTypeId,
    this.openingDate,
    this.facebookUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.tiktokUrl,
    this.googleReviewUrl,
    this.status = true,
  });

  Map<String, dynamic> toJson() => {
    'restaurantName': restaurantName,
    if (legalRestaurantName != null) 'legalRestaurantName': legalRestaurantName,
    if (vatPanNumber != null) 'vatPanNumber': vatPanNumber,
    if (invoiceType != null) 'invoiceType': invoiceType,
    if (restaurantLogoId != null) 'restaurantLogoId': restaurantLogoId,
    if (contactNumber != null) 'contactNumber': contactNumber,
    if (subDomain != null) 'subDomain': subDomain,
    if (email != null) 'email': email,
    if (country != null) 'country': country,
    if (district != null) 'district': district,
    if (address != null) 'address': address,
    if (restaurantTypeId != null) 'restaurantTypeId': restaurantTypeId,
    if (openingDate != null) 'openingDate': openingDate,
    if (facebookUrl != null) 'facebookUrl': facebookUrl,
    if (instagramUrl != null) 'instagramUrl': instagramUrl,
    if (youtubeUrl != null) 'youtubeUrl': youtubeUrl,
    if (tiktokUrl != null) 'tiktokUrl': tiktokUrl,
    if (googleReviewUrl != null) 'googleReviewUrl': googleReviewUrl,
    'status': status,
  };
}
