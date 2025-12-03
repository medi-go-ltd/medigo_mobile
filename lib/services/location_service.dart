import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:medigo_mobile/models/doctor.dart';

class LocationService {
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get location from address (geocoding)
  /// Returns null if address cannot be geocoded
  static Future<Location?> getLocationFromAddress(String address) async {
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(
        address,
      );
      if (locations.isEmpty) return null;

      final geocodingLocation = locations.first;
      return Location(
        latitude: geocodingLocation.latitude,
        longitude: geocodingLocation.longitude,
        address: address,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get address from coordinates (reverse geocoding)
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final placemark = placemarks.first;
      // Build address string from placemark components
      final addressParts = <String>[];
      if (placemark.street != null && placemark.street!.isNotEmpty) {
        addressParts.add(placemark.street!);
      }
      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        addressParts.add(placemark.locality!);
      }
      if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
        addressParts.add(placemark.postalCode!);
      }
      if (placemark.country != null && placemark.country!.isNotEmpty) {
        addressParts.add(placemark.country!);
      }

      return addressParts.isEmpty ? null : addressParts.join(', ');
    } catch (e) {
      return null;
    }
  }

  /// Get current position
  /// If address is provided, geocode it to get coordinates
  /// If address is null, use GPS coordinates and reverse geocode to get address
  /// Returns null if permission denied or location unavailable
  static Future<Location?> getCurrentLocation({String? address}) async {
    try {
      // If address is provided, geocode it
      if (address != null && address.isNotEmpty) {
        return await getLocationFromAddress(address);
      }

      // Otherwise, use GPS coordinates
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Reverse geocode to get address from coordinates
      final addressFromCoords = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        address: addressFromCoords,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Location?> getLastKnownLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      // Reverse geocode to get address from coordinates
      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      return null;
    }
  }

  static Stream<Location> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).asyncMap((position) async {
      // Reverse geocode to get address from coordinates
      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    });
  }

  static double calculateDistance(Location location1, Location location2) {
    return Geolocator.distanceBetween(
          location1.latitude,
          location1.longitude,
          location2.latitude,
          location2.longitude,
        ) /
        1000;
  }
}
