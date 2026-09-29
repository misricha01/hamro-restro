import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/sales_purchase/sales_transaction_model.dart';

abstract class SalesTransactionRepository {
  /// [checkoutStatus] filters by status (e.g. `completed`, `pending`,
  /// `partial`, `cancelled`); omit to fetch every status.
  Future<List<SalesTransaction>> getSalesTransactions({String? checkoutStatus});

  /// `GET /api/sales-transaction`, also surfacing the server-computed sales
  /// total from the response's `message` block. The backend returns
  /// `{status, message: {totalCheckoutAmount, totalDueAmount, totalGuest,
  /// ...}, meta, data}`, but only `data` (the transaction list) was
  /// previously used, discarding the total the backend already computes.
  ///
  /// Note: the backend only populates `totalCheckoutAmount` when a
  /// [checkoutStatus] filter is supplied -- with no filter it returns 0 even
  /// though `data` still lists every row. Callers that need the total must
  /// therefore pass a [checkoutStatus] (e.g. `completed`). Uses a single
  /// request; prefer this over [getSalesTransactions] when the total is also
  /// needed.
  Future<({List<SalesTransaction> transactions, double totalAmount})> getSalesTransactionsWithTotal({String? checkoutStatus});
}

class SalesTransactionRepositoryImpl implements SalesTransactionRepository {
  final Dio _dio;

  SalesTransactionRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<SalesTransaction>> getSalesTransactions({String? checkoutStatus}) async {
    try {
      final response = await _dio.get(
        ApiConstants.salesTransactions,
        queryParameters: {'page': 1, 'take': 50, 'checkoutStatus': ?checkoutStatus},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => SalesTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<({List<SalesTransaction> transactions, double totalAmount})> getSalesTransactionsWithTotal({String? checkoutStatus}) async {
    try {
      final response = await _dio.get(
        ApiConstants.salesTransactions,
        queryParameters: {'page': 1, 'take': 50, 'checkoutStatus': ?checkoutStatus},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      final transactions = data.map((e) => SalesTransaction.fromJson(e as Map<String, dynamic>)).toList();
      final message = response.data['message'];
      final total = message is Map<String, dynamic> ? (message['totalCheckoutAmount'] as num?)?.toDouble() ?? 0.0 : 0.0;
      return (transactions: transactions, totalAmount: total);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
