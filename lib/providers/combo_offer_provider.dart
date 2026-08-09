import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/combo_offer/combo_offer_model.dart';
import '../data/repositories/combo_offer_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Combo Offer list and Add/Edit Combo form.
class ComboOfferProvider extends ChangeNotifier {
  final ComboOfferRepository _repository;

  ComboOfferProvider({required ComboOfferRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<ComboOffer> offers = [];
  String? errorMessage;

  Future<void> fetchComboOffers() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      offers = await _repository.getComboOffers();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<ComboOffer?> createComboOffer({
    required String name,
    String? description,
    String? hsCode,
    String? comboPhoto,
    required List<String> dishIds,
    required double offerPrice,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final offer = await _repository.createComboOffer(
        name: name,
        description: description,
        hsCode: hsCode,
        comboPhoto: comboPhoto,
        dishIds: dishIds,
        offerPrice: offerPrice,
        startsAt: startsAt,
        endsAt: endsAt,
      );
      offers = [...offers, offer];
      return offer;
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

  /// Updates a combo offer and replaces it in [offers] on success. Returns
  /// the updated [ComboOffer], or `null` if the call failed (see
  /// [updateErrorMessage]).
  Future<ComboOffer?> updateComboOffer({
    required String id,
    required String name,
    String? description,
    String? hsCode,
    String? comboPhoto,
    required List<String> dishIds,
    required double offerPrice,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final offer = await _repository.updateComboOffer(
        id: id,
        name: name,
        description: description,
        hsCode: hsCode,
        comboPhoto: comboPhoto,
        dishIds: dishIds,
        offerPrice: offerPrice,
        startsAt: startsAt,
        endsAt: endsAt,
      );
      offers = offers.map((o) => o.id == id ? offer : o).toList();
      return offer;
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

  Future<bool> deleteComboOffer(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteComboOffer(id);
      offers = offers.where((o) => o.id != id).toList();
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
