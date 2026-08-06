import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/expense/expense_model.dart';
import '../data/repositories/expense_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Expenses list and Add Expense form.
class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseProvider({required ExpenseRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Expense> expenses = [];
  String? errorMessage;

  Future<void> fetchExpenses() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      expenses = await _repository.getExpenses();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<Expense?> createExpense({
    required String title,
    required String categoryId,
    required double amount,
    required String expenseDate,
    required String paymentDate,
    required String dueDate,
    required String paymentStatus,
    required String paymentMethodId,
    String? description,
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final expense = await _repository.createExpense(
        title: title,
        categoryId: categoryId,
        amount: amount,
        expenseDate: expenseDate,
        paymentDate: paymentDate,
        dueDate: dueDate,
        paymentStatus: paymentStatus,
        paymentMethodId: paymentMethodId,
        description: description,
      );
      expenses = [expense, ...expenses];
      return expense;
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

  bool isDeleting = false;
  String? deleteErrorMessage;

  Future<bool> deleteExpense(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteExpense(id);
      expenses = expenses.where((e) => e.id != id).toList();
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
