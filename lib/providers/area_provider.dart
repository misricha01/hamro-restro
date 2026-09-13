import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/area/area_model.dart';
import '../data/repositories/area_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Space (backend: "area") list, shared by the Manage
/// screen's Space tab and the Select Space picker used from Add Table.
class AreaProvider extends ChangeNotifier {
  final AreaRepository _repository;

  AreaProvider({required AreaRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Area> areas = [];
  String? errorMessage;

  bool isCreating = false;
  String? createErrorMessage;

  Future<void> fetchAreas() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      areas = await _repository.getAreas();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Creates a space and appends it to [areas] on success. Returns the
  /// created [Area], or `null` if the call failed (see [createErrorMessage]).
  ///
  /// Uses `finally` for the [isCreating] reset and a catch-all so a
  /// non-[ApiException] failure (e.g. an unexpected response shape) can
  /// never leave the UI stuck on a permanent loading spinner.
  Future<Area?> createArea({required String areaName, String? description}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final area = await _repository.createArea(areaName: areaName, description: description);
      areas = [...areas, area];
      return area;
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

  /// Updates a space and replaces it in [areas] on success. Returns the
  /// updated [Area], or `null` if the call failed (see [updateErrorMessage]).
  Future<Area?> updateArea({required String id, required String areaName, String? description}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final area = await _repository.updateArea(id: id, areaName: areaName, description: description);
      areas = areas.map((a) => a.id == id ? area : a).toList();
      return area;
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

  AreaStats? areaStats;
  LoadStatus areaStatsStatus = LoadStatus.idle;
  String? areaStatsError;

  Future<void> fetchAreaStats() async {
    areaStatsStatus = LoadStatus.loading;
    areaStatsError = null;
    notifyListeners();

    try {
      areaStats = await _repository.getAreaStats();
      areaStatsStatus = LoadStatus.loaded;
    } on ApiException catch (e) {
      areaStatsError = e.message;
      areaStatsStatus = LoadStatus.error;
    } catch (_) {
      areaStatsError = 'Something went wrong. Please try again.';
      areaStatsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isDeleting = false;
  String? deleteErrorMessage;

  /// Deletes a space and removes it from [areas] on success. Returns whether
  /// the call succeeded (see [deleteErrorMessage] on failure).
  Future<bool> deleteArea(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteArea(id);
      areas = areas.where((a) => a.id != id).toList();
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
