import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/addon/addon_model.dart';

class AddOnStats {
  final int totalAddOn;
  final String? mostUsedName;
  final int? mostUsedOrders;

  const AddOnStats({required this.totalAddOn, this.mostUsedName, this.mostUsedOrders});

  factory AddOnStats.fromJson(Map<String, dynamic> json) {
    final mostUsed = json['mostUsedAddOn'] as Map<String, dynamic>?;
    return AddOnStats(
      totalAddOn: (json['totalAddOn'] as num?)?.toInt() ?? (json['total'] as num?)?.toInt() ?? 0,
      mostUsedName: mostUsed?['addOnName'] as String? ?? mostUsed?['name'] as String?,
      mostUsedOrders: (mostUsed?['noOfOrder'] as num?)?.toInt() ?? (mostUsed?['count'] as num?)?.toInt(),
    );
  }
}

abstract class AddOnRepository {
  Future<List<AddOn>> getAddOns();

  Future<AddOn> createAddOn({required String addonName, required double price, required double cogs});

  Future<AddOn> updateAddOn({required String id, required String addonName, required double price, required double cogs});

  Future<void> deleteAddOn(String id);

  Future<AddOnStats> getAddOnStats();
}

class AddOnRepositoryImpl implements AddOnRepository {
  final Dio _dio;

  AddOnRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<AddOn>> getAddOns() async {
    try {
      final response = await _dio.get(ApiConstants.addons);
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => AddOn.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AddOn> createAddOn({required String addonName, required double price, required double cogs}) async {
    try {
      // Confirmed live: CreateAddonDTO requires `addOnName` (capital O,
      // not `addonName`) and `cogs` (previously never sent) — both 400
      // otherwise ("addOnName must be a string...", "cogs must be a
      // number...").
      final response = await _dio.post(ApiConstants.addons, data: {'addOnName': addonName, 'price': price, 'cogs': cogs});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) {
        return AddOn.fromJson(raw);
      }

      // Some create endpoints in this backend don't return the created
      // entity (just `{status, message, data: null}`) — the call still
      // succeeded (2xx), so fall back to refetching and matching by name
      // rather than surfacing a false failure. See AreaRepositoryImpl.
      final addons = await getAddOns();
      final matches = addons.where((a) => a.addonName == addonName).toList()
        ..sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Add-On was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AddOn> updateAddOn({required String id, required String addonName, required double price, required double cogs}) async {
    try {
      final response = await _dio.patch('${ApiConstants.addons}/$id', data: {'addOnName': addonName, 'price': price, 'cogs': cogs});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['addOnName'] != null) return AddOn.fromJson(raw);

      final addons = await getAddOns();
      final match = addons.where((a) => a.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Add-On was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteAddOn(String id) async {
    try {
      await _dio.delete('${ApiConstants.addons}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AddOnStats> getAddOnStats() async {
    try {
      final response = await _dio.get('${ApiConstants.addons}/stats');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return AddOnStats.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
