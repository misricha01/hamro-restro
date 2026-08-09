import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/staff/role_model.dart';

abstract class RbacRepository {
  Future<void> assignRole({required String userId, required String roleName});

  Future<void> unassignRole(String userId);

  Future<List<RbacEntry>> getRbacForRole(String roleName);

  /// Grants each `(role, route, permission)` in [grants] — used by the User
  /// Role editor to save newly-checked cells in the Route x Permission
  /// matrix. `PUT /api/rbac/bulk`.
  Future<void> bulkSetRbac(List<RbacEntry> grants);

  /// Revokes the RBAC records identified by [ids] — used by the User Role
  /// editor to save newly-unchecked cells. `DELETE /api/rbac/bulk`.
  Future<void> bulkDeleteRbac(List<String> ids);
}

class RbacRepositoryImpl implements RbacRepository {
  final Dio _dio;

  RbacRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<void> assignRole({required String userId, required String roleName}) async {
    try {
      await _dio.post(ApiConstants.rbacAssignRole, data: {'userId': userId, 'roleName': roleName});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> unassignRole(String userId) async {
    try {
      await _dio.delete('${ApiConstants.rbacAssignRole}/$userId');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<RbacEntry>> getRbacForRole(String roleName) async {
    try {
      final response = await _dio.get(ApiConstants.rbacAll, queryParameters: {'role': roleName});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => RbacEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> bulkSetRbac(List<RbacEntry> grants) async {
    if (grants.isEmpty) return;
    try {
      await _dio.put(
        ApiConstants.rbacBulk,
        data: {
          'items': grants.map((g) => {'role': g.role, 'route': g.route, 'permission': g.permission}).toList(),
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> bulkDeleteRbac(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      await _dio.delete(ApiConstants.rbacBulk, data: {'ids': ids});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
