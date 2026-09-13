import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/orders/table_model.dart';
import '../data/repositories/table_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Orders screen's "Table" tab.
class TableProvider extends ChangeNotifier {
  final TableRepository _repository;

  TableProvider({required TableRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<RestaurantTable> tables = [];
  String? errorMessage;

  TableStats? tableStats;
  LoadStatus tableStatsStatus = LoadStatus.idle;
  String? tableStatsError;

  bool isCreating = false;
  String? createErrorMessage;

  Future<void> fetchTables() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      tables = await _repository.getTables();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> fetchTableStats() async {
    tableStatsStatus = LoadStatus.loading;
    tableStatsError = null;
    notifyListeners();

    try {
      tableStats = await _repository.getTableStats();
      tableStatsStatus = LoadStatus.loaded;
    } on ApiException catch (e) {
      tableStatsError = e.message;
      tableStatsStatus = LoadStatus.error;
    } catch (_) {
      tableStatsError = 'Something went wrong. Please try again.';
      tableStatsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Creates a table and appends it to [tables] on success. Returns the
  /// created [RestaurantTable], or `null` if the call failed (see
  /// [createErrorMessage]).
  ///
  /// Uses `finally` for the [isCreating] reset and a catch-all so a
  /// non-[ApiException] failure (e.g. an unexpected response shape) can
  /// never leave the UI stuck on a permanent loading spinner.
  Future<RestaurantTable?> createTable({
    required String tableName,
    String? tableType,
    int? capacity,
    String? areaId,
    double? charge,
    String tableStatus = 'Open',
    bool available = true,
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final table = await _repository.createTable(
        tableName: tableName,
        tableType: tableType,
        capacity: capacity,
        areaId: areaId,
        charge: charge,
        tableStatus: tableStatus,
        available: available,
      );
      tables = [...tables, table];
      return table;
    } on ApiException catch (e) {
      createErrorMessage = e.message;
      return null;
    } catch (_) {
      createErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  bool isUpdating = false;
  String? updateErrorMessage;

  /// Updates a table and replaces it in [tables] on success. Returns the
  /// updated [RestaurantTable], or `null` if the call failed (see
  /// [updateErrorMessage]).
  Future<RestaurantTable?> updateTable({
    required String id,
    required String tableName,
    String? tableType,
    int? capacity,
    String? areaId,
    double? charge,
    required String tableStatus,
    required bool available,
  }) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final table = await _repository.updateTable(
        id: id,
        tableName: tableName,
        tableType: tableType,
        capacity: capacity,
        areaId: areaId,
        charge: charge,
        tableStatus: tableStatus,
        available: available,
      );
      tables = tables.map((t) => t.id == id ? table : t).toList();
      return table;
    } on ApiException catch (e) {
      updateErrorMessage = e.message;
      return null;
    } catch (_) {
      updateErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  bool isDeleting = false;
  String? deleteErrorMessage;

  /// Deletes a table and removes it from [tables] on success. Returns
  /// whether the call succeeded (see [deleteErrorMessage] on failure).
  Future<bool> deleteTable(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteTable(id);
      tables = tables.where((t) => t.id != id).toList();
      return true;
    } on ApiException catch (e) {
      deleteErrorMessage = e.message;
      return false;
    } catch (_) {
      deleteErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  bool isMoving = false;
  String? moveErrorMessage;

  /// Moves [fromTableId]'s active order onto [toTableId] and refreshes
  /// [tables] so both tables' statuses reflect the change. Returns the
  /// backend's status message on success (see [TableRepository.moveTable]
  /// for why that message — not just a boolean — is what callers should
  /// show), or `null` if the call failed (see [moveErrorMessage]).
  Future<String?> moveTable({required String fromTableId, required String toTableId}) async {
    isMoving = true;
    moveErrorMessage = null;
    notifyListeners();

    try {
      final message = await _repository.moveTable(fromTableId: fromTableId, toTableId: toTableId);
      await fetchTables();
      return message;
    } on ApiException catch (e) {
      moveErrorMessage = e.message;
      return null;
    } catch (_) {
      moveErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isMoving = false;
      notifyListeners();
    }
  }

  bool isMerging = false;
  String? mergeErrorMessage;

  /// Combines [fromTableIds]' active orders onto [toTableId] and refreshes
  /// [tables]. Returns the backend's status message on success, or `null`
  /// if the call failed (see [mergeErrorMessage]).
  Future<String?> mergeTables({required List<String> fromTableIds, required String toTableId}) async {
    isMerging = true;
    mergeErrorMessage = null;
    notifyListeners();

    try {
      final message = await _repository.mergeTable(fromTableIds: fromTableIds, toTableId: toTableId);
      await fetchTables();
      return message;
    } on ApiException catch (e) {
      mergeErrorMessage = e.message;
      return null;
    } catch (_) {
      mergeErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isMerging = false;
      notifyListeners();
    }
  }
}
