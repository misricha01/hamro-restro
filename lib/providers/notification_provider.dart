import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/notification/notification_model.dart';
import '../data/repositories/notification_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for [NotificationScreen]'s Order / Activity Log tabs — both
/// read from the same `GET /api/notification` list and split it client-side
/// by [AppNotification.type] rather than hitting two endpoints.
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider({required NotificationRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<AppNotification> notifications = [];
  String? errorMessage;

  List<AppNotification> get orderNotifications => notifications.where((n) => n.type == 'order').toList();

  List<AppNotification> get activityNotifications => notifications.where((n) => n.type != 'order').toList();

  Future<void> fetchNotifications() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      notifications = await _repository.getNotifications();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<AppNotification?> createNotification({
    required String title,
    required String subject,
    required String notificationMessage,
    required String type,
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final notification = await _repository.createNotification(
        title: title,
        subject: subject,
        notificationMessage: notificationMessage,
        type: type,
      );
      notifications = [notification, ...notifications];
      return notification;
    } on ApiException catch (e) {
      createErrorMessage = e.message;
      return null;
    } catch (_) {
      createErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  final Set<String> _markingAsRead = {};
  String? markAsReadErrorMessage;

  bool isMarkingAsRead(String id) => _markingAsRead.contains(id);

  /// Marks [id] as read (`PATCH /api/notification/read`) then silently
  /// re-syncs [notifications] in the background — the backend doesn't echo
  /// an updated read-state field on [AppNotification] we could flip
  /// locally, so a refetch is the only way to reflect the real server
  /// state. Uses [_repository] directly rather than [fetchNotifications] so
  /// [status] (and the loading spinner it drives) isn't disturbed for what
  /// should feel like a silent background update. Returns whether the mark
  /// itself succeeded.
  Future<bool> markNotificationAsRead(String id) async {
    _markingAsRead.add(id);
    markAsReadErrorMessage = null;
    notifyListeners();

    try {
      await _repository.markAsRead([id]);
      try {
        notifications = await _repository.getNotifications();
        notifyListeners();
      } catch (_) {
        // Best-effort resync — the mark itself already succeeded above, so
        // don't surface this as a failure to the caller.
      }
      return true;
    } on ApiException catch (e) {
      markAsReadErrorMessage = e.message;
      return false;
    } catch (_) {
      markAsReadErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _markingAsRead.remove(id);
      notifyListeners();
    }
  }
}
