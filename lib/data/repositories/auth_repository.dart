import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);

  /// `POST /api/auth/register` (operation id `AuthController_createUser`).
  /// Swagger's summary says "Register a new user and auto-login" -- the
  /// response has NOT been confirmed live, but is assumed to match login's
  /// `{status, message, data: {access_token, refresh_token,
  /// loggedInUser}}` envelope given that wording. If the real payload
  /// differs, this is the first place to check.
  ///
  /// NOTE: `CreateUserDto` has no `restaurantId` field, so a freshly
  /// registered user has no restaurant attached yet -- there is currently
  /// no follow-up screen (e.g. "create your restaurant") wired after this
  /// call succeeds.
  Future<LoginResponse> register(RegisterRequest request);

  /// Best-effort server-side session invalidation. Callers should still
  /// clear the local session even if this throws.
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl({DioClient? dioClient}) : _dio = (dioClient ?? DioClient.instance).dio;

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
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(ApiConstants.register, data: request.toJson());
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