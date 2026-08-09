import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/supplier/supplier_transaction_model.dart';
import '../data/repositories/supplier_transaction_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Supplier Detail screen's Transactions list. The
/// backend has no per-supplier filter, so this fetches the restaurant's
/// full transaction list once and [transactionsFor] filters client-side.
class SupplierTransactionProvider extends ChangeNotifier {
  final SupplierTransactionRepository _repository;

  SupplierTransactionProvider({required SupplierTransactionRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<SupplierTransaction> transactions = [];
  String? errorMessage;

  List<SupplierTransaction> transactionsFor(String supplierId) {
    final list = transactions.where((t) => t.supplierId == supplierId).toList()
      ..sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
    return list;
  }

  Future<void> fetchTransactions() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      transactions = await _repository.getSupplierTransactions();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<SupplierTransaction?> createSupplierTransaction({
    required String supplierId,
    required String date,
    required String particulars,
    double? toReceived,
    double? toPay,
    required String paymentMethodId,
    required double totalPayment,
    String? remarks,
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final transaction = await _repository.createSupplierTransaction(
        supplierId: supplierId,
        date: date,
        particulars: particulars,
        toReceived: toReceived,
        toPay: toPay,
        paymentMethodId: paymentMethodId,
        totalPayment: totalPayment,
        remarks: remarks,
      );
      transactions = [transaction, ...transactions];
      return transaction;
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

  /// Updates a transaction and replaces it in [transactions] on success.
  /// Returns the updated [SupplierTransaction], or `null` if the call
  /// failed (see [updateErrorMessage]).
  Future<SupplierTransaction?> updateSupplierTransaction({
    required String id,
    required String supplierId,
    required String date,
    required String particulars,
    double? toReceived,
    double? toPay,
    required String paymentMethodId,
    required double totalPayment,
    String? remarks,
  }) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final transaction = await _repository.updateSupplierTransaction(
        id: id,
        supplierId: supplierId,
        date: date,
        particulars: particulars,
        toReceived: toReceived,
        toPay: toPay,
        paymentMethodId: paymentMethodId,
        totalPayment: totalPayment,
        remarks: remarks,
      );
      transactions = transactions.map((t) => t.id == id ? transaction : t).toList();
      return transaction;
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

  Future<bool> deleteSupplierTransaction(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteSupplierTransaction(id);
      transactions = transactions.where((t) => t.id != id).toList();
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
