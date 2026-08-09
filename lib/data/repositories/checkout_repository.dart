import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/checkout/checkout_model.dart';

/// A single payment-method split entered when completing a checkout —
/// mirrors the backend's `SplitPaymentDTO`.
class SplitPayment {
  final String paymentMethodId;
  final double amount;

  const SplitPayment({required this.paymentMethodId, required this.amount});

  Map<String, dynamic> toJson() => {'paymentMethodId': paymentMethodId, 'amount': amount};
}

abstract class CheckoutRepository {
  /// `POST /api/checkout` — "Generates bill and initiates Checkout only."
  /// Computes and returns the bill for [tableId]'s current order.
  Future<Checkout> createCheckout({
    required String tableId,
    String? discountType,
    String? discount,
    String? remarks,
  });

  /// `PATCH /api/checkout/{id}` — "Complete Checkout procedure." Records the
  /// payment split and finalizes the bill.
  Future<Checkout> completeCheckout({
    required String id,
    required String checkoutStatus,
    String? noOfGuests,
    String? customerId,
    String? companyName,
    String? companyPan,
    List<SplitPayment>? payments,
  });

  Future<Checkout> getCheckout(String id);

  /// `DELETE /api/checkout/{id}` — cancels a checkout that was generated but
  /// never completed, so it doesn't linger as an orphaned `pending` record.
  Future<void> cancelCheckout(String id);
}

class CheckoutRepositoryImpl implements CheckoutRepository {
  final Dio _dio;

  CheckoutRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<Checkout> createCheckout({
    required String tableId,
    String? discountType,
    String? discount,
    String? remarks,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkout,
        data: {
          'tableId': tableId,
          'discountType': ?discountType,
          'discount': ?discount,
          'remarks': ?remarks,
        },
      );
      // Confirmed live: unlike most other "create" endpoints on this
      // backend (which at least echo the full/partial record), this one
      // only ever returns `{"checkoutId": "..."}` — always follow up with a
      // GET for the actual computed bill.
      final raw = response.data['data'];
      final checkoutId = raw is Map<String, dynamic> ? raw['checkoutId']?.toString() : null;
      if (checkoutId != null) return getCheckout(checkoutId);
      throw const ApiException('Bill could not be generated. Please try again.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Checkout> completeCheckout({
    required String id,
    required String checkoutStatus,
    String? noOfGuests,
    String? customerId,
    String? companyName,
    String? companyPan,
    List<SplitPayment>? payments,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.checkout}/$id',
        data: {
          'checkoutStatus': checkoutStatus,
          'noOfGuests': ?noOfGuests,
          'customerId': ?customerId,
          'companyName': ?companyName,
          'companyPan': ?companyPan,
          if (payments != null && payments.isNotEmpty) 'payments': payments.map((p) => p.toJson()).toList(),
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return Checkout.fromJson(raw);

      // Create only echoes back partial data on some of this backend's
      // endpoints — fall back to a fresh GET rather than guessing.
      return getCheckout(id);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Checkout> getCheckout(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.checkout}/$id');
      final raw = response.data['data'];
      return Checkout.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> cancelCheckout(String id) async {
    try {
      await _dio.delete('${ApiConstants.checkout}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
