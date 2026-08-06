import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/customer/customer_model.dart';
import '../data/repositories/customer_comment_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for the Customer detail screen's Comments tab, backed by
/// `/api/customer-comments`. Scoped to whichever customer is currently
/// being viewed — [fetchComments] replaces [comments] each time it's
/// called for a (possibly different) customer.
class CustomerCommentProvider extends ChangeNotifier {
  final CustomerCommentRepository _repository;

  CustomerCommentProvider({required CustomerCommentRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<CustomerComment> comments = [];
  String? errorMessage;
  String? _customerId;

  Future<void> fetchComments(String customerId) async {
    _customerId = customerId;
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      comments = await _repository.getCommentsForCustomer(customerId);
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  bool isCreating = false;
  String? createErrorMessage;

  Future<CustomerComment?> addComment(String comment) async {
    final customerId = _customerId;
    if (customerId == null) return null;

    isCreating = true;
    createErrorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createComment(customerId: customerId, comment: comment);
      comments = [...comments, created];
      return created;
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

  Future<bool> updateComment({required String id, required String comment}) async {
    isUpdating = true;
    updateErrorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateComment(id: id, comment: comment);
      comments = comments.map((c) => c.id == id ? updated : c).toList();
      return true;
    } on ApiException catch (e) {
      updateErrorMessage = e.message;
      return false;
    } catch (_) {
      updateErrorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  bool isDeleting = false;
  String? deleteErrorMessage;

  Future<bool> deleteComment(String id) async {
    isDeleting = true;
    deleteErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteComment(id);
      comments = comments.where((c) => c.id != id).toList();
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
