import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/customer/customer_model.dart';
import '../data/repositories/customer_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the customer list/detail and Add/Edit Customer form.
class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository;

  CustomerProvider({required CustomerRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Customer> customers = [];
  String? errorMessage;

  Future<void> fetchCustomers() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      customers = await _repository.getCustomers();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  /// Creates a customer and appends it to [customers] on success. Returns
  /// the created [Customer], or `null` if the call failed (see
  /// [createErrorMessage]).
  Future<Customer?> createCustomer({
    required String customerName,
    required String phoneNumber,
    String? emailAddress,
    String? companyName,
    String? panVatNumber,
    String? discount,
    String? customerGroupId,
    String? favouriteDishId,
    String? preferredSeatingId,
    String? dietaryTypeId,
    String? allergies,
    String? startPreferredTime,
    String? endPreferredTime,
    List<String> comments = const [],
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final customer = await _repository.createCustomer(
        customerName: customerName,
        phoneNumber: phoneNumber,
        emailAddress: emailAddress,
        companyName: companyName,
        panVatNumber: panVatNumber,
        discount: discount,
        customerGroupId: customerGroupId,
        favouriteDishId: favouriteDishId,
        preferredSeatingId: preferredSeatingId,
        dietaryTypeId: dietaryTypeId,
        allergies: allergies,
        startPreferredTime: startPreferredTime,
        endPreferredTime: endPreferredTime,
        comments: comments,
      );
      customers = [...customers, customer];
      return customer;
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

  /// Updates a customer and replaces it in [customers] on success. Returns
  /// the updated [Customer], or `null` if the call failed (see
  /// [updateErrorMessage]).
  Future<Customer?> updateCustomer({
    required String id,
    required String customerName,
    required String phoneNumber,
    String? emailAddress,
    String? companyName,
    String? panVatNumber,
    String? discount,
    String? customerGroupId,
    String? favouriteDishId,
    String? preferredSeatingId,
    String? dietaryTypeId,
    String? allergies,
    String? startPreferredTime,
    String? endPreferredTime,
    List<String> comments = const [],
  }) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final customer = await _repository.updateCustomer(
        id: id,
        customerName: customerName,
        phoneNumber: phoneNumber,
        emailAddress: emailAddress,
        companyName: companyName,
        panVatNumber: panVatNumber,
        discount: discount,
        customerGroupId: customerGroupId,
        favouriteDishId: favouriteDishId,
        preferredSeatingId: preferredSeatingId,
        dietaryTypeId: dietaryTypeId,
        allergies: allergies,
        startPreferredTime: startPreferredTime,
        endPreferredTime: endPreferredTime,
        comments: comments,
      );
      customers = customers.map((c) => c.id == id ? customer : c).toList();
      return customer;
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

  /// Deletes a customer and removes it from [customers] on success. Returns
  /// whether the call succeeded (see [deleteErrorMessage] on failure).
  Future<bool> deleteCustomer(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteCustomer(id);
      customers = customers.where((c) => c.id != id).toList();
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
