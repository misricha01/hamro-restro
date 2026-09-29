import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/checkout_history/checkout_history_model.dart';

abstract class CheckoutHistoryRepository {
  Future<List<CheckoutHistoryEntry>> getCheckoutHistory();
}

class CheckoutHistoryRepositoryImpl implements CheckoutHistoryRepository {
  final Dio _dio;

  CheckoutHistoryRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<CheckoutHistoryEntry>> getCheckoutHistory() async {
    try {
      final response = await _dio.get(ApiConstants.checkoutHistory);
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => CheckoutHistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
