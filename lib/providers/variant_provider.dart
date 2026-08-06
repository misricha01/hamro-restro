import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/variant/variant_model.dart';
import '../data/repositories/variant_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Edit Variant flow (Add Dish's Variants section).
class VariantProvider extends ChangeNotifier {
  final VariantRepository _repository;

  VariantProvider({required VariantRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Variant> variants = [];
  String? errorMessage;

  Future<void> fetchVariants() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      variants = await _repository.getVariants();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isSaving = false;
  String? saveErrorMessage;

  Future<Variant?> createVariant({
    required String variantName,
    String? unitId,
    required double actualPrice,
    required double discount,
    required double cogs,
  }) async {
    isSaving = true;
    saveErrorMessage = null;
    notifyListeners();

    try {
      final variant = await _repository.createVariant(variantName: variantName, unitId: unitId, actualPrice: actualPrice, discount: discount, cogs: cogs);
      variants = [...variants, variant];
      return variant;
    } on ApiException catch (e) {
      saveErrorMessage = e.message;
      return null;
    } catch (_) {
      saveErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<Variant?> updateVariant({
    required String id,
    required String variantName,
    String? unitId,
    required double actualPrice,
    required double discount,
    required double cogs,
  }) async {
    isSaving = true;
    saveErrorMessage = null;
    notifyListeners();

    try {
      final variant = await _repository.updateVariant(id: id, variantName: variantName, unitId: unitId, actualPrice: actualPrice, discount: discount, cogs: cogs);
      variants = variants.map((v) => v.id == id ? variant : v).toList();
      return variant;
    } on ApiException catch (e) {
      saveErrorMessage = e.message;
      return null;
    } catch (_) {
      saveErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  bool isDeleting = false;
  String? deleteErrorMessage;

  Future<bool> deleteVariant(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteVariant(id);
      variants = variants.where((v) => v.id != id).toList();
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
