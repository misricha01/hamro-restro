import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/order_analytics/order_dashboard_model.dart';

abstract class OrderAnalyticsRepository {
  Future<OrderDashboard> getDashboard();
}

class OrderAnalyticsRepositoryImpl implements OrderAnalyticsRepository {
  final Dio _dio;

  OrderAnalyticsRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<OrderDashboard> getDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.orderDashboard);
      return OrderDashboard.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
