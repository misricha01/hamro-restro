import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/category/category_model.dart';

abstract class CategoryRepository {
  Future<List<MenuCategory>> getCategories();

  Future<MenuCategory> createCategory({required String categoryName, String? image});

  Future<MenuCategory> updateCategory({required String id, required String categoryName, String? image});

  Future<void> deleteCategory(String id);
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
  Future<MenuCategory> createCategory({required String categoryName, String? image}) async {
    try {
      final response = await _dio.post(ApiConstants.menuCategories, data: {'categoryName': categoryName, if (image != null) 'image': image});
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

  @override
  Future<MenuCategory> updateCategory({required String id, required String categoryName, String? image}) async {
    try {
      // `status` is the only required field in Swagger's UpdateMenuCategoryDTO;
      // the app doesn't surface an active/inactive toggle for categories, so
      // this always keeps it active, same as TypeOfMenuRepositoryImpl's default.
      final response = await _dio.patch(
        '${ApiConstants.menuCategories}/$id',
        data: {'categoryName': categoryName, 'status': true, if (image != null) 'image': image},
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['categoryName'] != null) return MenuCategory.fromJson(raw);

      final categories = await getCategories();
      final match = categories.where((c) => c.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Category was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('${ApiConstants.menuCategories}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
