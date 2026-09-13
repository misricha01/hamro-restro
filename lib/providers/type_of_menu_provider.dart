import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/type_of_menu/type_of_menu_model.dart';
import '../data/repositories/type_of_menu_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Sub-Menu picker/list (Add Dish's Sub-Menu field, Manage
/// > Menu > Sub Menu).
class TypeOfMenuProvider extends ChangeNotifier {
  final TypeOfMenuRepository _repository;

  TypeOfMenuProvider({required TypeOfMenuRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<TypeOfMenu> types = [];
  String? errorMessage;

  Future<void> fetchTypeOfMenus() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      types = await _repository.getTypeOfMenus();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  TypeOfMenuStats? typeOfMenuStats;
  LoadStatus typeOfMenuStatsStatus = LoadStatus.idle;
  String? typeOfMenuStatsError;

  Future<void> fetchTypeOfMenuStats() async {
    typeOfMenuStatsStatus = LoadStatus.loading;
    typeOfMenuStatsError = null;
    notifyListeners();

    try {
      typeOfMenuStats = await _repository.getTypeOfMenuStats();
      typeOfMenuStatsStatus = LoadStatus.loaded;
    } on ApiException catch (e) {
      typeOfMenuStatsError = e.message;
      typeOfMenuStatsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<TypeOfMenu?> createTypeOfMenu({required String name, required String description, bool status = true}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final type = await _repository.createTypeOfMenu(name: name, description: description, status: status);
      types = [...types, type];
      return type;
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

  /// Updates a sub-menu and replaces it in [types] on success. Returns the
  /// updated [TypeOfMenu], or `null` if the call failed (see
  /// [updateErrorMessage]).
  Future<TypeOfMenu?> updateTypeOfMenu({required String id, required String name, required String description, required bool status}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final type = await _repository.updateTypeOfMenu(id: id, name: name, description: description, status: status);
      types = types.map((t) => t.id == id ? type : t).toList();
      return type;
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

  /// Deletes a sub-menu and removes it from [types] on success. Returns
  /// whether the call succeeded (see [deleteErrorMessage] on failure).
  Future<bool> deleteTypeOfMenu(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteTypeOfMenu(id);
      types = types.where((t) => t.id != id).toList();
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
