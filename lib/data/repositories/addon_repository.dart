import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/addon/addon_model.dart';

abstract class AddOnRepository {
  Future<List<AddOn>> getAddOns();

  Future<AddOn> createAddOn({required String addonName, required double price});
}

class AddOnRepositoryImpl implements AddOnRepository {
  final Dio _dio;

  AddOnRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<AddOn>> getAddOns() async {
    try {
      final response = await _dio.get(ApiConstants.addons);
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => AddOn.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AddOn> createAddOn({required String addonName, required double price}) async {
    try {
      final response = await _dio.post(ApiConstants.addons, data: {'addonName': addonName, 'price': price});
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
}
