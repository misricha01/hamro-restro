import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/staff/role_model.dart';

abstract class RoleRepository {
  Future<List<Role>> getRoles();

  Future<Role> createRole(String name);

  Future<Role> updateRole({required String id, required String name});

  Future<void> deleteRole(String id);
}

class RoleRepositoryImpl implements RoleRepository {
  final Dio _dio;

  RoleRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Role>> getRoles() async {
    try {
      final response = await _dio.get(ApiConstants.roles, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => Role.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Role> createRole(String name) async {
    try {
      final response = await _dio.post(ApiConstants.roles, data: {'name': name});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return Role.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by name.
      final roles = await getRoles();
      final matches = roles.where((r) => r.name == name).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Role was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Role> updateRole({required String id, required String name}) async {
    try {
      final response = await _dio.patch('${ApiConstants.roles}/$id', data: {'name': name});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return Role.fromJson(raw);

      final roles = await getRoles();
      final match = roles.where((r) => r.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Role was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      await _dio.delete('${ApiConstants.roles}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
