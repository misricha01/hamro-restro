import 'package:flutter/material.dart';

/// How urgently a notification channel pops up on screen.
enum NotifyPriority { low, normal, high }

extension NotifyPriorityLabel on NotifyPriority {
  String get label {
    switch (this) {
      case NotifyPriority.low:
        return 'Low';
      case NotifyPriority.normal:
        return 'Normal';
      case NotifyPriority.high:
        return 'High';
    }
  }
}

/// Alert sound played for a notification channel.
enum NotifySound { defaultSound, ting }

extension NotifySoundLabel on NotifySound {
  String get label {
    switch (this) {
      case NotifySound.defaultSound:
        return 'Default';
      case NotifySound.ting:
        return 'Ting';
    }
  }
}

/// One notification channel/event row on the Notification settings screen
/// (e.g. "New Orders", "Order Edits"). Plain UI-only model backing the
/// [NotificationChannelCard] widget's local `setState`-driven form.
class NotificationChannelData {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  NotifyPriority priority;
  NotifySound sound;
  bool pushEnabled;
  bool notifySpecificStaff;
  List<String> selectedStaff;

  NotificationChannelData({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    this.priority = NotifyPriority.normal,
    this.sound = NotifySound.defaultSound,
    this.pushEnabled = true,
    this.notifySpecificStaff = false,
    List<String>? selectedStaff,
  }) : selectedStaff = selectedStaff ?? [];

  String get audienceLabel => notifySpecificStaff && selectedStaff.isNotEmpty ? '${selectedStaff.length} Staff' : 'Everyone';
}

/// One labelled group of [NotificationChannelData] rows (e.g. "Orders &
/// Services") shown under a section header with a live item count badge.
class NotificationCategory {
  final String label;
  final List<NotificationChannelData> channels;
  NotificationCategory({required this.label, required this.channels});
}
