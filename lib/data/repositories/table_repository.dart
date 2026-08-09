import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/orders/table_model.dart';

abstract class TableRepository {
  Future<List<RestaurantTable>> getTables();

  Future<RestaurantTable> createTable({
    required String tableName,
    String? tableType,
    int? capacity,
    String? areaId,
    double? charge,
    String tableStatus,
    bool available,
  });

  Future<RestaurantTable> updateTable({
    required String id,
    required String tableName,
    String? tableType,
    int? capacity,
    String? areaId,
    double? charge,
    required String tableStatus,
    required bool available,
  });

  Future<void> deleteTable(String id);

  /// `POST /api/table-order/move-table` — relocates [fromTableId]'s active
  /// order session onto [toTableId]. Returns the backend's own status
  /// message (e.g. "Orders moved to new table successfully", or a no-op
  /// "No active orders to move" if the source had nothing active) — the
  /// endpoint always responds `data: null` and 2xx even for the no-op case,
  /// so the message is the only way to tell the two apart.
  Future<String> moveTable({required String fromTableId, required String toTableId});

  /// `POST /api/table-order/merge-table` — combines [fromTableIds]' active
  /// order sessions onto [toTableId] (which need not be one of them).
  /// Returns the backend's status message, same caveat as [moveTable].
  Future<String> mergeTable({required List<String> fromTableIds, required String toTableId});
}

class TableRepositoryImpl implements TableRepository {
  final Dio _dio;

  TableRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<RestaurantTable>> getTables() async {
    try {
      // Tables are a restaurant's fixed physical layout — unlike order/sales
      // history, every one of them needs to stay reachable rather than just
      // the most recent 50, so this uses a much higher ceiling than other
      // paginated list endpoints in the app.
      final response = await _dio.get(ApiConstants.tables, queryParameters: {'page': 1, 'take': 200});
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => RestaurantTable.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<RestaurantTable> createTable({
    required String tableName,
    String? tableType,
    int? capacity,
    String? areaId,
    double? charge,
    String tableStatus = 'Open',
    bool available = true,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.tables,
        data: {
          'tableName': tableName,
          'tableType': tableType,
          'capacity': capacity,
          'areaId': areaId,
          'charge': charge,
          'tableStatus': tableStatus,
          'available': available,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) {
        return RestaurantTable.fromJson(raw);
      }

      // Same fallback as AreaRepositoryImpl.createArea — the create response
      // doesn't always include the created entity, even on success.
      final tables = await getTables();
      final matches = tables.where((t) => t.tableName == tableName).toList();
      if (matches.length == 1) return matches.first;
      if (matches.isNotEmpty) {
        // More than one Table shares this name — best-effort tiebreak by
        // numeric id (works for auto-increment ids; falls back to the last
        // list entry if ids aren't numeric).
        matches.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        return matches.first;
      }
      throw const ApiException('Table was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<RestaurantTable> updateTable({
    required String id,
    required String tableName,
    String? tableType,
    int? capacity,
    String? areaId,
    double? charge,
    required String tableStatus,
    required bool available,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.tables}/$id',
        data: {
          'tableName': tableName,
          'tableType': tableType,
          'capacity': capacity,
          'areaId': areaId,
          'charge': charge,
          'tableStatus': tableStatus,
          'available': available,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return RestaurantTable.fromJson(raw);

      // Same "response omits the updated entity" situation as createTable —
      // the call still succeeded, so refetch and match by id.
      final tables = await getTables();
      final match = tables.where((t) => t.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Table was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteTable(String id) async {
    try {
      await _dio.delete('${ApiConstants.tables}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<String> moveTable({required String fromTableId, required String toTableId}) async {
    try {
      final response = await _dio.post(
        ApiConstants.moveTable,
        data: {'fromTableId': fromTableId, 'toTableId': toTableId},
      );
      return response.data['message'] as String? ?? 'Table moved';
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<String> mergeTable({required List<String> fromTableIds, required String toTableId}) async {
    try {
      final response = await _dio.post(
        ApiConstants.mergeTable,
        data: {'fromTableIds': fromTableIds, 'toTableId': toTableId},
      );
      return response.data['message'] as String? ?? 'Tables merged';
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
