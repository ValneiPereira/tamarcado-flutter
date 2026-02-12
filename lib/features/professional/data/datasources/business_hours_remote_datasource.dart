import 'package:dio/dio.dart';
import '../models/business_hours_model.dart';

class BusinessHoursRemoteDatasource {
  final Dio _dio;

  BusinessHoursRemoteDatasource(this._dio);

  Future<List<BusinessHoursModel>> getBusinessHours() async {
    final response = await _dio.get('/professionals/me/business-hours');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => BusinessHoursModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BusinessHoursModel>> updateBusinessHours(
      List<BusinessHoursModel> hours) async {
    final response = await _dio.put('/professionals/me/business-hours', data: {
      'hours': hours.map((h) => h.toJson()).toList(),
    });
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => BusinessHoursModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
