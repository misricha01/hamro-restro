import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/unit/unit_model.dart';
import '../data/repositories/unit_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// Common units shown when `GET /api/unit` fails or returns empty. These
/// have no `id`, so picking one leaves the dish's `unitId` as `null` instead
/// of sending a made-up value.
const List<Unit> kFallbackUnits = [
  Unit(id: null, name: 'Kilogram (kg)'),
  Unit(id: null, name: 'Gram (g)'),
  Unit(id: null, name: 'Piece (pc)'),
  Unit(id: null, name: 'Litre (ltr)'),
  Unit(id: null, name: 'Millilitre (ml)'),
];

class UnitProvider extends ChangeNotifier {
  final UnitRepository _repository;

  UnitProvider({required UnitRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Unit> units = [];
  String? errorMessage;

  /// True once a fetch attempt has failed — callers use this to decide
  /// whether to show [kFallbackUnits] instead of blocking on the error.
  bool get useFallback => status == LoadStatus.error;

  Future<void> fetchUnits() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      units = await _repository.getUnits();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<Unit?> createUnit({required String name, String? description}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final unit = await _repository.createUnit(name: name, description: description);
      units = [...units, unit];
      return unit;
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

  Future<Unit?> updateUnit({required String id, required String name, String? description}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final unit = await _repository.updateUnit(id: id, name: name, description: description);
      units = units.map((u) => u.id == id ? unit : u).toList();
      return unit;
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

  Future<bool> deleteUnit(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteUnit(id);
      units = units.where((u) => u.id != id).toList();
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
