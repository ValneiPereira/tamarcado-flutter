class AppConstants {
  AppConstants._();

  static const String appName = 'Tá Marcado!';
  static const String appSlug = 'tamarcado-app';

  // Storage keys
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userKey = 'user';

  // Default location (São Paulo, SP)
  static const double defaultLatitude = -23.550520;
  static const double defaultLongitude = -46.633308;

  // Pagination
  static const int defaultPageSize = 20;

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 3;
}
