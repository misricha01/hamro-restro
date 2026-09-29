import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'dio_client.dart';

/// Backwards-compatibility bridge for `ApiClient`.
/// Preserves `ApiClient.mediaBaseUrl` and `ApiClient.instance` so that
/// image pickers and legacy references compile without breaking, while
/// routing network traffic through the secure [DioClient].
class ApiClient {
  ApiClient._();

  /// Media base URL for resolving uploaded image paths (`/uploads/...`)
  static String get mediaBaseUrl => ApiConstants.mediaBaseUrl;

  /// Returns the shared, interceptor-enabled [Dio] instance from [DioClient].
  static Dio get instance => DioClient.instance.dio;
}
