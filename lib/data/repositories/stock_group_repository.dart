import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/stock/stock_group_model.dart';

abstract class StockGroupRepository {
  Future<List<StockGroup>> getStockGroups();

  Future<StockGroup> createStockGroup({required String groupName, String? groupDescription});

  Future<StockGroup> updateStockGroup({required String id, required String groupName, String? groupDescription});

  Future<void> deleteStockGroup(String id);
}

class StockGroupRepositoryImpl implements StockGroupRepository {
  final Dio _dio;

  StockGroupRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<StockGroup>> getStockGroups() async {
    try {
      final response = await _dio.get(ApiConstants.stockGroups, queryParameters: {'page': 1, 'take': 200});
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => StockGroup.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _body({required String groupName, String? groupDescription}) {
    return {'groupName': groupName, 'groupDescription': groupDescription};
  }

  @override
  Future<StockGroup> createStockGroup({required String groupName, String? groupDescription}) async {
    try {
      final response = await _dio.post(ApiConstants.stockGroups, data: _body(groupName: groupName, groupDescription: groupDescription));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['groupName'] != null) return StockGroup.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by name.
      final groups = await getStockGroups();
      final matches = groups.where((g) => g.groupName == groupName).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Stock group was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<StockGroup> updateStockGroup({required String id, required String groupName, String? groupDescription}) async {
    try {
      final response = await _dio.patch('${ApiConstants.stockGroups}/$id', data: _body(groupName: groupName, groupDescription: groupDescription));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['groupName'] != null) return StockGroup.fromJson(raw);

      final groups = await getStockGroups();
      final match = groups.where((g) => g.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Stock group was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteStockGroup(String id) async {
    try {
      await _dio.delete('${ApiConstants.stockGroups}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
