import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/table_order/table_order_session.dart';

abstract class TableOrderRepository {
  /// `GET /api/table-order`. [tableStatus] filters by `active` / `completed`
  /// / `cancelled` per Swagger's documented query params; omit to fetch
  /// every status. Only the first page (50 items) is fetched -- this
  /// endpoint is for a live "what's happening right now" view, not a full
  /// paginated history browse.
  Future<List<TableOrderSession>> getTableOrders({String? tableStatus});
}

class TableOrderRepositoryImpl implements TableOrderRepository {
  final Dio _dio;

  TableOrderRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<TableOrderSession>> getTableOrders({String? tableStatus}) async {
    try {
      final response = await _dio.get(
        ApiConstants.tableOrder,
        queryParameters: {'page': 1, 'take': 50, 'tableStatus': ?tableStatus},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => TableOrderSession.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}