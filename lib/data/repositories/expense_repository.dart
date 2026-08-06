import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/expense/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();

  Future<Expense> createExpense({
    required String title,
    required String categoryId,
    required double amount,
    required String expenseDate,
    required String paymentDate,
    required String dueDate,
    required String paymentStatus,
    required String paymentMethodId,
    String? description,
  });

  Future<void> deleteExpense(String id);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final Dio _dio;

  ExpenseRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Expense>> getExpenses() async {
    try {
      final response = await _dio.get(ApiConstants.expenses, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Expense> createExpense({
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
    try {
      final response = await _dio.post(
        ApiConstants.expenses,
        data: {
          'title': title,
          'categoryId': categoryId,
          'amount': amount,
          'expense_date': expenseDate,
          'payment_date': paymentDate,
          'due_date': dueDate,
          'payment_status': paymentStatus,
          'paymentMethodId': paymentMethodId,
          if (description != null && description.isNotEmpty) 'description': description,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['title'] != null) return Expense.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by title+amount.
      final expenses = await getExpenses();
      final matches = expenses.where((e) => e.title == title && e.amount == amount).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Expense was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await _dio.delete('${ApiConstants.expenses}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
