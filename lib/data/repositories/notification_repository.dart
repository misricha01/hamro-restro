import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/notification/notification_model.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();

  Future<AppNotification> createNotification({
    required String title,
    required String subject,
    required String notificationMessage,
    required String type,
  });

  /// `PATCH /api/notification/read` — `MarkAsReadDto` takes a bulk
  /// `notificationIds` array, not a single id, so this accepts a list even
  /// when callers only ever mark one notification at a time.
  Future<void> markAsRead(List<String> ids);

  /// `GET /api/notification/log` — same [AppNotification] shape as
  /// [getNotifications], parsed defensively so an unexpected field layout
  /// degrades to empty/default values rather than throwing.
  Future<List<AppNotification>> getNotificationLog();

  Future<AppNotification> updateNotification({
    required String id,
    required String title,
    required String subject,
    required String notificationMessage,
    required String type,
  });

  Future<void> deleteNotification(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;

  NotificationRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notifications, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AppNotification> createNotification({
    required String title,
    required String subject,
    required String notificationMessage,
    required String type,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.notifications, data: {
        'title': title,
        'subject': subject,
        'notificationMessage': notificationMessage,
        'type': type,
      });
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return AppNotification.fromJson(raw);

      // Same "create response omits the entity" fallback as
      // DishRepositoryImpl.createDish — refetch and match by content, then
      // by highest id if more than one entry shares that content.
      final notifications = await getNotifications();
      final matches = notifications
          .where((n) => n.title == title && n.subject == subject && n.notificationMessage == notificationMessage && n.type == type)
          .toList();
      if (matches.length == 1) return matches.first;
      if (matches.isNotEmpty) {
        matches.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        return matches.first;
      }
      throw const ApiException('Notification was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> markAsRead(List<String> ids) async {
    try {
      await _dio.patch('${ApiConstants.notifications}/read', data: {'notificationIds': ids});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<AppNotification>> getNotificationLog() async {
    try {
      final response = await _dio.get('${ApiConstants.notifications}/log', queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AppNotification> updateNotification({
    required String id,
    required String title,
    required String subject,
    required String notificationMessage,
    required String type,
  }) async {
    try {
      final response = await _dio.patch('${ApiConstants.notifications}/$id', data: {
        'title': title,
        'subject': subject,
        'notificationMessage': notificationMessage,
        'type': type,
      });
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['title'] != null) return AppNotification.fromJson(raw);

      final notifications = await getNotifications();
      final match = notifications.where((n) => n.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Notification was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('${ApiConstants.notifications}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
