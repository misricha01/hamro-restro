import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/auth_storage.dart';
import 'api_client.dart';
import 'api_constants.dart';

/// Single shared Dio instance for the app. Attaches the stored access token
/// to every outgoing request, and transparently refreshes an expired access
/// token (via `/api/auth/refresh`) and retries the original request once.
///
/// If the refresh token itself is invalid/expired, [onUnauthenticated] is
/// invoked so the app can drop the user back to the login screen — this
/// class has no knowledge of `AuthProvider`/navigation itself.
class DioClient {
  final AuthStorage _authStorage;
  late final Dio dio;

  /// Called when a request fails with 401 and refreshing the session also
  /// fails. Set by whoever owns the auth session (see `main.dart`).
  VoidCallback? onUnauthenticated;

  Future<String?>? _refreshInFlight;

  DioClient({AuthStorage? authStorage}) : _authStorage = authStorage ?? AuthStorage() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
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
          final isAuthEndpoint = path == ApiConstants.login || path == ApiConstants.refresh;
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
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  /// Ensures only one refresh call is in flight even if several requests
  /// 401 at the same time — they all await the same future.
  Future<String?> _refreshAccessToken() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await _authStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final plainDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl, headers: {'Content-Type': 'application/json'}));
      final response = await plainDio.post(ApiConstants.refresh, data: {'refresh_token': refreshToken});
      final newAccessToken = (response.data['data'] as Map<String, dynamic>)['access_token'] as String;
      await _authStorage.updateAccessToken(newAccessToken);
      await ApiClient.setAuthToken(newAccessToken);
      return newAccessToken;
    } catch (_) {
      return null;
    }
  }

  /// Pulls the restaurant's subdomain out of the stored `LoggedInUser` JSON
  /// (see `AuthStorage.saveSession`) so every request can carry it as
  /// `x-subdomain`, without this class depending on the `LoggedInUser` model.
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


