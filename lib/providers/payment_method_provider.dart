import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/payment_method/payment_method_model.dart';
import '../data/repositories/payment_method_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for Cash & Banks' Modes tab and the Add/Edit Payment Mode form.
class PaymentMethodProvider extends ChangeNotifier {
  final PaymentMethodRepository _repository;

  PaymentMethodProvider({required PaymentMethodRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<PaymentMode> methods = [];
  String? errorMessage;

  Future<void> fetchPaymentMethods() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      methods = await _repository.getPaymentMethods();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<PaymentMode?> createPaymentMethod({required String name, String? remarks}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final method = await _repository.createPaymentMethod(name: name, remarks: remarks);
      methods = [...methods, method];
      return method;
    } on ApiException catch (e) {
      createErrorMessage = e.message;
      return null;
    } catch (_) {
      createErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  bool isUpdating = false;
  String? updateErrorMessage;

  Future<PaymentMode?> updatePaymentMethod({required String id, required String name, String? remarks}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final method = await _repository.updatePaymentMethod(id: id, name: name, remarks: remarks);
      methods = methods.map((m) => m.id == id ? method : m).toList();
      return method;
    } on ApiException catch (e) {
      updateErrorMessage = e.message;
      return null;
    } catch (_) {
      updateErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  bool isDeleting = false;
  String? deleteErrorMessage;

  Future<bool> deletePaymentMethod(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deletePaymentMethod(id);
      methods = methods.where((m) => m.id != id).toList();
      return true;
    } on ApiException catch (e) {
      deleteErrorMessage = e.message;
      return false;
    } catch (_) {
      deleteErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
