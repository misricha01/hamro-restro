import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/customer/customer_model.dart';

abstract class CustomerGroupRepository {
  Future<List<CustomerGroup>> getCustomerGroups();

  Future<CustomerGroup> createCustomerGroup({required String name, String? description});

  Future<CustomerGroup> updateCustomerGroup({required String id, required String name, String? description});

  Future<void> deleteCustomerGroup(String id);
}

class CustomerGroupRepositoryImpl implements CustomerGroupRepository {
  final Dio _dio;

  CustomerGroupRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<CustomerGroup>> getCustomerGroups() async {
    try {
      final response = await _dio.get(ApiConstants.customerGroups, queryParameters: {'page': 1, 'take': 100});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => CustomerGroup.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _body({required String name, String? description}) {
    return {'name': name, if (description != null && description.isNotEmpty) 'description': description};
  }

  @override
  Future<CustomerGroup> createCustomerGroup({required String name, String? description}) async {
    try {
      final response = await _dio.post(ApiConstants.customerGroups, data: _body(name: name, description: description));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return CustomerGroup.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by name.
      final groups = await getCustomerGroups();
      final matches = groups.where((g) => g.name == name).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Customer group was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<CustomerGroup> updateCustomerGroup({required String id, required String name, String? description}) async {
    try {
      final response = await _dio.patch('${ApiConstants.customerGroups}/$id', data: _body(name: name, description: description));
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['name'] != null) return CustomerGroup.fromJson(raw);

      final groups = await getCustomerGroups();
      final match = groups.where((g) => g.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Customer group was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteCustomerGroup(String id) async {
    try {
      await _dio.delete('${ApiConstants.customerGroups}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
