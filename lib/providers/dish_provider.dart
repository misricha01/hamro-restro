import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/dish/dish_model.dart';
import '../data/repositories/dish_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Manage screen's "Dishes" list and the Add/Edit Dish
/// form. `unitId`, `variantIds`, `addonIds` and `stockConsumptions` are
/// optional, so create/update work without them in the meantime — see
/// [DishRepository].
class DishProvider extends ChangeNotifier {
  final DishRepository _repository;

  DishProvider({required DishRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Dish> dishes = [];
  String? errorMessage;

  Future<void> fetchDishes() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      dishes = await _repository.getDishes();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  DishStats? dishStats;
  LoadStatus dishStatsStatus = LoadStatus.idle;
  String? dishStatsError;

  Future<void> fetchDishStats() async {
    dishStatsStatus = LoadStatus.loading;
    dishStatsError = null;
    notifyListeners();

    try {
      dishStats = await _repository.getDishStats();
      dishStatsStatus = LoadStatus.loaded;
    } on ApiException catch (e) {
      dishStatsError = e.message;
      dishStatsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  /// `GET /api/dish/{id}/transactions` — not cached on the provider since
  /// it's only ever needed transiently by [DishTransactionsSheet].
  Future<List<DishTransaction>> getDishTransactions(String dishId) {
    return _repository.getDishTransactions(dishId);
  }

  bool isCreating = false;
  String? createErrorMessage;

  /// Creates a dish and appends it to [dishes] on success. Returns the
  /// created [Dish], or `null` if the call failed (see [createErrorMessage]).
  Future<Dish?> createDish({
    required String dishName,
    String? hsCode,
    String? dishPhoto,
    String? description,
    double? price,
    String? unitId,
    double? cogs,
    String? discountType,
    double? discount,
    double? priceAfterDiscount,
    List<String> variantIds = const [],
    List<String> addonIds = const [],
    required String dishTypeId,
    String? typeOfMenuId,
    required String menuCategoryId,
    bool available = true,
    List<DishStockConsumption> stockConsumptions = const [],
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final dish = await _repository.createDish(
        dishName: dishName,
        hsCode: hsCode,
        dishPhoto: dishPhoto,
        description: description,
        price: price,
        unitId: unitId,
        cogs: cogs,
        discountType: discountType,
        discount: discount,
        priceAfterDiscount: priceAfterDiscount,
        variantIds: variantIds,
        addonIds: addonIds,
        dishTypeId: dishTypeId,
        typeOfMenuId: typeOfMenuId,
        menuCategoryId: menuCategoryId,
        available: available,
        stockConsumptions: stockConsumptions,
      );
      dishes = [...dishes, dish];
      return dish;
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

  /// Updates a dish and replaces it in [dishes] on success. Returns the
  /// updated [Dish], or `null` if the call failed (see [updateErrorMessage]).
  Future<Dish?> updateDish({
    required String id,
    required String dishName,
    String? hsCode,
    String? dishPhoto,
    String? description,
    double? price,
    String? unitId,
    double? cogs,
    String? discountType,
    double? discount,
    double? priceAfterDiscount,
    List<String> variantIds = const [],
    List<String> addonIds = const [],
    required String dishTypeId,
    String? typeOfMenuId,
    required String menuCategoryId,
    required bool available,
    List<DishStockConsumption> stockConsumptions = const [],
  }) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final dish = await _repository.updateDish(
        id: id,
        dishName: dishName,
        hsCode: hsCode,
        dishPhoto: dishPhoto,
        description: description,
        price: price,
        unitId: unitId,
        cogs: cogs,
        discountType: discountType,
        discount: discount,
        priceAfterDiscount: priceAfterDiscount,
        variantIds: variantIds,
        addonIds: addonIds,
        dishTypeId: dishTypeId,
        typeOfMenuId: typeOfMenuId,
        menuCategoryId: menuCategoryId,
        available: available,
        stockConsumptions: stockConsumptions,
      );
      dishes = dishes.map((d) => d.id == id ? dish : d).toList();
      return dish;
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

  /// Deletes a dish and removes it from [dishes] on success. Returns
  /// whether the call succeeded (see [deleteErrorMessage] on failure).
  Future<bool> deleteDish(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteDish(id);
      dishes = dishes.where((d) => d.id != id).toList();
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
