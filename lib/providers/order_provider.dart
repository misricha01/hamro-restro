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

  bool isUpdatingItemStatus = false;
  String? updateItemStatusErrorMessage;

  /// Updates a single dish item's status (e.g. mark it `'completed'` or
  /// `'cancelled'`) and refetches [orders] on success so every screen
  /// reading from this provider sees the change.
  Future<bool> updateOrderItemDishStatus({required String itemId, required String dishStatus}) async {
    isUpdatingItemStatus = true;
    updateItemStatusErrorMessage = null;
    notifyListeners();

    try {
      await _repository.updateOrderItemDishStatus(itemId: itemId, dishStatus: dishStatus);
      await fetchOrders();
      return true;
    } on ApiException catch (e) {
      updateItemStatusErrorMessage = e.message;
      return false;
    } catch (_) {
      updateItemStatusErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isUpdatingItemStatus = false;
      notifyListeners();
    }
  }

  /// `GET /api/order/{id}` — fetches a single order fresh from the backend.
  /// Not used by any screen yet; exposed for a future order-detail view.
  Future<Order?> getOrder(String id) async {
    try {
      return await _repository.getOrder(id);
    } catch (_) {
      return null;
    }
  }

  bool isReassigning = false;
  String? reassignErrorMessage;

  /// `PATCH /api/order/{id}` — reassigns table/staff on an existing order.
  /// Not wired to any UI yet (no staff/table-reassignment picker exists on
  /// the Orders screen); exposed so the capability is available once one
  /// is built.
  Future<bool> updateOrder({required String id, String? tableId, String? assignedStaff}) async {
    isReassigning = true;
    reassignErrorMessage = null;
    notifyListeners();

    try {
      await _repository.updateOrder(id: id, tableId: tableId, assignedStaff: assignedStaff);
      await fetchOrders();
      return true;
    } on ApiException catch (e) {
      reassignErrorMessage = e.message;
      return false;
    } catch (_) {
      reassignErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isReassigning = false;
      notifyListeners();
    }
  }

  bool isDeletingOrder = false;
  String? deleteOrderErrorMessage;

  Future<bool> deleteOrder(String id) async {
    isDeletingOrder = true;
    deleteOrderErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteOrder(id);
      orders = orders.where((o) => o.id != id).toList();
      return true;
    } on ApiException catch (e) {
      deleteOrderErrorMessage = e.message;
      return false;
    } catch (_) {
      deleteOrderErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isDeletingOrder = false;
      notifyListeners();
    }
  }
}
