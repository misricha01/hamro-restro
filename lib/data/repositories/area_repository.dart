import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/area/area_model.dart';

abstract class AreaRepository {
  Future<List<Area>> getAreas();

  Future<Area> createArea({required String areaName, String? description});

  Future<Area> updateArea({required String id, required String areaName, String? description});

  Future<void> deleteArea(String id);
}

class AreaRepositoryImpl implements AreaRepository {
  final Dio _dio;

  AreaRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Area>> getAreas() async {
    try {
      final response = await _dio.get(ApiConstants.areas);
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Area.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Area> createArea({required String areaName, String? description}) async {
    try {
      final response = await _dio.post(ApiConstants.areas, data: {'areaName': areaName, 'description': description});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) {
        return Area.fromJson(raw);
      }

      // The backend's create response doesn't always include the created
      // entity (just `{status, message, data: null}`) — the call still
      // succeeded (2xx), so fall back to refetching and matching by name
      // rather than surfacing a false failure.
      final areas = await getAreas();
      final matches = areas.where((a) => a.areaName == areaName).toList();
      if (matches.length == 1) return matches.first;
      if (matches.isNotEmpty) {
        // More than one Space shares this name — best-effort tiebreak by
        // numeric id (works for auto-increment ids; falls back to the last
        // list entry if ids aren't numeric).
        matches.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        return matches.first;
      }
      throw const ApiException('Space was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Area> updateArea({required String id, required String areaName, String? description}) async {
    try {
      final response = await _dio.patch('${ApiConstants.areas}/$id', data: {'areaName': areaName, 'description': description});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return Area.fromJson(raw);

      // Same "response omits the updated entity" situation as createArea —
      // the call still succeeded, so build the result from what we sent.
      return Area(id: id, areaName: areaName, description: description);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteArea(String id) async {
    try {
      await _dio.delete('${ApiConstants.areas}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
