import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/customer/customer_model.dart';

abstract class CustomerCommentRepository {
  Future<List<CustomerComment>> getCommentsForCustomer(String customerId);

  Future<CustomerComment> createComment({required String customerId, required String comment});

  Future<CustomerComment> updateComment({required String id, required String comment});

  Future<void> deleteComment(String id);
}

class CustomerCommentRepositoryImpl implements CustomerCommentRepository {
  final Dio _dio;

  CustomerCommentRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<CustomerComment>> getCommentsForCustomer(String customerId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.customerComments}/customer/$customerId',
        queryParameters: {'page': 1, 'take': 100},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => CustomerComment.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<CustomerComment> createComment({required String customerId, required String comment}) async {
    try {
      final response = await _dio.post(ApiConstants.customerComments, data: {'comment': comment, 'customerId': customerId});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['comment'] != null) return CustomerComment.fromJson(raw);

      // Same "create only echoes an id (or nothing)" situation as other
      // endpoints on this backend — refetch and match the newest comment.
      final comments = await getCommentsForCustomer(customerId);
      final matches = comments.where((c) => c.comment == comment).toList()
        ..sort((a, b) => (int.tryParse(b.id ?? '0') ?? 0).compareTo(int.tryParse(a.id ?? '0') ?? 0));
      if (matches.isNotEmpty) return matches.first;
      throw const ApiException('Comment was added, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<CustomerComment> updateComment({required String id, required String comment}) async {
    try {
      final response = await _dio.patch('${ApiConstants.customerComments}/$id', data: {'comment': comment});
      final raw = response.data['data'];
      if (raw is Map<String, dynamic> && raw['comment'] != null) return CustomerComment.fromJson(raw);
      return CustomerComment(id: id, comment: comment);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteComment(String id) async {
    try {
      await _dio.delete('${ApiConstants.customerComments}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
