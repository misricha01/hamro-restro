import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/staff/staff_member_model.dart';
import '../data/repositories/rbac_repository.dart';
import '../data/repositories/staff_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Staff list/detail, Create/Invite Staff forms and
/// Change Role, backed by `/api/user`, `/api/restaurant/create-account`
/// and `/api/rbac/assign-role`.
class StaffProvider extends ChangeNotifier {
  final StaffRepository _repository;
  final RbacRepository _rbacRepository;

  StaffProvider({required StaffRepository repository, required RbacRepository rbacRepository})
    : _repository = repository,
      _rbacRepository = rbacRepository;

  LoadStatus status = LoadStatus.idle;
  List<StaffMember> staff = [];
  String? errorMessage;

  Future<void> fetchStaff() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      staff = await _repository.getStaff();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  /// Creates a staff account and appends it to [staff] on success. Returns
  /// the created [StaffMember], or `null` if the call failed (see
  /// [createErrorMessage]). [role], if given, also assigns the RBAC group so
  /// the account's permissions match immediately.
  Future<StaffMember?> createStaff({
    required String fullname,
    required String email,
    required String password,
    required String position,
    String? role,
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final member = await _repository.createStaff(
        fullname: fullname,
        email: email,
        password: password,
        position: position,
        role: role,
      );
      if (role != null && role.isNotEmpty) {
        try {
          await _rbacRepository.assignRole(userId: member.id, roleName: role);
        } on ApiException {
          // Account creation already succeeded — a failed role assignment
          // shouldn't be reported as a failed staff creation. It can be
          // retried from Change Role.
        }
      }
      staff = [...staff, member];
      return member;
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

  Future<StaffMember?> updateStaff({
    required String id,
    String? fullname,
    String? email,
    String? position,
  }) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final member = await _repository.updateStaff(id: id, fullname: fullname, email: email, position: position);
      staff = staff.map((s) => s.id == id ? member : s).toList();
      return member;
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

  Future<bool> deleteStaff(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteStaff(id);
      staff = staff.where((s) => s.id != id).toList();
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

  bool isAssigningRole = false;
  String? assignRoleErrorMessage;

  /// Assigns [roleName] to staff member [id] via RBAC and updates the local
  /// [staff] entry's displayed role. Returns whether it succeeded.
  Future<bool> assignRole({required String id, required String roleName}) async {
    isAssigningRole = true;
    assignRoleErrorMessage = null;
    notifyListeners();

    try {
      await _rbacRepository.assignRole(userId: id, roleName: roleName);
      staff = staff.map((s) {
        if (s.id != id) return s;
        return StaffMember(
          id: s.id,
          restaurantId: s.restaurantId,
          fullname: s.fullname,
          email: s.email,
          role: roleName,
          position: s.position,
          isDefaultAdmin: s.isDefaultAdmin,
          status: s.status,
          createdAt: s.createdAt,
        );
      }).toList();
      return true;
    } on ApiException catch (e) {
      assignRoleErrorMessage = e.message;
      return false;
    } catch (_) {
      assignRoleErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isAssigningRole = false;
      notifyListeners();
    }
  }
}
