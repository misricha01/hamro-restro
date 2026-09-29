import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/auth_storage.dart';
import 'api_constants.dart';

/// Single shared Dio instance for the entire app.
/// Attaches stored access tokens to outgoing requests, injects tenant subdomain
/// headers, and transparently refreshes expired JWT tokens on 401 status.
class DioClient {
  static DioClient? _instance;
  final AuthStorage _authStorage;
  late final Dio dio;

  /// Invoked when both access token and refresh token fail.
  VoidCallback? onUnauthenticated;

  Future<String?>? _refreshInFlight;

  /// Global singleton accessor for [DioClient].
  static DioClient get instance => _instance ??= DioClient();

  DioClient({AuthStorage? authStorage})
      : _authStorage = authStorage ?? AuthStorage() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final subDomain = await _readSubDomain();
          if (subDomain != null && subDomain.isNotEmpty) {
            options.headers['x-subdomain'] = subDomain;
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final path = error.requestOptions.path;
          final isAuthEndpoint =
              path == ApiConstants.login || path == ApiConstants.refresh;
          final alreadyRetried = error.requestOptions.extra['retried'] == true;

          if (error.response?.statusCode != 401 || isAuthEndpoint || alreadyRetried) {
            handler.next(error);
            return;
          }

          final newAccessToken = await _refreshAccessToken();
          if (newAccessToken == null) {
            onUnauthenticated?.call();
            handler.next(error);
            return;
          }

          final retryOptions = error.requestOptions
            ..headers['Authorization'] = 'Bearer $newAccessToken'
            ..extra['retried'] = true;

          try {
            final response = await dio.fetch(retryOptions);
            handler.resolve(response);
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  /// Ensures only one refresh call is in flight across simultaneous 401 requests.
  Future<String?> _refreshAccessToken() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await _authStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final plainDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ));

      final response = await plainDio.post(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String;

      await _authStorage.updateAccessToken(newAccessToken);
      return newAccessToken;
    } catch (_) {
      return null;
    }
  }

  /// Reads subdomain from stored user JSON so every request carries `x-subdomain`.
  Future<String?> _readSubDomain() async {
    final userJson = await _authStorage.readUserJson();
    if (userJson == null || userJson.isEmpty) return null;
    try {
      final user = jsonDecode(userJson) as Map<String, dynamic>;
      final restaurant = user['restaurant'] as Map<String, dynamic>?;
      return restaurant?['subDomain'] as String?;
    } catch (_) {
      return null;
    }
  }
}