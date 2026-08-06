import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/subscription/subscription_model.dart';
import '../data/repositories/subscription_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Billing & Subscription hub, backed by
/// `/api/subscriptions/current`, `/api/subscriptions/cancel`,
/// `/api/billing/invoices` and `/api/billing/payments`.
class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _repository;

  SubscriptionProvider({required SubscriptionRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  CurrentSubscription subscription = const CurrentSubscription();
  String? errorMessage;

  Future<void> fetchCurrentSubscription() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      subscription = await _repository.getCurrentSubscription();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCancelling = false;
  String? cancelErrorMessage;

  Future<bool> cancelSubscription({bool immediate = false}) async {
    isCancelling = true;
    cancelErrorMessage = null;
    notifyListeners();

    try {
      await _repository.cancelSubscription(immediate: immediate);
      await fetchCurrentSubscription();
      return true;
    } on ApiException catch (e) {
      cancelErrorMessage = e.message;
      return false;
    } catch (_) {
      cancelErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isCancelling = false;
      notifyListeners();
    }
  }

  LoadStatus billingStatus = LoadStatus.idle;
  List<BillingInvoice> invoices = [];
  List<BillingPayment> payments = [];
  String? billingErrorMessage;

  Future<void> fetchBillingHistory() async {
    billingStatus = LoadStatus.loading;
    billingErrorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([_repository.getBillingInvoices(), _repository.getBillingPayments()]);
      invoices = results[0] as List<BillingInvoice>;
      payments = results[1] as List<BillingPayment>;
      billingStatus = LoadStatus.loaded;
    } on ApiException catch (e) {
      billingErrorMessage = e.message;
      billingStatus = LoadStatus.error;
    }
    notifyListeners();
  }
}
