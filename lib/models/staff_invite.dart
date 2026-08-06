import 'package:flutter/material.dart';

/// The permission role assigned to an invited staff member.
enum StaffRole { admin, billing, kitchen, server, superAdmin }

extension StaffRoleDetails on StaffRole {
  String get label {
    switch (this) {
      case StaffRole.admin:
        return 'Admin';
      case StaffRole.billing:
        return 'Billing';
      case StaffRole.kitchen:
        return 'Kitchen';
      case StaffRole.server:
        return 'Server';
      case StaffRole.superAdmin:
        return 'SuperAdmin';
    }
  }

  String get description {
    switch (this) {
      case StaffRole.admin:
        return 'Managing all restaurant operations, including orders, menus, inventory, finance, and settings.';
      case StaffRole.billing:
        return 'Handling customer orders, checkouts, and manages general finances.';
      case StaffRole.kitchen:
        return 'Managing dishes, menus, and incoming orders.';
      case StaffRole.server:
        return 'Managing orders and tables for customers.';
      case StaffRole.superAdmin:
        return 'Managing the system with full and unrestricted access to all resources and actions.';
    }
  }

  /// Shared per-role accent color, used for role badges/chips/icons
  /// everywhere a staff member's role is shown (Invite Staff's role picker,
  /// the Staff detail/Change Role screens, ...).
  Color get color {
    switch (this) {
      case StaffRole.admin:
        return const Color(0xFFF4A340);
      case StaffRole.billing:
        return const Color(0xFF3FAE6A);
      case StaffRole.kitchen:
        return const Color(0xFFFF9800);
      case StaffRole.server:
        return const Color(0xFFDC3939);
      case StaffRole.superAdmin:
        return const Color(0xFF3B5FE0);
    }
  }

  IconData get icon {
    switch (this) {
      case StaffRole.admin:
        return Icons.view_in_ar_outlined;
      case StaffRole.billing:
        return Icons.flag_outlined;
      case StaffRole.kitchen:
        return Icons.person_outline;
      case StaffRole.server:
        return Icons.coffee_outlined;
      case StaffRole.superAdmin:
        return Icons.camera_outlined;
    }
  }
}
