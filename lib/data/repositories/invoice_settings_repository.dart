import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/invoice_settings/invoice_settings_model.dart';

abstract class InvoiceSettingsRepository {
  Future<InvoiceSettings> getMyInvoiceSettings();

  Future<InvoiceSettings> updateMyInvoiceSettings(InvoiceSettings settings);
}

class InvoiceSettingsRepositoryImpl implements InvoiceSettingsRepository {
  final Dio _dio;

  InvoiceSettingsRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<InvoiceSettings> getMyInvoiceSettings() async {
    try {
      final response = await _dio.get(ApiConstants.myInvoiceSettings);
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return InvoiceSettings.fromJson(raw);
      return const InvoiceSettings();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<InvoiceSettings> updateMyInvoiceSettings(InvoiceSettings settings) async {
    try {
      final response = await _dio.patch(ApiConstants.myInvoiceSettings, data: settings.toJson());
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return InvoiceSettings.fromJson(raw);
      return settings;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
