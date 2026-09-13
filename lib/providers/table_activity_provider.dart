import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/table_activity/table_activity_model.dart';
import '../data/repositories/table_activity_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// Backs the "Activity" view reached from a table's long-press menu on the
/// Orders screen. The backend has no per-table filter, so this fetches a
/// page of every table's activity and the screen filters client-side.
class TableActivityProvider extends ChangeNotifier {
  final TableActivityRepository _repository;

  TableActivityProvider({required TableActivityRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<TableActivityEntry> activity = [];
  String? errorMessage;

  Future<void> fetchActivity() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      activity = await _repository.getTableActivity();
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
