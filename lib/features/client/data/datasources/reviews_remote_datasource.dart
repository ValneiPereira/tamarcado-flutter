import 'package:dio/dio.dart';
import '../models/review_model.dart';

class ReviewsRemoteDatasource {
  final Dio _dio;

  ReviewsRemoteDatasource(this._dio);

  Future<ReviewModel> createReview({
    required String appointmentId,
    required int rating,
    String? comment,
  }) async {
    final response = await _dio.post('/reviews', data: {
      'appointmentId': appointmentId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return ReviewModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getProfessionalReviews(
    String professionalId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      '/reviews/professionals/$professionalId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<ReviewModel>> getMyReviews() async {
    final response = await _dio.get('/reviews/client/me');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
