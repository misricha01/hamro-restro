import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/repositories/kot_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// Backs "KOT History" (Orders' 3-dot Actions menu), backed directly by
/// `GET /api/kot` instead of deriving KOTs from [OrderProvider.orders].
class KotProvider extends ChangeNotifier {
  final KotRepository _repository;

  KotProvider({required KotRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<KotRecord> kots = [];
  String? errorMessage;

  Future<void> fetchKots() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      kots = await _repository.getKots();
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

  bool isUpdating = false;
  String? updateErrorMessage;

  /// Marks a KOT with a new [orderStatus] (e.g. `'completed'`) and replaces
  /// it in [kots] on success. Returns whether the call succeeded (see
  /// [updateErrorMessage] on failure).
  Future<bool> updateKotStatus({required String id, required String orderStatus}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final updatedKot = await _repository.updateKotStatus(id: id, orderStatus: orderStatus);
      kots = kots.map((record) => record.kot.id == id ? KotRecord(kot: updatedKot, orderId: record.orderId, tableName: record.tableName, createdAt: record.createdAt) : record).toList();
      return true;
    } on ApiException catch (e) {
      updateErrorMessage = e.message;
      return false;
    } catch (_) {
      updateErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  bool isDeleting = false;
  String? deleteErrorMessage;

  Future<bool> deleteKot(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteKot(id);
      kots = kots.where((record) => record.kot.id != id).toList();
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
}
