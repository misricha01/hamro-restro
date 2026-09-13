import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/expense/expense_model.dart';

abstract class ExpenseCategoryRepository {
  Future<List<ExpenseCategory>> getExpenseCategories();

  Future<ExpenseCategory> createExpenseCategory({required String name, String? description});

  Future<ExpenseCategory> updateExpenseCategory({required String id, required String name, String? description});

  Future<void> deleteExpenseCategory(String id);
}

class ExpenseCategoryRepositoryImpl implements ExpenseCategoryRepository {
  final Dio _dio;

  ExpenseCategoryRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    try {
      final response = await _dio.get(ApiConstants.expenseCategories, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => ExpenseCategory.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<ExpenseCategory> createExpenseCategory({required String name, String? description}) async {
    try {
      final response = await _dio.post(
        ApiConstants.expenseCategories,
        data: {'name': name, if (description != null && description.isNotEmpty) 'description': description},
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return ExpenseCategory.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by name.
      final categories = await getExpenseCategories();
      final matches = categories.where((c) => c.name == name).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Expense category was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<ExpenseCategory> updateExpenseCategory({required String id, required String name, String? description}) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.expenseCategories}/$id',
        data: {'name': name, if (description != null && description.isNotEmpty) 'description': description},
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return ExpenseCategory.fromJson(raw);

      final categories = await getExpenseCategories();
      final match = categories.where((c) => c.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Expense category was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteExpenseCategory(String id) async {
    try {
      await _dio.delete('${ApiConstants.expenseCategories}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
