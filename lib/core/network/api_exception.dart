import 'package:dio/dio.dart';

/// Normalized error surfaced to repositories/providers for any failed API
/// call. [message] is always human-readable text ready to show in the UI,
/// already unwrapped from the backend's `{statusCode, message}` error body
/// or from a Dio connection/timeout failure.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Shared by every repository: turns a [DioException] into an [ApiException]
/// with a message ready to show directly in the UI.
ApiException mapDioError(DioException e) {
  final response = e.response;
  if (response != null && response.data is Map<String, dynamic>) {
    final body = response.data as Map<String, dynamic>;
    final message = body['message'];
    final text = message is List ? message.join(', ') : (message?.toString() ?? 'Something went wrong');
    return ApiException(text, statusCode: response.statusCode);
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const ApiException('Request timed out. Please check your connection and try again.');
    case DioExceptionType.connectionError:
      return const ApiException('Could not connect to the server. Please check your connection.');
    default:
      return const ApiException('Something went wrong. Please try again.');
  }
}
