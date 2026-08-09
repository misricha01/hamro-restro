import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/supplier/supplier_transaction_model.dart';

abstract class SupplierTransactionRepository {
  /// The backend has no per-supplier filter on this endpoint — every call
  /// fetches the restaurant's full transaction list, which the caller then
  /// filters by `supplierId`.
  Future<List<SupplierTransaction>> getSupplierTransactions();

  Future<SupplierTransaction> createSupplierTransaction({
    required String supplierId,
    required String date,
    required String particulars,
    double? toReceived,
    double? toPay,
    required String paymentMethodId,
    required double totalPayment,
    String? remarks,
  });

  Future<SupplierTransaction> updateSupplierTransaction({
    required String id,
    required String supplierId,
    required String date,
    required String particulars,
    double? toReceived,
    double? toPay,
    required String paymentMethodId,
    required double totalPayment,
    String? remarks,
  });

  Future<void> deleteSupplierTransaction(String id);
}

class SupplierTransactionRepositoryImpl implements SupplierTransactionRepository {
  final Dio _dio;

  SupplierTransactionRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<SupplierTransaction>> getSupplierTransactions() async {
    try {
      final response = await _dio.get(ApiConstants.supplierTransactions, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => SupplierTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<SupplierTransaction> createSupplierTransaction({
    required String supplierId,
    required String date,
    required String particulars,
    double? toReceived,
    double? toPay,
    required String paymentMethodId,
    required double totalPayment,
    String? remarks,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.supplierTransactions,
        data: {
          'supplierId': supplierId,
          'date': date,
          'particulars': particulars,
          if (toReceived != null) 'toReceived': toReceived,
          if (toPay != null) 'toPay': toPay,
          'paymentMethodId': paymentMethodId,
          'totalPayment': totalPayment,
          if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['particulars'] != null) return SupplierTransaction.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by supplier+particulars+total.
      final transactions = await getSupplierTransactions();
      final matches = transactions.where((t) => t.supplierId == supplierId && t.particulars == particulars && t.totalPayment == totalPayment).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Transaction was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<SupplierTransaction> updateSupplierTransaction({
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
    try {
      final response = await _dio.patch(
        '${ApiConstants.supplierTransactions}/$id',
        data: {
          'supplierId': supplierId,
          'date': date,
          'particulars': particulars,
          if (toReceived != null) 'toReceived': toReceived,
          if (toPay != null) 'toPay': toPay,
          'paymentMethodId': paymentMethodId,
          'totalPayment': totalPayment,
          if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
        },
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['particulars'] != null) return SupplierTransaction.fromJson(raw);

      final transactions = await getSupplierTransactions();
      final match = transactions.where((t) => t.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Transaction was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteSupplierTransaction(String id) async {
    try {
      await _dio.delete('${ApiConstants.supplierTransactions}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
