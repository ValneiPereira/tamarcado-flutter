import 'package:dio/dio.dart';

/// Registra device token e lista notificações.
/// API: POST /notifications/register-device, GET /notifications, etc.
class NotificationRemoteDatasource {
  final Dio _dio;

  NotificationRemoteDatasource(this._dio);

  /// Registra o device token para push notifications.
  /// [deviceToken]: FCM token.
  /// [platformName]: "ANDROID" ou "IOS" (conforme backend).
  Future<void> registerDevice({
    required String deviceToken,
    required String platformName,
  }) async {
    await _dio.post('/notifications/register-device', data: {
      'deviceToken': deviceToken,
      'platform': platformName,
    });
  }

  /// Lista notificações do usuário.
  /// [unreadOnly]: se true, retorna apenas não lidas.
  Future<List<Map<String, dynamic>>> getNotifications({
    bool unreadOnly = false,
  }) async {
    final response = await _dio.get(
      '/notifications',
      queryParameters: {if (unreadOnly) 'unreadOnly': true},
    );
    final data = response.data;
    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(
        (data['data'] as List).map((e) => e as Map<String, dynamic>),
      );
    }
    return [];
  }

  /// Marca notificação como lida.
  Future<void> markAsRead(String notificationId) async {
    await _dio.put('/notifications/$notificationId/read');
  }

  /// Remove device token.
  Future<void> deleteDeviceToken(String deviceToken) async {
    await _dio.delete('/notifications/device/$deviceToken');
  }
}
