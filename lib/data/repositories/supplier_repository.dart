import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/supplier/supplier_model.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> getSuppliers();

  Future<Supplier> createSupplier({
    required String supplierName,
    required String phoneNumber,
    String? address,
    String? remarks,
  });

  Future<Supplier> updateSupplier({
    required String id,
    required String supplierName,
    required String phoneNumber,
    String? address,
    String? remarks,
  });

  Future<void> deleteSupplier(String id);
}

class SupplierRepositoryImpl implements SupplierRepository {
  final Dio _dio;

  SupplierRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Supplier>> getSuppliers() async {
    try {
      final response = await _dio.get(ApiConstants.suppliers, queryParameters: {'page': 1, 'take': 200});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Supplier.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _body({
    required String supplierName,
    required String phoneNumber,
    String? address,
    String? remarks,
  }) {
    return {
      'supplierName': supplierName,
      'phoneNumber': phoneNumber,
      'address': address,
      'remarks': remarks,
    };
  }

  @override
  Future<Supplier> createSupplier({
    required String supplierName,
    required String phoneNumber,
    String? address,
    String? remarks,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.suppliers,
        data: _body(supplierName: supplierName, phoneNumber: phoneNumber, address: address, remarks: remarks),
      );

      // Confirmed: POST /api/supplier returns `data: {id}` on success —
      // just the id, not the full entity — so refetch and match by it.
      final id = (response.data['data'] as Map<String, dynamic>)['id'].toString();
      final suppliers = await getSuppliers();
      final match = suppliers.where((s) => s.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Supplier was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Supplier> updateSupplier({
    required String id,
    required String supplierName,
    required String phoneNumber,
    String? address,
    String? remarks,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.suppliers}/$id',
        data: _body(supplierName: supplierName, phoneNumber: phoneNumber, address: address, remarks: remarks),
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['supplierName'] != null) return Supplier.fromJson(raw);

      // Same "response only echoes an id (or nothing)" situation as create —
      // refetch and match by id.
      final suppliers = await getSuppliers();
      final match = suppliers.where((s) => s.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Supplier was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      await _dio.delete('${ApiConstants.suppliers}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
