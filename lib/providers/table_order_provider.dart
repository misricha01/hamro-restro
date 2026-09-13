import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/table_order/table_order_session.dart';
import '../data/repositories/table_order_repository.dart';
import '../screens/orders/table_order_sessions_screen.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the active table-order sessions list (`GET
/// /api/table-order`). Read-only -- move/merge stay on their own existing
/// repository/flow; this just gives visibility into the raw session list
/// that had no screen before.
class TableOrderProvider extends ChangeNotifier {
  final TableOrderRepository _repository;

  TableOrderProvider({required TableOrderRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<TableOrderSession> sessions = [];
  String? errorMessage;

  Future<void> fetchSessions({String? tableStatus}) async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      sessions = await _repository.getTableOrders(tableStatus: tableStatus);
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}