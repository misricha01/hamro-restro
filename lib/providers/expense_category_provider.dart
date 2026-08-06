import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/expense/expense_model.dart';
import '../data/repositories/expense_category_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Expense Category picker (Add Expense).
class ExpenseCategoryProvider extends ChangeNotifier {
  final ExpenseCategoryRepository _repository;

  ExpenseCategoryProvider({required ExpenseCategoryRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<ExpenseCategory> categories = [];
  String? errorMessage;

  Future<void> fetchExpenseCategories() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      categories = await _repository.getExpenseCategories();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<ExpenseCategory?> createExpenseCategory({required String name, String? description}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final category = await _repository.createExpenseCategory(name: name, description: description);
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
