import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/staff/role_model.dart';
import '../data/repositories/route_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the User Role editor's Route x Permission matrix, backed
/// by `GET /api/routes` — the shared vocabulary of grantable resources.
class RouteProvider extends ChangeNotifier {
  final RouteRepository _repository;

  RouteProvider({required RouteRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<ApiRoute> routes = [];
  String? errorMessage;

  Future<void> fetchRoutes() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      routes = await _repository.getRoutes();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
