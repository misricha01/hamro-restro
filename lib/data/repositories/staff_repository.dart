import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/staff/staff_member_model.dart';

abstract class StaffRepository {
  Future<List<StaffMember>> getStaff({String? role});

  Future<StaffMember> getStaffById(String id);

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
        queryParameters: {'page': 1, 'take': 200, if (role != null) 'role': role},
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
          if (role != null && role.isNotEmpty) 'role': role,
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
          if (fullname != null) 'fullname': fullname,
          if (email != null) 'email': email,
          if (position != null) 'position': position,
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
