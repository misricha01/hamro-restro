import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);

  /// Best-effort server-side session invalidation. Callers should still
  /// clear the local session even if this throws.
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl({DioClient? dioClient}) : _dio = (dioClient ?? DioClient()).dio;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: request.toJson());
      final data = response.data['data'] as Map<String, dynamic>;
      return LoginResponse.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
