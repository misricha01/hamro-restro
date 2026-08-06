import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/dashboard/dashboard_overview_model.dart';

abstract class DashboardRepository {
  Future<DashboardOverview> getOverview();
}

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<DashboardOverview> getOverview() async {
    try {
      final response = await _dio.get(ApiConstants.dashboardOverview);
      return DashboardOverview.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
