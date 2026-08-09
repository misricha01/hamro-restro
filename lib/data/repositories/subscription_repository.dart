import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/subscription/subscription_model.dart';

/// Purchase/change (upgrade/downgrade) aren't implemented here — both start
/// a real payment (eSewa) and this app has no browser-launch/webview
/// capability wired up yet. Cancel and read are self-service, so those are
/// wired.
abstract class SubscriptionRepository {
  Future<CurrentSubscription> getCurrentSubscription();

  Future<void> cancelSubscription({bool immediate = false});

  Future<List<BillingInvoice>> getBillingInvoices();

  Future<List<BillingPayment>> getBillingPayments();
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final Dio _dio;

  SubscriptionRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<CurrentSubscription> getCurrentSubscription() async {
    try {
      final response = await _dio.get(ApiConstants.subscriptionCurrent);
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return CurrentSubscription.fromJson(raw);
      return const CurrentSubscription();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> cancelSubscription({bool immediate = false}) async {
    try {
      await _dio.post(ApiConstants.subscriptionCancel, data: {'immediate': immediate});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<BillingInvoice>> getBillingInvoices() async {
    try {
      final response = await _dio.get(ApiConstants.billingInvoices, queryParameters: {'page': 1, 'take': 50});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => BillingInvoice.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<BillingPayment>> getBillingPayments() async {
    try {
      final response = await _dio.get(ApiConstants.billingPayments, queryParameters: {'page': 1, 'take': 50});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => BillingPayment.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
