/// KOT reference attached to order-related notifications (e.g. "Order
/// created"). Only present on some `GET /api/notification` entries.
class NotificationKot {
  final String id;
  final String kotNumber;
  final String status;

  const NotificationKot({required this.id, required this.kotNumber, required this.status});

  factory NotificationKot.fromJson(Map<String, dynamic> json) {
    return NotificationKot(
      id: json['id'].toString(),
      kotNumber: json['kotNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

/// Named `AppNotification` (not `Notification`) to avoid colliding with
/// Flutter's own `Notification` widget class.
class AppNotification {
  final String id;
  final String title;
  final String subject;
  final String notificationMessage;
  final String type;
  final bool status;
  final DateTime createdAt;
  final NotificationKot? kot;

  const AppNotification({
    required this.id,
    required this.title,
    required this.subject,
    required this.notificationMessage,
    required this.type,
    required this.status,
    required this.createdAt,
    this.kot,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      notificationMessage: json['notificationMessage'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      kot: json['kot'] is Map<String, dynamic> ? NotificationKot.fromJson(json['kot'] as Map<String, dynamic>) : null,
    );
  }
}
