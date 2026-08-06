import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/payment_method/payment_method_model.dart';

abstract class PaymentMethodRepository {
  Future<List<PaymentMode>> getPaymentMethods();

  Future<PaymentMode> createPaymentMethod({required String name, String? remarks});

  Future<PaymentMode> updatePaymentMethod({required String id, required String name, String? remarks});

  Future<void> deletePaymentMethod(String id);
}

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final Dio _dio;

  PaymentMethodRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<PaymentMode>> getPaymentMethods() async {
    try {
      final response = await _dio.get(ApiConstants.paymentMethods, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => PaymentMode.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _body({required String name, String? remarks}) {
    return {'name': name, if (remarks != null && remarks.isNotEmpty) 'remarks': remarks};
  }

  @override
  Future<PaymentMode> createPaymentMethod({required String name, String? remarks}) async {
    try {
      final response = await _dio.post(ApiConstants.paymentMethods, data: _body(name: name, remarks: remarks));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return PaymentMode.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by name.
      final methods = await getPaymentMethods();
      final matches = methods.where((m) => m.name == name).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Payment mode was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PaymentMode> updatePaymentMethod({required String id, required String name, String? remarks}) async {
    try {
      final response = await _dio.patch('${ApiConstants.paymentMethods}/$id', data: _body(name: name, remarks: remarks));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return PaymentMode.fromJson(raw);

      final methods = await getPaymentMethods();
      final match = methods.where((m) => m.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Payment mode was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    try {
      await _dio.delete('${ApiConstants.paymentMethods}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
