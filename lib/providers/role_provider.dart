import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/staff/role_model.dart';
import '../data/repositories/role_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Staff role pickers (Create/Invite Staff, Change Role)
/// and the User Role editor (Manage > Settings > User Role), backed by
/// `/api/roles`.
class RoleProvider extends ChangeNotifier {
  final RoleRepository _repository;

  RoleProvider({required RoleRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Role> roles = [];
  String? errorMessage;

  Future<void> fetchRoles() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      roles = await _repository.getRoles();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<Role?> createRole(String name) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final role = await _repository.createRole(name);
      roles = [...roles, role];
      return role;
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

  bool isUpdating = false;
  String? updateErrorMessage;

  Future<Role?> updateRole({required String id, required String name}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final role = await _repository.updateRole(id: id, name: name);
      roles = roles.map((r) => r.id == id ? role : r).toList();
      return role;
    } on ApiException catch (e) {
      updateErrorMessage = e.message;
      return null;
    } catch (_) {
      updateErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  bool isDeleting = false;
  String? deleteErrorMessage;

  Future<bool> deleteRole(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteRole(id);
      roles = roles.where((r) => r.id != id).toList();
      return true;
    } on ApiException catch (e) {
      deleteErrorMessage = e.message;
      return false;
    } catch (_) {
      deleteErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
