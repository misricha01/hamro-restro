import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/supplier/supplier_model.dart';
import '../data/repositories/supplier_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the supplier list/detail and Add/Edit Supplier form.
class SupplierProvider extends ChangeNotifier {
  final SupplierRepository _repository;

  SupplierProvider({required SupplierRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Supplier> suppliers = [];
  String? errorMessage;

  Future<void> fetchSuppliers() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      suppliers = await _repository.getSuppliers();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  /// Creates a supplier and appends it to [suppliers] on success. Returns
  /// the created [Supplier], or `null` if the call failed (see
  /// [createErrorMessage]).
  Future<Supplier?> createSupplier({
    required String supplierName,
    required String phoneNumber,
    String? address,
    String? remarks,
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final supplier = await _repository.createSupplier(
        supplierName: supplierName,
        phoneNumber: phoneNumber,
        address: address,
        remarks: remarks,
      );
      suppliers = [...suppliers, supplier];
      return supplier;
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

  /// Updates a supplier and replaces it in [suppliers] on success. Returns
  /// the updated [Supplier], or `null` if the call failed (see
  /// [updateErrorMessage]).
  Future<Supplier?> updateSupplier({
    required String id,
    required String supplierName,
    required String phoneNumber,
    String? address,
    String? remarks,
  }) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final supplier = await _repository.updateSupplier(
        id: id,
        supplierName: supplierName,
        phoneNumber: phoneNumber,
        address: address,
        remarks: remarks,
      );
      suppliers = suppliers.map((s) => s.id == id ? supplier : s).toList();
      return supplier;
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

  /// Deletes a supplier and removes it from [suppliers] on success. Returns
  /// whether the call succeeded (see [deleteErrorMessage] on failure).
  Future<bool> deleteSupplier(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteSupplier(id);
      suppliers = suppliers.where((s) => s.id != id).toList();
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
