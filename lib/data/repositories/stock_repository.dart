import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/stock/stock_model.dart';

abstract class StockRepository {
  Future<List<Stock>> getStocks();

  Future<Stock> createStock({
    required String itemName,
    required double defaultPrice,
    required double quantity,
    required double rate,
    String? description,
    required String unitId,
    String? stockGroupId,
    String? supplierId,
  });

  Future<Stock> updateStock({
    required String id,
    String? itemName,
    double? defaultPrice,
    double? quantity,
    double? rate,
    String? description,
    String? unitId,
    String? stockGroupId,
    String? supplierId,
  });

  Future<void> deleteStock(String id);

  /// `PATCH /api/stock/{id}/adjust` — [type] is `'add'` or `'reduce'`.
  Future<Stock> adjustStock({
    required String id,
    required String type,
    required double quantity,
    required double rate,
    required DateTime transactionDate,
    String? supplierId,
    String? remark,
  });

  Future<List<StockTransaction>> getStockHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
    String? stockId,
    String? stockGroupId,
  });

  Future<StockStats> getStockStats();
}

class StockRepositoryImpl implements StockRepository {
  final Dio _dio;

  StockRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Stock>> getStocks() async {
    try {
      final response = await _dio.get(ApiConstants.stocks, queryParameters: {'page': 1, 'take': 200});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Stock.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Stock> createStock({
    required String itemName,
    required double defaultPrice,
    required double quantity,
    required double rate,
    String? description,
    required String unitId,
    String? stockGroupId,
    String? supplierId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.stocks,
        data: {
          'itemName': itemName,
          'defaultPrice': defaultPrice,
          'quantity': quantity,
          'rate': rate,
          if (description != null && description.isNotEmpty) 'description': description,
          'unitId': unitId,
          if (stockGroupId != null) 'stockGroupId': stockGroupId,
          if (supplierId != null) 'supplierId': supplierId,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['itemName'] != null) return Stock.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by name.
      final stocks = await getStocks();
      final matches = stocks.where((s) => s.itemName == itemName).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Stock item was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Stock> updateStock({
    required String id,
    String? itemName,
    double? defaultPrice,
    double? quantity,
    double? rate,
    String? description,
    String? unitId,
    String? stockGroupId,
    String? supplierId,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.stocks}/$id',
        data: {
          if (itemName != null) 'itemName': itemName,
          if (defaultPrice != null) 'defaultPrice': defaultPrice,
          if (quantity != null) 'quantity': quantity,
          if (rate != null) 'rate': rate,
          if (description != null) 'description': description,
          if (unitId != null) 'unitId': unitId,
          if (stockGroupId != null) 'stockGroupId': stockGroupId,
          if (supplierId != null) 'supplierId': supplierId,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['itemName'] != null) return Stock.fromJson(raw);

      final stocks = await getStocks();
      final match = stocks.where((s) => s.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Stock item was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteStock(String id) async {
    try {
      await _dio.delete('${ApiConstants.stocks}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Stock> adjustStock({
    required String id,
    required String type,
    required double quantity,
    required double rate,
    required DateTime transactionDate,
    String? supplierId,
    String? remark,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.stocks}/$id/adjust',
        data: {
          'type': type,
          'quantity': quantity,
          'rate': rate,
          'transactionDate': transactionDate.toIso8601String().split('T').first,
          if (supplierId != null) 'supplierId': supplierId,
          if (remark != null && remark.isNotEmpty) 'remark': remark,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['itemName'] != null) return Stock.fromJson(raw);

      final stocks = await getStocks();
      final match = stocks.where((s) => s.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Stock was adjusted, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<StockTransaction>> getStockHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
    String? stockId,
    String? stockGroupId,
  }) async {
    try {
      String fmt(DateTime d) => d.toIso8601String().split('T').first;
      final response = await _dio.get(
        '${ApiConstants.stocks}/history',
        queryParameters: {
          'page': 1,
          'take': 200,
          if (startDate != null) 'startDate': fmt(startDate),
          if (endDate != null) 'endDate': fmt(endDate),
          if (staffId != null) 'staffId': staffId,
          if (stockId != null) 'stockId': stockId,
          if (stockGroupId != null) 'stockGroupId': stockGroupId,
        },
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => StockTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<StockStats> getStockStats() async {
    try {
      final response = await _dio.get('${ApiConstants.stocks}/stats');
      return StockStats.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
