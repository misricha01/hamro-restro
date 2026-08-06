import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/customer/customer_model.dart';
import '../data/repositories/customer_group_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Customer Group picker (Add/Edit Customer).
class CustomerGroupProvider extends ChangeNotifier {
  final CustomerGroupRepository _repository;

  CustomerGroupProvider({required CustomerGroupRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<CustomerGroup> groups = [];
  String? errorMessage;

  Future<void> fetchCustomerGroups() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      groups = await _repository.getCustomerGroups();
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<CustomerGroup?> createCustomerGroup({required String name, String? description}) async {
    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final group = await _repository.createCustomerGroup(name: name, description: description);
      groups = [...groups, group];
      return group;
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
