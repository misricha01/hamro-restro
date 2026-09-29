import 'package:dio/dio.dart';
import '../core/network/api_constants.dart';
import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../models/restaurant_profile.dart';
import '../models/restaurant_type.dart';
import '../models/update_restaurant_request.dart';

/// Restaurant profile and settings API service.
/// Uses the unified [DioClient] singleton to ensure secure auth tokens,
/// automatic 401 session refresh, and tenant subdomain routing.
class RestaurantService {
  static Dio get _dio => DioClient.instance.dio;

  /// `GET /api/restaurant`
  static Future<RestaurantProfile> getRestaurantProfile() async {
    try {
      final response = await _dio.get(ApiConstants.restaurant);
      final list = response.data['data'] as List<dynamic>? ?? [];
      if (list.isEmpty) {
        throw const ApiException('No restaurant found for this account.');
      }
      return RestaurantProfile.fromJson(list.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// `PATCH /api/restaurant/settings`
  static Future<RestaurantProfile> updateRestaurantSettings(
      UpdateRestaurantRequest request,
      ) async {
    try {
      final response = await _dio.patch(
        ApiConstants.restaurantSettings,
        data: request.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RestaurantProfile.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// `GET /api/type-of-restro`
  static Future<List<RestaurantType>> getRestaurantTypes() async {
    try {
      final response = await _dio.get(ApiConstants.typeOfRestro);
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => RestaurantType.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// `POST /api/restaurant/transfer-ownership`
  static Future<void> transferOwnership(String userId) async {
    try {
      await _dio.post(
        ApiConstants.transferOwnership,
        data: {'userId': userId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}