import 'package:flutter/material.dart';
import '../data/models/staff/role_model.dart';
import 'role_style.dart';

/// One role card shown on the User Role screen, wrapping a real [Role]
/// (backend: `/api/roles`) with its computed [totalUsers] (from
/// [StaffProvider]) and display color/icon (from [role_style]).
class UserRoleEntry {
  final Role role;
  final int totalUsers;

  UserRoleEntry({required this.role, required this.totalUsers});

  String get name => role.name;
  Color get color => roleColorFor(role.name);
  IconData get icon => roleIconFor(role.name);
}
