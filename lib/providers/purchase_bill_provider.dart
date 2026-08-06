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
  String? errorMessage;

  Future<void> fetchBills({String? purchaseStatus}) async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      bills = await _repository.getPurchaseBills(purchaseStatus: purchaseStatus);
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
}
