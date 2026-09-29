import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/variant/variant_model.dart';

abstract class VariantRepository {
  Future<List<Variant>> getVariants();

  Future<Variant> createVariant({
    required String variantName,
    String? unitId,
    required double actualPrice,
    required double discount,
    required double cogs,
  });

  Future<Variant> updateVariant({
    required String id,
    required String variantName,
    String? unitId,
    required double actualPrice,
    required double discount,
    required double cogs,
  });

  Future<void> deleteVariant(String id);
}

class VariantRepositoryImpl implements VariantRepository {
  final Dio _dio;

  VariantRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Variant>> getVariants() async {
    try {
      final response = await _dio.get(ApiConstants.variants, queryParameters: {'page': 1, 'take': 200});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Variant.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // `unitId` is deliberately not sent: the backend's Create/UpdateVariantDTO
  // has no such field and rejects the request with
  // "property unitId should not exist" (verified live 2026-09-29).
  Map<String, dynamic> _body({
    required String variantName,
    required double actualPrice,
    required double discount,
    required double cogs,
  }) {
    return {
      'variantName': variantName,
      'actualPrice': actualPrice,
      'discount': discount,
      'cogs': cogs,
    };
  }

  @override
  Future<Variant> createVariant({
    required String variantName,
    String? unitId,
    required double actualPrice,
    required double discount,
    required double cogs,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.variants,
        data: _body(variantName: variantName, actualPrice: actualPrice, discount: discount, cogs: cogs),
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['variantName'] != null) return Variant.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match by name.
      final variants = await getVariants();
      final matches = variants.where((v) => v.variantName == variantName).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Variant was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Variant> updateVariant({
    required String id,
    required String variantName,
    String? unitId,
    required double actualPrice,
    required double discount,
    required double cogs,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.variants}/$id',
        data: _body(variantName: variantName, actualPrice: actualPrice, discount: discount, cogs: cogs),
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['variantName'] != null) return Variant.fromJson(raw);

      final variants = await getVariants();
      final match = variants.where((v) => v.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Variant was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteVariant(String id) async {
    try {
      await _dio.delete('${ApiConstants.variants}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
