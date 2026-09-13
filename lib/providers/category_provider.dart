import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/category/category_model.dart';
import '../data/repositories/category_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the menu category list, shared by the Manage screen's
/// Category tab and any dish-creation category picker.
class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider({required CategoryRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<MenuCategory> categories = [];
  String? errorMessage;

  bool isCreating = false;
  String? createErrorMessage;

  Future<void> fetchCategories() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      categories = await _repository.getCategories();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Creates a category and appends it to [categories] on success. Returns
  /// the created [MenuCategory], or `null` if the call failed (see
  /// [createErrorMessage]).
  Future<MenuCategory?> createCategory({required String categoryName, String? image}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final category = await _repository.createCategory(categoryName: categoryName, image: image);
      categories = [...categories, category];
      return category;
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

  /// Updates a category and replaces it in [categories] on success. Returns
  /// the updated [MenuCategory], or `null` if the call failed (see
  /// [updateErrorMessage]).
  Future<MenuCategory?> updateCategory({required String id, required String categoryName, String? image}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final category = await _repository.updateCategory(id: id, categoryName: categoryName, image: image);
      categories = categories.map((c) => c.id == id ? category : c).toList();
      return category;
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

  /// Deletes a category and removes it from [categories] on success. Returns
  /// whether the call succeeded (see [deleteErrorMessage] on failure).
  Future<bool> deleteCategory(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteCategory(id);
      categories = categories.where((c) => c.id != id).toList();
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

  CategoryStats? categoryStats;
  LoadStatus categoryStatsStatus = LoadStatus.idle;
  String? categoryStatsError;

  Future<void> fetchCategoryStats() async {
    categoryStatsStatus = LoadStatus.loading;
    categoryStatsError = null;
    notifyListeners();

    try {
      categoryStats = await _repository.getCategoryStats();
      categoryStatsStatus = LoadStatus.loaded;
    } on ApiException catch (e) {
      categoryStatsError = e.message;
      categoryStatsStatus = LoadStatus.error;
    }
    notifyListeners();
  }
}
