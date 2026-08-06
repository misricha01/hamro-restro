import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/type_of_menu/type_of_menu_model.dart';
import '../data/repositories/type_of_menu_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Sub-Menu picker/list (Add Dish's Sub-Menu field, Manage
/// > Menu > Sub Menu).
class TypeOfMenuProvider extends ChangeNotifier {
  final TypeOfMenuRepository _repository;

  TypeOfMenuProvider({required TypeOfMenuRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<TypeOfMenu> types = [];
  String? errorMessage;

  Future<void> fetchTypeOfMenus() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      types = await _repository.getTypeOfMenus();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<TypeOfMenu?> createTypeOfMenu({required String name, required String description, bool status = true}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final type = await _repository.createTypeOfMenu(name: name, description: description, status: status);
      types = [...types, type];
      return type;
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
}
