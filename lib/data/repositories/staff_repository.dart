import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/staff/staff_member_model.dart';

abstract class StaffRepository {
  Future<List<StaffMember>> getStaff({String? role});

  Future<StaffMember> getStaffById(String id);

  /// `GET /api/user/profile` -- the currently authenticated user's own
  /// profile (as opposed to `getStaffById`, which looks up any staff
  /// member by id).
  Future<StaffMember> getProfile();

  Future<StaffMember> createStaff({
    required String fullname,
    required String email,
    required String password,
    required String position,
    String? role,
  });

  Future<StaffMember> updateStaff({
    required String id,
    String? fullname,
    String? email,
    String? position,
  });

  Future<void> deleteStaff(String id);
}

class StaffRepositoryImpl implements StaffRepository {
  final Dio _dio;

  StaffRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<StaffMember>> getStaff({String? role}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.staff}/all',
        queryParameters: {'page': 1, 'take': 200, 'role': ?role},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => StaffMember.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<StaffMember> getStaffById(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.staff}/$id');
      return StaffMember.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<StaffMember> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.myProfile);
      // NOTE: Swagger documents no response schema for this endpoint (empty
      // 200), unlike every other endpoint here which wraps its payload in
      // `{"data": ...}`. Handling both shapes defensively until this is
      // confirmed live -- if the real response nests further (e.g.
      // `{"data": {"user": {...}}}`), adjust this unwrap accordingly.
      final raw = response.data;
      final body = raw is Map<String, dynamic> && raw['data'] != null ? raw['data'] as Map<String, dynamic> : raw as Map<String, dynamic>;
      return StaffMember.fromJson(body);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<StaffMember> createStaff({
    required String fullname,
    required String email,
    required String password,
    required String position,
    String? role,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.createStaffAccount,
        data: {
          'fullname': fullname,
          'email': email,
          'password': password,
          'position': position,
          // The backend's `role` field here only accepts a small fixed set
          // of base types ("user"/"admin") — it is NOT the same vocabulary
          // as the custom RBAC role names from `GET /api/roles` (confirmed
          // live: sending a custom role name or omitting this field both
          // 400 with "Valid role required."). The caller's actual role
          // pick is applied afterward via `RbacRepository.assignRole`
          // (see StaffProvider.createStaff), which does accept custom names.
          'role': 'user',
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['fullname'] != null) return StaffMember.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by email.
      final staff = await getStaff();
      final matches = staff.where((s) => s.email == email).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Staff member was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<StaffMember> updateStaff({
    required String id,
    String? fullname,
    String? email,
    String? position,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.staff}/$id',
        data: {
          'fullname': ?fullname,
          'email': ?email,
          'position': ?position,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['fullname'] != null) return StaffMember.fromJson(raw);

      return getStaffById(id);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteStaff(String id) async {
    try {
      await _dio.delete('${ApiConstants.staff}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}