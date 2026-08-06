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
  Future<MenuCategory?> createCategory({required String categoryName}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final category = await _repository.createCategory(categoryName: categoryName);
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
}
