import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/orders/order_model.dart';

/// A single row from `GET /api/kot` — the same [Kot] shape nested under
/// [Order.kots], plus whatever order/table context the standalone endpoint
/// attaches. That context wasn't live-verified beyond a 200 during the
/// audit, so `orderId`/`tableName`/`createdAt` are all parsed defensively
/// and may come back null; callers should fall back to the KOT number
/// alone when they do.
class KotRecord {
  final Kot kot;
  final String? orderId;
  final String? tableName;
  final DateTime? createdAt;

  const KotRecord({required this.kot, this.orderId, this.tableName, this.createdAt});

  factory KotRecord.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>?;
    final table = json['table'] ?? order?['table'];
    return KotRecord(
      kot: Kot.fromJson(json),
      orderId: (json['orderId'] ?? order?['id'])?.toString(),
      tableName: json['tableName'] as String? ?? (table is Map<String, dynamic> ? table['tableName'] as String? : null),
      createdAt: DateTime.tryParse((json['createdAt'] ?? order?['createdAt']) as String? ?? ''),
    );
  }
}

abstract class KotRepository {
  Future<List<KotRecord>> getKots();

  /// `PATCH /api/kot/{id}` with just `orderStatus` — used for "Mark
  /// Complete" (KOTs are created server-side as a side effect of
  /// `POST /api/order`, so there's no standalone create flow here).
  Future<Kot> updateKotStatus({required String id, required String orderStatus});

  Future<void> deleteKot(String id);
}

class KotRepositoryImpl implements KotRepository {
  final Dio _dio;

  KotRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<KotRecord>> getKots() async {
    try {
      final response = await _dio.get(ApiConstants.kot);
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => KotRecord.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Kot> updateKotStatus({required String id, required String orderStatus}) async {
    try {
      final response = await _dio.patch('${ApiConstants.kot}/$id', data: {'orderStatus': orderStatus});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['orderStatus'] != null) return Kot.fromJson(raw);

      final kots = await getKots();
      final match = kots.where((k) => k.kot.id == id).toList();
      if (match.isNotEmpty) return match.first.kot;
      throw const ApiException('KOT was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteKot(String id) async {
    try {
      await _dio.delete('${ApiConstants.kot}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
