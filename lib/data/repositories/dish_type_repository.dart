import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/dish_type/dish_type_model.dart';

abstract class DishTypeRepository {
  Future<List<DishType>> getDishTypes();

  Future<DishType> createDishType({required String dishTypeName});
}

class DishTypeRepositoryImpl implements DishTypeRepository {
  final Dio _dio;

  DishTypeRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<DishType>> getDishTypes() async {
    try {
      final response = await _dio.get(ApiConstants.dishTypes);
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => DishType.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<DishType> createDishType({required String dishTypeName}) async {
    try {
      final response = await _dio.post(ApiConstants.dishTypes, data: {'dishTypeName': dishTypeName});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) {
        return DishType.fromJson(raw);
      }

      // Some create endpoints in this backend don't return the created
      // entity (just `{status, message, data: null}`) — the call still
      // succeeded (2xx), so fall back to refetching and matching by name
      // rather than surfacing a false failure. See AreaRepositoryImpl.
      final dishTypes = await getDishTypes();
      final matches = dishTypes.where((d) => d.dishTypeName == dishTypeName).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Dish Type was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
