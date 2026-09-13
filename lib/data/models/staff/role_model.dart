/// A per-restaurant role (backend: `/api/roles`), e.g. "admin",
/// "waiter-group". Freely creatable per tenant — not the fixed 5-role list
/// the UI used to assume.
class Role {
  final String id;
  final String name;

  const Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    // `GET /api/roles` never returns an `id` field — confirmed live, the
    // response is only `{restaurantId, name}`. This resource is keyed by
    // `name` (also what `PATCH`/`DELETE /api/roles/{id}` actually expect),
    // so use it as the identifier instead of the nonexistent `id`.
    final name = json['name'] as String? ?? '';
    return Role(id: name, name: name);
  }
}

/// One `role -> route -> permission` grant (backend: `GET /api/rbac/all`),
/// used both to render a role's read-only permission list on the Staff
/// detail / Change Role / Permission Details screens, and to build the
/// editable Route x Permission matrix on the User Role editor. [id] is only
/// present on entries read back from the API (needed to target
/// `DELETE /api/rbac/bulk`) — absent on ones we construct locally to send.
class RbacEntry {
  final String? id;
  final String role;
  final String route;
  final String permission;

  const RbacEntry({this.id, required this.role, required this.route, required this.permission});

  factory RbacEntry.fromJson(Map<String, dynamic> json) {
    return RbacEntry(
      id: json['id']?.toString(),
      role: json['role'] as String? ?? '',
      route: json['route'] as String? ?? '',
      permission: json['permission'] as String? ?? '',
    );
  }
}

/// A shared RBAC route name (e.g. "user", "order", "dish") — the vocabulary
/// every role's permissions are granted against. Backend: `/api/routes`.
class ApiRoute {
  final String id;
  final String name;

  const ApiRoute({required this.id, required this.name});

  factory ApiRoute.fromJson(Map<String, dynamic> json) {
    return ApiRoute(id: json['id'].toString(), name: json['name'] as String? ?? '');
  }
}
