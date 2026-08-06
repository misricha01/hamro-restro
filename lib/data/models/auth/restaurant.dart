class Restaurant {
  final String id;
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
  final String? verificationStatus;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;

  const Restaurant({
    required this.id,
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
    this.verificationStatus,
    this.isEmailVerified,
    this.isPhoneVerified,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'].toString(),
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
      verificationStatus: json['verificationStatus'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      isPhoneVerified: json['isPhoneVerified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurantName': restaurantName,
    'legalRestaurantName': legalRestaurantName,
    'vatPanNumber': vatPanNumber,
    'invoiceType': invoiceType,
    'contactNumber': contactNumber,
    'subDomain': subDomain,
    'email': email,
    'country': country,
    'district': district,
    'address': address,
    'verificationStatus': verificationStatus,
    'isEmailVerified': isEmailVerified,
    'isPhoneVerified': isPhoneVerified,
  };
}
