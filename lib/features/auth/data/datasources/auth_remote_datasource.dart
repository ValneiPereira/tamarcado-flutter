import 'package:dio/dio.dart';
import '../models/auth_response.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> registerClient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Map<String, dynamic> address,
  }) async {
    final response = await _dio.post('/auth/register/client', data: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> registerProfessional({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Map<String, dynamic> address,
    required String category,
    required String serviceType,
    required List<Map<String, dynamic>> services,
  }) async {
    final response = await _dio.post('/auth/register/professional', data: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'category': category,
      'serviceType': serviceType,
      'services': services,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post('/auth/refresh-token', data: {
      'refreshToken': refreshToken,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }
}
