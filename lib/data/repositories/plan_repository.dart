import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/subscription/plan_model.dart';

/// Read-only — plan/feature/price management (create/update/delete) is
/// SUPER_ADMIN-only on this backend, not self-service from the restaurant
/// app.
abstract class PlanRepository {
  Future<List<Plan>> getPlans();

  Future<List<PlanPrice>> getPlanPrices();

  Future<List<PlanFeatureDef>> getFeatures();

  Future<List<PlanFeatureGrant>> getPlanFeatures();
}

class PlanRepositoryImpl implements PlanRepository {
  final Dio _dio;

  PlanRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Plan>> getPlans() async {
    try {
      final response = await _dio.get(ApiConstants.plans);
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => Plan.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<PlanPrice>> getPlanPrices() async {
    try {
      final response = await _dio.get(ApiConstants.planPrices);
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => PlanPrice.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<PlanFeatureDef>> getFeatures() async {
    try {
      final response = await _dio.get(ApiConstants.features);
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => PlanFeatureDef.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<PlanFeatureGrant>> getPlanFeatures() async {
    try {
      final response = await _dio.get(ApiConstants.planFeatures);
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => PlanFeatureGrant.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
