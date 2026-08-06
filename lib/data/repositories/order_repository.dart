import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/orders/order_model.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();

  Future<PlacedOrder> createOrder({required String tableId, required List<NewOrderItem> items});
}

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio;

  OrderRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get(ApiConstants.orders, queryParameters: {'page': 1, 'take': 50});
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PlacedOrder> createOrder({required String tableId, required List<NewOrderItem> items}) async {
    try {
      final response = await _dio.post(
        ApiConstants.orders,
        data: {
          'tableId': tableId,
          'items': items.map((e) => e.toJson()).toList(),
        },
      );
      return PlacedOrder.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
