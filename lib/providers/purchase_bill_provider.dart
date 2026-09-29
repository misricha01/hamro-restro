import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/sales_purchase/purchase_bill_model.dart';
import '../data/repositories/purchase_bill_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the "Purchase Bills" tab on [SalesAnalyticsScreen], backed
/// by `GET /api/purchase-bill`.
class PurchaseBillProvider extends ChangeNotifier {
  final PurchaseBillRepository _repository;

  PurchaseBillProvider({required PurchaseBillRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<PurchaseBill> bills = [];
  double totalAmount = 0;
  String? errorMessage;

  Future<void> fetchBills({String? purchaseStatus}) async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getPurchaseBillsWithTotal(purchaseStatus: purchaseStatus);
      bills = result.bills;
      totalAmount = result.totalAmount;
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<PurchaseBill?> createPurchaseBill({
    required String date,
    required String supplierId,
    required String billNo,
    required double amount,
    required String purchaseStatus,
    required String customerId,
    required String paymentType,
    String? paymentMethodId,
    String? imageId,
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final bill = await _repository.createPurchaseBill(
        date: date,
        supplierId: supplierId,
        billNo: billNo,
        amount: amount,
        purchaseStatus: purchaseStatus,
        customerId: customerId,
        paymentType: paymentType,
        paymentMethodId: paymentMethodId,
        imageId: imageId,
      );
      bills = [bill, ...bills];
      return bill;
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

  /// Updates a purchase bill and replaces it in [bills] on success. Returns
  /// the updated [PurchaseBill], or `null` if the call failed (see
  /// [updateErrorMessage]).
  Future<PurchaseBill?> updatePurchaseBill({
    required String id,
    required String date,
    required String supplierId,
    required String billNo,
    required double amount,
    required String purchaseStatus,
    required String customerId,
    required String paymentType,
    String? paymentMethodId,
    String? imageId,
  }) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final bill = await _repository.updatePurchaseBill(
        id: id,
        date: date,
        supplierId: supplierId,
        billNo: billNo,
        amount: amount,
        purchaseStatus: purchaseStatus,
        customerId: customerId,
        paymentType: paymentType,
        paymentMethodId: paymentMethodId,
        imageId: imageId,
      );
      bills = bills.map((b) => b.id == id ? bill : b).toList();
      return bill;
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
}