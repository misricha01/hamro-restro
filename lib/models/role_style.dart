import 'package:flutter/material.dart';
import 'staff_invite.dart' show StaffRole, StaffRoleDetails;

/// Fallback palette for role names that don't match one of the 5 built-in
/// [StaffRole] labels (this backend allows arbitrary per-restaurant roles,
/// e.g. "waiter-group"). Picked deterministically by name so the same role
/// always renders the same color.
const List<Color> _rolePalette = [
  Color(0xFF3B5FE0),
  Color(0xFF3FAE6A),
  Color(0xFFF4A340),
  Color(0xFFDC3939),
  Color(0xFF8E6CD9),
  Color(0xFF2AA8B0),
];

const List<IconData> _roleIconPalette = [
  Icons.badge_outlined,
  Icons.flag_outlined,
  Icons.person_outline,
  Icons.coffee_outlined,
  Icons.shield_outlined,
  Icons.storefront_outlined,
];

StaffRole? _matchBuiltIn(String roleName) {
  final normalized = roleName.trim().toLowerCase();
  for (final role in StaffRole.values) {
    if (role.label.toLowerCase() == normalized || role.name.toLowerCase() == normalized) return role;
  }
  return null;
}

/// Display color for an arbitrary role name string — reuses the built-in
/// [StaffRole] palette when [roleName] matches one of the 5 known labels,
/// otherwise a deterministic hash-based fallback.
Color roleColorFor(String roleName) {
  final builtIn = _matchBuiltIn(roleName);
  if (builtIn != null) return builtIn.color;
  if (roleName.isEmpty) return _rolePalette.first;
  return _rolePalette[roleName.hashCode.abs() % _rolePalette.length];
}

/// Display icon for an arbitrary role name string — see [roleColorFor].
IconData roleIconFor(String roleName) {
  final builtIn = _matchBuiltIn(roleName);
  if (builtIn != null) return builtIn.icon;
  if (roleName.isEmpty) return _roleIconPalette.first;
  return _roleIconPalette[roleName.hashCode.abs() % _roleIconPalette.length];
}
