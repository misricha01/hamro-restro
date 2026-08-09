import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/media/media_model.dart';
import '../data/repositories/media_repository.dart';

/// ViewModel for every photo/attachment picker in the app (Dish photo,
/// Restaurant logo, etc.), backed by [MediaRepository.uploadFile]
/// (`POST /api/media`). Deliberately stateless beyond the in-flight upload —
/// there's no list of media to hold, each screen just calls [uploadFile] and
/// keeps the returned [UploadedMedia] itself.
class MediaProvider extends ChangeNotifier {
  final MediaRepository _repository;

  MediaProvider({required MediaRepository repository}) : _repository = repository;

  bool isUploading = false;
  String? uploadErrorMessage;

  Future<UploadedMedia?> uploadFile(String filePath) async {
    isUploading = true;
    uploadErrorMessage = null;
    notifyListeners();

    try {
      return await _repository.uploadFile(filePath);
    } on ApiException catch (e) {
      uploadErrorMessage = e.message;
      return null;
    } catch (_) {
      uploadErrorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }
}
