import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/restaurant_profile.dart';
import '../models/restaurant_type.dart';
import '../models/update_restaurant_request.dart';

/// Restaurant profile API calls.
class RestaurantService {
  static Future<RestaurantProfile> getRestaurantProfile() async {
    try {
      final response = await ApiClient.instance.get('/restaurant');
      final list = response.data['data'] as List<dynamic>;
      if (list.isEmpty) {
        throw const ApiException('No restaurant found for this account.');
      }
      return RestaurantProfile.fromJson(list.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// `PATCH /api/restaurant/settings` (operation id `updateMyRestro`).
  static Future<RestaurantProfile> updateRestaurantSettings(UpdateRestaurantRequest request) async {
    try {
      final response = await ApiClient.instance.patch('/restaurant/settings', data: request.toJson());
      final data = response.data['data'] as Map<String, dynamic>;
      return RestaurantProfile.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// `GET /api/type-of-restro`, used to populate the Type chips with real
  /// ids instead of hardcoded strings.
  static Future<List<RestaurantType>> getRestaurantTypes() async {
    try {
      final response = await ApiClient.instance.get('/type-of-restro');
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => RestaurantType.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
