import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/addon/addon_model.dart';
import '../data/repositories/addon_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Add-On / Extra list, shared by [SelectAddOnsSheet] and
/// the Manage screen's "Add-Ons or Extras" row.
class AddOnProvider extends ChangeNotifier {
  final AddOnRepository _repository;

  AddOnProvider({required AddOnRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<AddOn> addons = [];
  String? errorMessage;

  bool isCreating = false;
  String? createErrorMessage;

  Future<void> fetchAddOns() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      addons = await _repository.getAddOns();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Creates an add-on and appends it to [addons] on success. Returns the
  /// created [AddOn], or `null` if the call failed (see [createErrorMessage]).
  Future<AddOn?> createAddOn({required String addonName, required double price}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final addon = await _repository.createAddOn(addonName: addonName, price: price);
      addons = [...addons, addon];
      return addon;
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

  /// Updates an add-on and replaces it in [addons] on success. Returns the
  /// updated [AddOn], or `null` if the call failed (see [updateErrorMessage]).
  Future<AddOn?> updateAddOn({required String id, required String addonName, required double price}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final addon = await _repository.updateAddOn(id: id, addonName: addonName, price: price);
      addons = addons.map((a) => a.id == id ? addon : a).toList();
      return addon;
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

  /// Deletes an add-on and removes it from [addons] on success. Returns
  /// whether the call succeeded (see [deleteErrorMessage] on failure).
  Future<bool> deleteAddOn(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteAddOn(id);
      addons = addons.where((a) => a.id != id).toList();
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
