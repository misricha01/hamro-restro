import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/checkout_history/checkout_history_model.dart';
import '../data/repositories/checkout_history_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// Backs the "Checkout History" view reached from Orders' 3-dot Actions
/// menu, backed by `GET /api/checkout-history`.
class CheckoutHistoryProvider extends ChangeNotifier {
  final CheckoutHistoryRepository _repository;

  CheckoutHistoryProvider({required CheckoutHistoryRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<CheckoutHistoryEntry> history = [];
  String? errorMessage;

  Future<void> fetchHistory() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      history = await _repository.getCheckoutHistory();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
