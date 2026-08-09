import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/sales_purchase/purchase_bill_model.dart';

abstract class PurchaseBillRepository {
  /// [purchaseStatus] filters by status (`paid`, `unpaid`, `pending`,
  /// `partial`); omit to fetch every status.
  Future<List<PurchaseBill>> getPurchaseBills({String? purchaseStatus});

  /// `POST /api/purchase-bill`. `customerId` is required by the backend's
  /// `CreatePurchaseBillDTO` despite this being a supplier purchase — the
  /// Add Purchase screen surfaces it as a real "Customer" picker rather than
  /// guessing a value.
  Future<PurchaseBill> createPurchaseBill({
    required String date,
    required String supplierId,
    required String billNo,
    required double amount,
    required String purchaseStatus,
    required String customerId,
    required String paymentType,
    String? paymentMethodId,
    String? imageId,
  });

  Future<PurchaseBill> updatePurchaseBill({
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
  });
}

class PurchaseBillRepositoryImpl implements PurchaseBillRepository {
  final Dio _dio;

  PurchaseBillRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<PurchaseBill>> getPurchaseBills({String? purchaseStatus}) async {
    try {
      final response = await _dio.get(
        ApiConstants.purchaseBills,
        queryParameters: {'page': 1, 'take': 50, 'purchaseStatus': ?purchaseStatus},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => PurchaseBill.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PurchaseBill> createPurchaseBill({
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
    try {
      final response = await _dio.post(
        ApiConstants.purchaseBills,
        data: {
          'date': date,
          'supplierId': supplierId,
          'billNo': billNo,
          // Confirmed live against the real backend: unlike every other
          // numeric field in this app, `amount` here 400s ("amount must be
          // a string") unless it's sent as a string.
          'amount': amount.toString(),
          'purchaseStatus': purchaseStatus,
          'customerId': customerId,
          'payment_type': paymentType,
          'paymentMethodId': ?paymentMethodId,
          'imageId': ?imageId,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['billNo'] != null) return PurchaseBill.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by billNo+amount.
      // Confirmed live: `GET /api/purchase-bill` currently 500s once a
      // `paid`-status bill exists, so this refetch itself can fail even
      // though the POST above already succeeded (201). Don't report the
      // create as failed in that case — fall back to a locally-synthesized
      // record built from what we just sent, so the caller still sees
      // success; the next successful list refresh will replace it.
      try {
        final bills = await getPurchaseBills();
        final matches = bills.where((b) => b.billNo == billNo && b.amount == amount).toList()
          ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        if (matches.isNotEmpty) return matches.first;
      } catch (_) {
        // Fall through to the synthesized record below.
      }
      return PurchaseBill(
        id: 'pending-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.tryParse(date) ?? DateTime.now(),
        billNo: billNo,
        amount: amount,
        purchaseStatus: purchaseStatus,
        paymentType: paymentType,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PurchaseBill> updatePurchaseBill({
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
    try {
      final response = await _dio.patch(
        '${ApiConstants.purchaseBills}/$id',
        data: {
          'date': date,
          'supplierId': supplierId,
          'billNo': billNo,
          // Same "amount must be a string" quirk as create — see above.
          'amount': amount.toString(),
          'purchaseStatus': purchaseStatus,
          'customerId': customerId,
          'payment_type': paymentType,
          'paymentMethodId': ?paymentMethodId,
          'imageId': ?imageId,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['billNo'] != null) return PurchaseBill.fromJson(raw);

      // Same 500-on-list quirk as create's refetch fallback — don't report
      // the update as failed just because the follow-up GET can't confirm
      // it; synthesize the record from what was just sent instead.
      try {
        final bills = await getPurchaseBills();
        final match = bills.where((b) => b.id == id).toList();
        if (match.isNotEmpty) return match.first;
      } catch (_) {
        // Fall through to the synthesized record below.
      }
      return PurchaseBill(
        id: id,
        date: DateTime.tryParse(date) ?? DateTime.now(),
        billNo: billNo,
        amount: amount,
        purchaseStatus: purchaseStatus,
        paymentType: paymentType,
        customerId: customerId,
        paymentMethodId: paymentMethodId,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
