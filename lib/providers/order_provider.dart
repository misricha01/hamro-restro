import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/orders/order_model.dart';
import '../data/repositories/order_repository.dart';

enum LoadStatus { idle, loading, loaded, error }

/// ViewModel for the Orders screen's "Active" tab.
class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;

  OrderProvider({required OrderRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Order> orders = [];
  String? errorMessage;

  Future<void> fetchOrders() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {

      orders = await _repository.getOrders();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isPlacing = false;
  String? placeOrderErrorMessage;

  /// Places an order and returns the [PlacedOrder] result, or `null` if the
  /// call failed (see [placeOrderErrorMessage]). Doesn't touch [orders] —
  /// callers that show the Active/Table list should call [fetchOrders]
  /// afterwards if they need it refreshed.
  Future<PlacedOrder?> placeOrder({required String tableId, required List<NewOrderItem> items}) async {
    isPlacing = true;
    placeOrderErrorMessage = null;
    notifyListeners();

    try {
      return await _repository.createOrder(tableId: tableId, items: items);
    } on ApiException catch (e) {
      placeOrderErrorMessage = e.message;
      return null;
    } catch (_) {
      placeOrderErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isPlacing = false;
      notifyListeners();
    }
  }
}
