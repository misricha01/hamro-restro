/// A restaurant staff member (backend: `/api/user`, `/api/restaurant/create-account`).
/// Shape mirrors the confirmed `LoggedInUser` fields — there is no
/// `contactNumber`/`balance`/`discountLimit` on this backend, so those stay
/// local-only UI concerns rather than being read from or sent to the API.
class StaffMember {
  final String id;
  final String? restaurantId;
  final String fullname;
  final String email;
  final String role;
  final String? position;
  final bool? isDefaultAdmin;
  final bool? status;
  final DateTime? createdAt;

  const StaffMember({
    required this.id,
    this.restaurantId,
    required this.fullname,
    required this.email,
    required this.role,
    this.position,
    this.isDefaultAdmin,
    this.status,
    this.createdAt,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'].toString(),
      restaurantId: json['restaurantId']?.toString(),
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      position: json['position'] as String?,
      isDefaultAdmin: json['isDefaultAdmin'] as bool?,
      status: json['status'] as bool?,
      createdAt: json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'] as String),
    );
  }
}
