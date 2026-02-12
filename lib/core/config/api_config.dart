import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  ApiConfig._();

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  static String get baseUrl {
    if (kDebugMode) {
      if (kIsWeb) {
        return 'http://localhost:8080/api/v1';
      }
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api/v1';
      }
      return 'http://localhost:8080/api/v1';
    }
    return const String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://api.tamarcado.com.br/api/v1',
    );
  }
}
