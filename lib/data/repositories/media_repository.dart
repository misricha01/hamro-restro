import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/media/media_model.dart';

abstract class MediaRepository {
  /// `POST /api/media` (single-file upload, `multipart/form-data` field
  /// name `file`). Used for every photo/attachment picker in the app —
  /// dish photo, restaurant logo, expense/purchase attachments, etc.
  Future<UploadedMedia> uploadFile(String filePath);
}

class MediaRepositoryImpl implements MediaRepository {
  final Dio _dio;

  MediaRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<UploadedMedia> uploadFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(ApiConstants.media, data: formData);
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['id'] != null) return UploadedMedia.fromJson(raw);

      // Unlike every other create endpoint in this app, there's no "refetch
      // the list and match by content" fallback available for an anonymous
      // file upload — if the response doesn't carry an id back, there's no
      // way to know which media record was just created.
      throw const ApiException('Upload succeeded, but the server did not return a usable response.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
