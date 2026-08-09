import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/checkout/checkout_model.dart';
import '../data/repositories/checkout_repository.dart';

/// ViewModel for the Checkout / Bill Settlement screen — generates a bill
/// for a table (`POST /api/checkout`) then completes it with a payment
/// split (`PATCH /api/checkout/{id}`).
class CheckoutProvider extends ChangeNotifier {
  final CheckoutRepository _repository;

  CheckoutProvider({required CheckoutRepository repository}) : _repository = repository;

  bool isGenerating = false;
  String? generateErrorMessage;

  Future<Checkout?> generateBill({
    required String tableId,
    String? discountType,
    String? discount,
    String? remarks,
  }) async {
    isGenerating = true;
    generateErrorMessage = null;
    notifyListeners();

    try {
      return await _repository.createCheckout(tableId: tableId, discountType: discountType, discount: discount, remarks: remarks);
    } on ApiException catch (e) {
      generateErrorMessage = e.message;
      return null;
    } catch (_) {
      generateErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  bool isCompleting = false;
  String? completeErrorMessage;

  Future<Checkout?> completeCheckout({
    required String id,
    required String checkoutStatus,
    String? noOfGuests,
    String? customerId,
    String? companyName,
    String? companyPan,
    List<SplitPayment>? payments,
  }) async {
    isCompleting = true;
    completeErrorMessage = null;
    notifyListeners();

    try {
      return await _repository.completeCheckout(
        id: id,
        checkoutStatus: checkoutStatus,
        noOfGuests: noOfGuests,
        customerId: customerId,
        companyName: companyName,
        companyPan: companyPan,
        payments: payments,
      );
    } on ApiException catch (e) {
      completeErrorMessage = e.message;
      return null;
    } catch (_) {
      completeErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isCompleting = false;
      notifyListeners();
    }
  }

  bool isCancelling = false;

  /// Best-effort cleanup for a generated-but-abandoned bill — nothing
  /// meaningful to surface to the user if this fails, the record just stays
  /// `pending` server-side.
  Future<void> cancelCheckout(String id) async {
    isCancelling = true;
    notifyListeners();
    try {
      await _repository.cancelCheckout(id);
    } catch (_) {
      // Ignored — see doc comment.
    } finally {
      isCancelling = false;
      notifyListeners();
    }
  }
}
