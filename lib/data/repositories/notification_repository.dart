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
}

class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;

  NotificationRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notifications, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>;
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
}
