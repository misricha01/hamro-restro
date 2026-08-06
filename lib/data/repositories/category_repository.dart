import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/category/category_model.dart';

abstract class CategoryRepository {
  Future<List<MenuCategory>> getCategories();

  Future<MenuCategory> createCategory({required String categoryName});
}

class CategoryRepositoryImpl implements CategoryRepository {
  final Dio _dio;

  CategoryRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<MenuCategory>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.menuCategories);
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => MenuCategory.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<MenuCategory> createCategory({required String categoryName}) async {
    try {
      final response = await _dio.post(ApiConstants.menuCategories, data: {'categoryName': categoryName});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) {
        return MenuCategory.fromJson(raw);
      }

      // Some create endpoints in this backend don't return the created
      // entity (just `{status, message, data: null}`) — the call still
      // succeeded (2xx), so fall back to refetching and matching by name
      // rather than surfacing a false failure. See AreaRepositoryImpl.
      final categories = await getCategories();
      final matches = categories.where((c) => c.categoryName == categoryName).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Category was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
