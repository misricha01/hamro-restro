import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/sales_purchase/sales_transaction_model.dart';

abstract class SalesTransactionRepository {
  /// [checkoutStatus] filters by status (e.g. `completed`, `pending`,
  /// `partial`, `cancelled`); omit to fetch every status.
  Future<List<SalesTransaction>> getSalesTransactions({String? checkoutStatus});
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
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => SalesTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
