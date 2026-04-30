import 'dart:math';

class Haversine {
  static const double earthRadius = 6371; // km

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {

    double dLat = _toRad(lat2 - lat1);
    double dLon = _toRad(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRad(double degree) {
    return degree * pi / 180;
  }

  // GEOFENCING CHECK
  static bool isInsideRadius(double distanceKm, double radiusMeter) {
    return distanceKm * 1000 <= radiusMeter;
  }
}