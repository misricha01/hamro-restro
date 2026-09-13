import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/dish_type/dish_type_model.dart';
import '../data/repositories/dish_type_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Dish Type list, used by [SelectDishTypeSheet] and
/// (eventually) dish creation's type assignment.
class DishTypeProvider extends ChangeNotifier {
  final DishTypeRepository _repository;

  DishTypeProvider({required DishTypeRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<DishType> dishTypes = [];
  String? errorMessage;

  bool isCreating = false;
  String? createErrorMessage;

  DishTypeCounts? dishTypeCounts;
  LoadStatus dishTypeCountsStatus = LoadStatus.idle;

  Future<void> fetchDishTypeCounts() async {
    dishTypeCountsStatus = LoadStatus.loading;
    notifyListeners();

    try {
      dishTypeCounts = await _repository.getDishTypeCounts();
      dishTypeCountsStatus = LoadStatus.loaded;
    } catch (_) {
      dishTypeCountsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> fetchDishTypes() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      dishTypes = await _repository.getDishTypes();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Creates a dish type and appends it to [dishTypes] on success. Returns
  /// the created [DishType], or `null` if the call failed (see
  /// [createErrorMessage]).
  Future<DishType?> createDishType({required String dishTypeName}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final dishType = await _repository.createDishType(dishTypeName: dishTypeName);
      dishTypes = [...dishTypes, dishType];
      return dishType;
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

  /// Updates a dish type and replaces it in [dishTypes] on success. Returns
  /// the updated [DishType], or `null` if the call failed (see
  /// [updateErrorMessage]).
  Future<DishType?> updateDishType({required String id, required String dishTypeName}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final dishType = await _repository.updateDishType(id: id, dishTypeName: dishTypeName);
      dishTypes = dishTypes.map((d) => d.id == id ? dishType : d).toList();
      return dishType;
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

  /// Deletes a dish type and removes it from [dishTypes] on success. Returns
  /// whether the call succeeded (see [deleteErrorMessage] on failure).
  Future<bool> deleteDishType(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteDishType(id);
      dishTypes = dishTypes.where((d) => d.id != id).toList();
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
