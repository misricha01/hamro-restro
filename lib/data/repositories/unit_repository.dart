import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/unit/unit_model.dart';

abstract class UnitRepository {
  Future<List<Unit>> getUnits();

  Future<Unit> createUnit({required String name, String? description});

  Future<Unit> updateUnit({required String id, required String name, String? description});

  Future<void> deleteUnit(String id);
}

class UnitRepositoryImpl implements UnitRepository {
  final Dio _dio;

  UnitRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Unit>> getUnits() async {
    try {
      final response = await _dio.get(ApiConstants.units, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => Unit.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _body({required String name, String? description}) {
    return {'name': name, if (description != null && description.isNotEmpty) 'description': description};
  }

  @override
  Future<Unit> createUnit({required String name, String? description}) async {
    try {
      final response = await _dio.post(ApiConstants.units, data: _body(name: name, description: description));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return Unit.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by name.
      final units = await getUnits();
      final matches = units.where((u) => u.name == name).toList()
        ..sort((a, b) => (int.tryParse(b.id ?? '0') ?? 0).compareTo(int.tryParse(a.id ?? '0') ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Unit was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Unit> updateUnit({required String id, required String name, String? description}) async {
    try {
      final response = await _dio.patch('${ApiConstants.units}/$id', data: _body(name: name, description: description));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return Unit.fromJson(raw);

      final units = await getUnits();
      final match = units.where((u) => u.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Unit was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteUnit(String id) async {
    try {
      await _dio.delete('${ApiConstants.units}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
