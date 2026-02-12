import 'package:dio/dio.dart';
import '../models/professional_model.dart';
import '../models/service_model.dart';

class ProfessionalsRemoteDatasource {
  final Dio _dio;

  ProfessionalsRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> searchProfessionals({
    String? serviceId,
    String? category,
    String? serviceType,
    double? latitude,
    double? longitude,
    double? maxDistanceKm,
    String sortBy = 'distance',
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get('/search/professionals', queryParameters: {
      if (serviceId != null) 'serviceId': serviceId,
      if (category != null) 'category': category,
      if (serviceType != null) 'serviceType': serviceType,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (maxDistanceKm != null) 'maxDistanceKm': maxDistanceKm,
      'sortBy': sortBy,
      'page': page,
      'size': size,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<ProfessionalModel> getProfessionalById(
    String id, {
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.get('/professionals/$id', queryParameters: {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return ProfessionalModel.fromJson(data);
  }

  Future<List<ServiceModel>> getMyServices() async {
    final response = await _dio.get('/professionals/me/services');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceModel> createService({
    required String name,
    required double price,
  }) async {
    final response = await _dio.post('/professionals/me/services', data: {
      'name': name,
      'price': price,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return ServiceModel.fromJson(data);
  }

  Future<ServiceModel> updateService({
    required String serviceId,
    required String name,
    required double price,
  }) async {
    final response = await _dio.put(
      '/professionals/me/services/$serviceId',
      data: {'name': name, 'price': price},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return ServiceModel.fromJson(data);
  }

  Future<void> deleteService(String serviceId) async {
    await _dio.delete('/professionals/me/services/$serviceId');
  }

  Future<List<Map<String, dynamic>>> searchServices({
    String? category,
    String? serviceType,
  }) async {
    final response = await _dio.get('/search/services', queryParameters: {
      if (category != null) 'category': category,
      if (serviceType != null) 'serviceType': serviceType,
    });
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
