import 'dart:math' show cos, pi, sin, sqrt, atan2;

/// Utilitários de geolocalização.
/// Uso: cálculo de distância (Haversine), integração com [geolocator] nas telas.
class LocationUtils {
  LocationUtils._();

  /// Raio da Terra em km (para fórmula de Haversine).
  static const double earthRadiusKm = 6371.0;

  /// Calcula a distância em km entre dois pontos (fórmula de Haversine).
  /// [lat1], [lng1]: ponto 1 em graus.
  /// [lat2], [lng2]: ponto 2 em graus.
  /// Retorna distância em km (1 casa decimal).
  static double distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final km = earthRadiusKm * c;
    return (km * 10).round() / 10;
  }

  static double _toRad(double deg) => deg * pi / 180;
}
