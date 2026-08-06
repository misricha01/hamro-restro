import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/dashboard/dashboard_overview_model.dart';
import '../data/repositories/dashboard_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Analytics screen's "Overview" tab, backed by
/// `GET /api/dashboard`.
class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardProvider({required DashboardRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  DashboardOverview? overview;
  String? errorMessage;

  Future<void> fetchOverview() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      overview = await _repository.getOverview();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
