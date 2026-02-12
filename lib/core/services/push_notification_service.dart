import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../network/dio_client.dart';
import '../../features/shared/data/datasources/notification_remote_datasource.dart';

/// Inicializa FCM e registra o device token no backend quando o usuário está autenticado.
/// Chamar após login ou quando o app abre com sessão restaurada.
Future<void> registerFcmTokenIfAuthenticated(dynamic ref) async {
  if (kIsWeb) return;

  final authState = ref.read(authProvider);
  if (!authState.isAuthenticated) return;

  try {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token == null || token.isEmpty) return;

    final platform = _getPlatform();
    if (platform == null) return;

    final dio = ref.read(dioClientProvider).dio;
    final ds = NotificationRemoteDatasource(dio);
    await ds.registerDevice(deviceToken: token, platformName: platform);
  } catch (_) {
    // Falha silenciosa (ex.: Firebase não configurado, sem rede)
  }
}

String? _getPlatform() {
  if (kIsWeb) return null;
  if (defaultTargetPlatform == TargetPlatform.android) return 'ANDROID';
  if (defaultTargetPlatform == TargetPlatform.iOS) return 'IOS';
  return null;
}
