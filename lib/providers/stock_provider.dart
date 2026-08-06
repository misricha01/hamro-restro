import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/stock/stock_model.dart';
import '../data/repositories/stock_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Stock Item list/detail, Add Stock Item form,
/// Consumption (stock adjust) and Stock History.
class StockProvider extends ChangeNotifier {
  final StockRepository _repository;

  StockProvider({required StockRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Stock> stocks = [];
  String? errorMessage;

  Future<void> fetchStocks() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      stocks = await _repository.getStocks();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<Stock?> createStock({
    required String itemName,
    required double defaultPrice,
    required double quantity,
    required double rate,
    String? description,
    required String unitId,
    String? stockGroupId,
    String? supplierId,
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final stock = await _repository.createStock(
        itemName: itemName,
        defaultPrice: defaultPrice,
        quantity: quantity,
        rate: rate,
        description: description,
        unitId: unitId,
        stockGroupId: stockGroupId,
        supplierId: supplierId,
      );
      stocks = [...stocks, stock];
      return stock;
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

  bool isDeleting = false;
  String? deleteErrorMessage;

  Future<bool> deleteStock(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteStock(id);
      stocks = stocks.where((s) => s.id != id).toList();
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

  bool isAdjusting = false;
  String? adjustErrorMessage;

  /// `type` is `'add'` or `'reduce'`. Used by Consumption (always `'reduce'`)
  /// and any future restock flow (`'add'`).
  Future<Stock?> adjustStock({
    required String id,
    required String type,
    required double quantity,
    required double rate,
    required DateTime transactionDate,
    String? supplierId,
    String? remark,
  }) async {
    isAdjusting = true;
    adjustErrorMessage = null;
    notifyListeners();

    try {
      final stock = await _repository.adjustStock(
        id: id,
        type: type,
        quantity: quantity,
        rate: rate,
        transactionDate: transactionDate,
        supplierId: supplierId,
        remark: remark,
      );
      stocks = stocks.map((s) => s.id == id ? stock : s).toList();
      return stock;
    } on ApiException catch (e) {
      adjustErrorMessage = e.message;
      return null;
    } catch (_) {
      adjustErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isAdjusting = false;
      notifyListeners();
    }
  }

  LoadStatus historyStatus = LoadStatus.idle;
  List<StockTransaction> history = [];
  String? historyErrorMessage;

  Future<void> fetchStockHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
    String? stockId,
    String? stockGroupId,
  }) async {
    historyStatus = LoadStatus.loading;
    historyErrorMessage = null;
    notifyListeners();

    try {
      history = await _repository.getStockHistory(
        startDate: startDate,
        endDate: endDate,
        staffId: staffId,
        stockId: stockId,
        stockGroupId: stockGroupId,
      );
      historyStatus = LoadStatus.loaded;
    } on ApiException catch (e) {
      historyErrorMessage = e.message;
      historyStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  StockStats? stats;

  Future<void> fetchStats() async {
    try {
      stats = await _repository.getStockStats();
    } on ApiException {
      // Summary counts are a nice-to-have — leave `stats` null and let the
      // UI fall back to showing 0s rather than blocking on this.
    }
    notifyListeners();
  }
}
