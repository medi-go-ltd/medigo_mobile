import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:medigo_mobile/models/route_info.dart';

class RouteResult {
  final List<LatLng> points;
  final RouteInfo? routeInfo;

  RouteResult({required this.points, this.routeInfo});
}

class DirectionsService {
  // Use the same API key from your Google Maps setup
  // You should ideally store this in a config file
  static const String _apiKey = 'AIzaSyCqim4iIJ8L2y5FXansOxswNUFXKiK6DU4';
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  /// Fetches the route between two points using Google Directions API
  /// Returns route points and information (distance, duration, mode)
  static Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=${mode.apiValue}'
        '&units=imperial'
        '&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'OK' && data['routes'] != null) {
          final routes = data['routes'] as List;
          if (routes.isNotEmpty) {
            final route = routes[0] as Map<String, dynamic>;
            final overviewPolyline =
                route['overview_polyline'] as Map<String, dynamic>?;

            // Parse route information
            final routeInfo = RouteInfo.fromJson(route, mode);

            if (overviewPolyline != null) {
              final encodedPolyline = overviewPolyline['points'] as String;

              // Decode the polyline (returns List<List<num>> where each inner list is [lat, lng])
              final decodedPoints = decodePolyline(encodedPolyline);

              // Convert to LatLng
              final List<LatLng> points = decodedPoints
                  .map(
                    (point) => LatLng(point[0] as double, point[1] as double),
                  )
                  .toList();

              return RouteResult(points: points, routeInfo: routeInfo);
            }
          }
        }
      }

      // If API call fails, return empty result (will fall back to straight line)
      return RouteResult(points: []);
    } catch (e) {
      // If there's an error, return empty result (will fall back to straight line)
      return RouteResult(points: []);
    }
  }
}
