import 'package:geolocator/geolocator.dart';
import 'package:medigo_mobile/models/doctor.dart';

/// Utility class for location-based calculations
class LocationUtils {
  /// Calculate distance between two coordinates using Geolocator
  /// Returns distance in kilometers
  /// Note: This is straight-line distance (as the crow flies), not road distance
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Geolocator.distanceBetween returns distance in meters
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Calculate distance from user location to doctor
  /// Uses Geolocator which implements Haversine formula internally
  static double distanceToDoctor(Location userLocation, Doctor doctor) {
    return calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      doctor.location.latitude,
      doctor.location.longitude,
    );
  }

  /// Estimate travel time in minutes based on distance
  /// Assumes average speed of 30 km/h in city
  ///
  /// Note: This is a simple estimate. For accurate road travel times,
  /// consider using Google Distance Matrix API which provides:
  /// - Actual road distances (not straight-line)
  /// - Real-time traffic data
  /// - Multiple travel modes (driving, walking, transit)
  ///
  /// Trade-offs:
  /// - Current (simple): Free, fast, but less accurate (straight-line distance)
  /// - Google Distance Matrix: Accurate, but requires API calls and costs money
  static int estimateTravelTime(double distanceInKm) {
    const double averageSpeedKmh = 30.0; // km/h
    final double timeInHours = distanceInKm / averageSpeedKmh;
    return (timeInHours * 60).round(); // Convert to minutes
  }

  /// Sort doctors by distance from user location
  static List<Doctor> sortByDistance(
    Location userLocation,
    List<Doctor> doctors,
  ) {
    final List<(Doctor, double)> doctorsWithDistance = doctors.map((doctor) {
      final distance = distanceToDoctor(userLocation, doctor);
      return (doctor, distance);
    }).toList();

    doctorsWithDistance.sort((a, b) => a.$2.compareTo(b.$2));

    return doctorsWithDistance.map((item) => item.$1).toList();
  }

  /// Map latitude to screen Y position (for mock map)
  /// This is a simplified projection - in production, use proper map library
  static double latitudeToY(
    double latitude,
    double minLat,
    double maxLat,
    double screenHeight,
  ) {
    final normalized = (maxLat - latitude) / (maxLat - minLat);
    return normalized * screenHeight;
  }

  /// Map longitude to screen X position (for mock map)
  /// This is a simplified projection - in production, use proper map library
  static double longitudeToX(
    double longitude,
    double minLon,
    double maxLon,
    double screenWidth,
  ) {
    final normalized = (longitude - minLon) / (maxLon - minLon);
    return normalized * screenWidth;
  }

  /// Get bounds (min/max lat/lon) from a list of locations
  static ({double minLat, double maxLat, double minLon, double maxLon})
  getBounds(List<Location> locations) {
    if (locations.isEmpty) {
      return (minLat: 0, maxLat: 0, minLon: 0, maxLon: 0);
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLon = locations.first.longitude;
    double maxLon = locations.first.longitude;

    for (final location in locations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLon) minLon = location.longitude;
      if (location.longitude > maxLon) maxLon = location.longitude;
    }

    // Add padding
    final latPadding = (maxLat - minLat) * 0.1;
    final lonPadding = (maxLon - minLon) * 0.1;

    return (
      minLat: minLat - latPadding,
      maxLat: maxLat + latPadding,
      minLon: minLon - lonPadding,
      maxLon: maxLon + lonPadding,
    );
  }
}
