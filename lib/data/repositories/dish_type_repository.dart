import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/dish_type/dish_type_model.dart';

class DishTypeCounts {
  final int total;
  final int active;

  const DishTypeCounts({required this.total, required this.active});
}

abstract class DishTypeRepository {
  Future<List<DishType>> getDishTypes();

  Future<DishType> createDishType({required String dishTypeName});

  Future<DishType> updateDishType({required String id, required String dishTypeName});

  Future<void> deleteDishType(String id);

  Future<DishTypeCounts> getDishTypeCounts();
}

class DishTypeRepositoryImpl implements DishTypeRepository {
  final Dio _dio;

  DishTypeRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<DishType>> getDishTypes() async {
    try {
      final response = await _dio.get(ApiConstants.dishTypes);
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => DishType.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<DishType> createDishType({required String dishTypeName}) async {
    try {
      // Confirmed live: the backend's CreateDishTypeDto field is `name`,
      // not `dishTypeName` (400 "property dishTypeName should not exist").
      final response = await _dio.post(ApiConstants.dishTypes, data: {'name': dishTypeName});
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

  @override
  Future<DishType> updateDishType({required String id, required String dishTypeName}) async {
    try {
      final response = await _dio.patch('${ApiConstants.dishTypes}/$id', data: {'name': dishTypeName});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return DishType.fromJson(raw);

      final dishTypes = await getDishTypes();
      final match = dishTypes.where((d) => d.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Dish Type was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteDishType(String id) async {
    try {
      await _dio.delete('${ApiConstants.dishTypes}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<DishTypeCounts> getDishTypeCounts() async {
    try {
      final results = await Future.wait([
        _dio.get('${ApiConstants.dishTypes}/count/total'),
        _dio.get('${ApiConstants.dishTypes}/count/active'),
      ]);
      return DishTypeCounts(total: _parseCount(results[0].data['data']), active: _parseCount(results[1].data['data']));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  static int _parseCount(dynamic raw) {
    if (raw is num) return raw.toInt();
    if (raw is Map<String, dynamic>) {
      final value = raw['count'] ?? raw['total'] ?? raw['activeCount'] ?? (raw.values.isNotEmpty ? raw.values.first : null);
      if (value is num) return value.toInt();
    }
    return 0;
  }
}
