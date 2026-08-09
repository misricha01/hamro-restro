import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/type_of_menu/type_of_menu_model.dart';

abstract class TypeOfMenuRepository {
  Future<List<TypeOfMenu>> getTypeOfMenus();

  Future<TypeOfMenu> createTypeOfMenu({required String name, required String description, required bool status});

  Future<TypeOfMenu> updateTypeOfMenu({required String id, required String name, required String description, required bool status});

  Future<void> deleteTypeOfMenu(String id);
}

class TypeOfMenuRepositoryImpl implements TypeOfMenuRepository {
  final Dio _dio;

  TypeOfMenuRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<TypeOfMenu>> getTypeOfMenus() async {
    try {
      final response = await _dio.get(ApiConstants.typeOfMenus, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => TypeOfMenu.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _body({required String name, required String description, required bool status}) {
    return {'name': name, 'description': description, 'status': status};
  }

  @override
  Future<TypeOfMenu> createTypeOfMenu({required String name, required String description, required bool status}) async {
    try {
      final response = await _dio.post(ApiConstants.typeOfMenus, data: _body(name: name, description: description, status: status));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return TypeOfMenu.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by name.
      final types = await getTypeOfMenus();
      final matches = types.where((t) => t.name == name).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Sub-Menu was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<TypeOfMenu> updateTypeOfMenu({required String id, required String name, required String description, required bool status}) async {
    try {
      final response = await _dio.patch('${ApiConstants.typeOfMenus}/$id', data: _body(name: name, description: description, status: status));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return TypeOfMenu.fromJson(raw);

      final types = await getTypeOfMenus();
      final match = types.where((t) => t.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Sub-Menu was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteTypeOfMenu(String id) async {
    try {
      await _dio.delete('${ApiConstants.typeOfMenus}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
