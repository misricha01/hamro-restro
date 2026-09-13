import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/orders/order_model.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();

  Future<Order> getOrder(String id);

  Future<PlacedOrder> createOrder({required String tableId, required List<NewOrderItem> items});

  /// `PATCH /api/order/{id}` — reassigns [tableId]/[assignedStaff] on an
  /// existing order. Both optional; only non-null fields are sent.
  Future<void> updateOrder({required String id, String? tableId, String? assignedStaff});

  Future<void> deleteOrder(String id);

  /// `PATCH /api/order/dish/{itemId}` — updates a single dish line item's
  /// status (this app only ever creates dish/custom-dish items on an order,
  /// never addon/variant items, so there's no addon/variant counterpart
  /// wired here — see `PATCH /api/order/addon/{addonItemId}` and
  /// `/variant/{variantItemId}` in the audit report's skip list).
  Future<void> updateOrderItemDishStatus({required String itemId, required String dishStatus});
}

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio;

  OrderRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get(ApiConstants.orders, queryParameters: {'page': 1, 'take': 50});
      final data = response.data['data'] as List<dynamic>? ?? [];
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

  @override
  Future<Order> getOrder(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.orders}/$id');
      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> updateOrder({required String id, String? tableId, String? assignedStaff}) async {
    try {
      await _dio.patch(
        '${ApiConstants.orders}/$id',
        data: {'tableId': ?tableId, 'assignedStaff': ?assignedStaff},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      await _dio.delete('${ApiConstants.orders}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> updateOrderItemDishStatus({required String itemId, required String dishStatus}) async {
    try {
      await _dio.patch('${ApiConstants.orders}/dish/$itemId', data: {'dishStatus': dishStatus});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
