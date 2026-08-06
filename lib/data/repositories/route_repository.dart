import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/staff/role_model.dart';

abstract class RouteRepository {
  Future<List<ApiRoute>> getRoutes();
}

/// Read-only — routes are shared, tenant-visible vocabulary (`GET
/// /api/routes`); this app doesn't manage the route list itself, only
/// grants permissions against it.
class RouteRepositoryImpl implements RouteRepository {
  final Dio _dio;

  RouteRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<ApiRoute>> getRoutes() async {
    try {
      final response = await _dio.get(ApiConstants.routes, queryParameters: {'page': 1, 'take': 200});
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => ApiRoute.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
