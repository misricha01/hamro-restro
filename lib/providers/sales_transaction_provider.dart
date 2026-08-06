import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/sales_purchase/sales_transaction_model.dart';
import '../data/repositories/sales_transaction_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the "Sales Invoice" tab on [SalesAnalyticsScreen], backed by
/// `GET /api/sales-transaction`.
class SalesTransactionProvider extends ChangeNotifier {
  final SalesTransactionRepository _repository;

  SalesTransactionProvider({required SalesTransactionRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<SalesTransaction> transactions = [];
  String? errorMessage;

  Future<void> fetchTransactions({String? checkoutStatus}) async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      transactions = await _repository.getSalesTransactions(checkoutStatus: checkoutStatus);
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
