import 'restaurant.dart';

class LoggedInUser {
  final String id;
  final String? restaurantId;
  final String fullname;
  final String email;
  final String role;
  final String? position;
  final bool? isDefaultAdmin;
  final bool? status;
  final Restaurant? restaurant;

  const LoggedInUser({
    required this.id,
    this.restaurantId,
    required this.fullname,
    required this.email,
    required this.role,
    this.position,
    this.isDefaultAdmin,
    this.status,
    this.restaurant,
  });

  factory LoggedInUser.fromJson(Map<String, dynamic> json) {
    return LoggedInUser(
      id: json['id'].toString(),
      restaurantId: json['restaurantId']?.toString(),
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      position: json['position'] as String?,
      isDefaultAdmin: json['isDefaultAdmin'] as bool?,
      status: json['status'] as bool?,
      restaurant: json['restaurant'] == null ? null : Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'fullname': fullname,
    'email': email,
    'role': role,
    'position': position,
    'isDefaultAdmin': isDefaultAdmin,
    'status': status,
    'restaurant': restaurant?.toJson(),
  };
}
