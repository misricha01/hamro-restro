import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/stock/stock_group_model.dart';
import '../data/repositories/stock_group_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Stock Group list/detail and Add/Edit Stock Group form.
class StockGroupProvider extends ChangeNotifier {
  final StockGroupRepository _repository;

  StockGroupProvider({required StockGroupRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<StockGroup> groups = [];
  String? errorMessage;

  Future<void> fetchStockGroups() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      groups = await _repository.getStockGroups();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  /// Creates a stock group and appends it to [groups] on success. Returns
  /// the created [StockGroup], or `null` if the call failed (see
  /// [createErrorMessage]).
  Future<StockGroup?> createStockGroup({required String groupName, String? groupDescription}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final group = await _repository.createStockGroup(groupName: groupName, groupDescription: groupDescription);
      groups = [...groups, group];
      return group;
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

  Future<StockGroup?> updateStockGroup({required String id, required String groupName, String? groupDescription}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final group = await _repository.updateStockGroup(id: id, groupName: groupName, groupDescription: groupDescription);
      groups = groups.map((g) => g.id == id ? group : g).toList();
      return group;
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

  Future<bool> deleteStockGroup(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteStockGroup(id);
      groups = groups.where((g) => g.id != id).toList();
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

  StockGroupStats? stockGroupStats;
  LoadStatus stockGroupStatsStatus = LoadStatus.idle;
  String? stockGroupStatsError;

  Future<void> fetchStockGroupStats() async {
    stockGroupStatsStatus = LoadStatus.loading;
    stockGroupStatsError = null;
    notifyListeners();

    try {
      stockGroupStats = await _repository.getStockGroupStats();
      stockGroupStatsStatus = LoadStatus.loaded;
    } on ApiException catch (e) {
      stockGroupStatsError = e.message;
      stockGroupStatsStatus = LoadStatus.error;
    }
    notifyListeners();
  }
}
