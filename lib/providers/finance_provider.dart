import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/finance/finance_dashboard_model.dart';
import '../data/repositories/finance_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Finance overview (Manage > Finance / Analytics > Finance
/// tab), backed by `GET /api/dashboard/finance`.
class FinanceProvider extends ChangeNotifier {
  final FinanceRepository _repository;

  FinanceProvider({required FinanceRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  FinanceDashboard? dashboard;
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
