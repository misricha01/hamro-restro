import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared Dio client for newly integrated features (the ApiClient/Service
/// convention) — kept separate from [DioClient]/[AuthRepository], which
/// remain the networking stack for Auth/Orders/Tables.
///
/// The bearer token is cached in memory for the interceptor and persisted
/// via [SharedPreferences] so it survives app restarts. Call [init] once at
/// startup (after auth restores its session) before making authenticated
/// calls through [instance].
class ApiClient {
  ApiClient._();

  static const String baseUrl = 'http://192.168.1.27:8002/api';

  /// Host only (no `/api` suffix) — for resolving relative media URLs like
  /// `restaurantLogoId.url` ("/uploads/...") into a full, loadable URL.
  static const String mediaBaseUrl = 'http://192.168.1.27:8002';

  static const String _tokenKey = 'auth_token';

  static String? _cachedToken;
  static Dio? _dio;

  static Dio get instance {
    return _dio ??= Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.addAll([
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final token = _cachedToken;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
        if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
      ]);
  }

  /// Restores the persisted token into memory. Safe to call multiple times.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
  }

  static Future<void> setAuthToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearAuthToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
