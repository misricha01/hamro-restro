import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/invoice_settings/invoice_settings_model.dart';
import '../data/repositories/invoice_settings_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Invoice Setting screen, backed by `/api/invoice/my`.
class InvoiceSettingsProvider extends ChangeNotifier {
  final InvoiceSettingsRepository _repository;

  InvoiceSettingsProvider({required InvoiceSettingsRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  InvoiceSettings settings = const InvoiceSettings();
  String? errorMessage;

  Future<void> fetchSettings() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      settings = await _repository.getMyInvoiceSettings();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isSaving = false;
  String? saveErrorMessage;

  Future<bool> saveSettings(InvoiceSettings updated) async {
    isSaving = true;
    saveErrorMessage = null;
    notifyListeners();

    try {
      settings = await _repository.updateMyInvoiceSettings(updated);
      return true;
    } on ApiException catch (e) {
      saveErrorMessage = e.message;
      return false;
    } catch (_) {
      saveErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
