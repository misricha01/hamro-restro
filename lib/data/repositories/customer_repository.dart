import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/customer/customer_model.dart';
import '../models/customer/customer_insight_model.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers();

  Future<CustomerDiningInsight> getDiningInsight(String customerId);

  Future<CustomerFinanceInsight> getFinanceInsight(String customerId, {String? startDate, String? endDate});

  Future<CustomerSpendingBehaviour> getSpendingBehaviour(String customerId, {String? startDate, String? endDate});

  Future<Customer> createCustomer({
    required String customerName,
    required String phoneNumber,
    String? emailAddress,
    String? companyName,
    String? panVatNumber,
    String? discount,
    String? customerGroupId,
    String? favouriteDishId,
    String? preferredSeatingId,
    String? dietaryTypeId,
    String? allergies,
    String? startPreferredTime,
    String? endPreferredTime,
    List<String> comments,
  });

  Future<Customer> updateCustomer({
    required String id,
    required String customerName,
    required String phoneNumber,
    String? emailAddress,
    String? companyName,
    String? panVatNumber,
    String? discount,
    String? customerGroupId,
    String? favouriteDishId,
    String? preferredSeatingId,
    String? dietaryTypeId,
    String? allergies,
    String? startPreferredTime,
    String? endPreferredTime,
    List<String> comments,
  });

  Future<void> deleteCustomer(String id);
}

class CustomerRepositoryImpl implements CustomerRepository {
  final Dio _dio;

  CustomerRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _dio.get(ApiConstants.customers, queryParameters: {'page': 1, 'take': 200});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _body({
    required String customerName,
    required String phoneNumber,
    String? emailAddress,
    String? companyName,
    String? panVatNumber,
    String? discount,
    String? customerGroupId,
    String? favouriteDishId,
    String? preferredSeatingId,
    String? dietaryTypeId,
    String? allergies,
    String? startPreferredTime,
    String? endPreferredTime,
    required List<String> comments,
  }) {
    return {
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'companyName': companyName,
      'panVatNumber': panVatNumber,
      'discount': discount,
      'customerGroupId': customerGroupId,
      'favouriteDishId': favouriteDishId,
      'preferredSeatingId': preferredSeatingId,
      'dietaryTypeId': dietaryTypeId,
      'allergies': allergies,
      'startPreferredTime': startPreferredTime,
      'endPreferredTime': endPreferredTime,
      if (comments.isNotEmpty) 'comments': comments.map((c) => {'comment': c}).toList(),
    };
  }

  @override
  Future<Customer> createCustomer({
    required String customerName,
    required String phoneNumber,
    String? emailAddress,
    String? companyName,
    String? panVatNumber,
    String? discount,
    String? customerGroupId,
    String? favouriteDishId,
    String? preferredSeatingId,
    String? dietaryTypeId,
    String? allergies,
    String? startPreferredTime,
    String? endPreferredTime,
    List<String> comments = const [],
  }) async {
    try {
      await _dio.post(
        ApiConstants.customers,
        data: _body(
          customerName: customerName,
          phoneNumber: phoneNumber,
          emailAddress: emailAddress,
          companyName: companyName,
          panVatNumber: panVatNumber,
          discount: discount,
          customerGroupId: customerGroupId,
          favouriteDishId: favouriteDishId,
          preferredSeatingId: preferredSeatingId,
          dietaryTypeId: dietaryTypeId,
          allergies: allergies,
          startPreferredTime: startPreferredTime,
          endPreferredTime: endPreferredTime,
          comments: comments,
        ),
      );

      // Confirmed: POST /api/customers returns `data: null` on success, so
      // there's no created entity to parse directly — refetch and match by
      // phoneNumber, which the backend enforces as unique.
      final customers = await getCustomers();
      final matches = customers.where((c) => c.phoneNumber == phoneNumber).toList();
      if (matches.length == 1) return matches.first;
      if (matches.isNotEmpty) {
        matches.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        return matches.first;
      }
      throw const ApiException('Customer was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Customer> updateCustomer({
    required String id,
    required String customerName,
    required String phoneNumber,
    String? emailAddress,
    String? companyName,
    String? panVatNumber,
    String? discount,
    String? customerGroupId,
    String? favouriteDishId,
    String? preferredSeatingId,
    String? dietaryTypeId,
    String? allergies,
    String? startPreferredTime,
    String? endPreferredTime,
    List<String> comments = const [],
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.customers}/$id',
        data: _body(
          customerName: customerName,
          phoneNumber: phoneNumber,
          emailAddress: emailAddress,
          companyName: companyName,
          panVatNumber: panVatNumber,
          discount: discount,
          customerGroupId: customerGroupId,
          favouriteDishId: favouriteDishId,
          preferredSeatingId: preferredSeatingId,
          dietaryTypeId: dietaryTypeId,
          allergies: allergies,
          startPreferredTime: startPreferredTime,
          endPreferredTime: endPreferredTime,
          comments: comments,
        ),
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return Customer.fromJson(raw);

      // Same "response omits the entity" fallback as createCustomer — the
      // update still succeeded, so refetch and match by id.
      final customers = await getCustomers();
      final match = customers.where((c) => c.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Customer was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _dio.delete('${ApiConstants.customers}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<CustomerDiningInsight> getDiningInsight(String customerId) async {
    try {
      final response = await _dio.get('${ApiConstants.customers}/$customerId/dining-insight');
      return CustomerDiningInsight.fromJson(response.data['data'] as Map<String, dynamic>? ?? {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<CustomerFinanceInsight> getFinanceInsight(String customerId, {String? startDate, String? endDate}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.customers}/$customerId/finance-insight',
        queryParameters: {'startDate': ?startDate, 'endDate': ?endDate},
      );
      return CustomerFinanceInsight.fromJson(response.data['data'] as Map<String, dynamic>? ?? {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<CustomerSpendingBehaviour> getSpendingBehaviour(String customerId, {String? startDate, String? endDate}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.customers}/$customerId/spending-behaviour',
        queryParameters: {'startDate': ?startDate, 'endDate': ?endDate},
      );
      return CustomerSpendingBehaviour.fromJson(response.data['data'] as Map<String, dynamic>? ?? {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
