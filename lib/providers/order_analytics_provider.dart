import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/order_analytics/order_dashboard_model.dart';
import '../data/repositories/order_analytics_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Order overview (Analytics screen's "Order" tab), backed
/// by `GET /api/dashboard/order`.
class OrderAnalyticsProvider extends ChangeNotifier {
  final OrderAnalyticsRepository _repository;

  OrderAnalyticsProvider({required OrderAnalyticsRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  OrderDashboard? dashboard;
  String? errorMessage;

  Future<void> fetchDashboard() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      dashboard = await _repository.getDashboard();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
