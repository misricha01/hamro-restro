import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/table_activity/table_activity_model.dart';

abstract class TableActivityRepository {
  /// `GET /api/table-activity`. No `tableId` filter exists on the backend
  /// (only `page/take/searchTerm/isActive`), so this fetches a page and
  /// callers filter client-side by `entry.table?.id`.
  Future<List<TableActivityEntry>> getTableActivity({int page = 1, int take = 200});
}

class TableActivityRepositoryImpl implements TableActivityRepository {
  final Dio _dio;

  TableActivityRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<TableActivityEntry>> getTableActivity({int page = 1, int take = 200}) async {
    try {
      final response = await _dio.get(ApiConstants.tableActivity, queryParameters: {'page': page, 'take': take});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => TableActivityEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
