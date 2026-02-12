import 'package:dio/dio.dart';
import '../../../auth/data/models/user_model.dart';

class UserRemoteDatasource {
  final Dio _dio;

  UserRemoteDatasource(this._dio);

  Future<UserModel> getProfile() async {
    final response = await _dio.get('/users/me');
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phone,
    Map<String, dynamic>? address,
  }) async {
    final response = await _dio.put('/users/me', data: {
      'name': name,
      'email': email,
      'phone': phone,
      if (address != null) 'address': address,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> updatePhoto(String photoUrl) async {
    final response = await _dio.put('/users/me/photo', data: {
      'photoUrl': photoUrl,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _dio.put('/users/me/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/users/me');
  }
}
