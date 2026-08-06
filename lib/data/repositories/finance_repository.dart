import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/finance/finance_dashboard_model.dart';

abstract class FinanceRepository {
  Future<FinanceDashboard> getDashboard();
}

class FinanceRepositoryImpl implements FinanceRepository {
  final Dio _dio;

  FinanceRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<FinanceDashboard> getDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.financeDashboard);
      return FinanceDashboard.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
