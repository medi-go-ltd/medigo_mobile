import 'package:flutter/material.dart';

enum TravelMode { driving, walking, bicycling, transit }

extension TravelModeExtension on TravelMode {
  String get apiValue {
    switch (this) {
      case TravelMode.driving:
        return 'driving';
      case TravelMode.walking:
        return 'walking';
      case TravelMode.bicycling:
        return 'bicycling';
      case TravelMode.transit:
        return 'transit';
    }
  }

  String get displayName {
    switch (this) {
      case TravelMode.driving:
        return 'Driving';
      case TravelMode.walking:
        return 'Walking';
      case TravelMode.bicycling:
        return 'Cycling';
      case TravelMode.transit:
        return 'Transit';
    }
  }

  IconData get icon {
    switch (this) {
      case TravelMode.driving:
        return Icons.directions_car;
      case TravelMode.walking:
        return Icons.directions_walk;
      case TravelMode.bicycling:
        return Icons.directions_bike;
      case TravelMode.transit:
        return Icons.directions_transit;
    }
  }
}

class RouteInfo {
  final String distance; // e.g., "5.2 km" or "3.2 mi"
  final String duration; // e.g., "15 min" or "1 h 20 min"
  final TravelMode mode;
  final String? distanceText; // Raw text from API
  final String? durationText; // Raw text from API

  RouteInfo({
    required this.distance,
    required this.duration,
    required this.mode,
    this.distanceText,
    this.durationText,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json, TravelMode mode) {
    final legs = json['legs'] as List?;
    if (legs == null || legs.isEmpty) {
      return RouteInfo(distance: 'Unknown', duration: 'Unknown', mode: mode);
    }

    final leg = legs[0] as Map<String, dynamic>;
    final distance = leg['distance'] as Map<String, dynamic>?;
    final duration = leg['duration'] as Map<String, dynamic>?;

    return RouteInfo(
      distance: distance?['text'] as String? ?? 'Unknown',
      duration: duration?['text'] as String? ?? 'Unknown',
      mode: mode,
      distanceText: distance?['text'] as String?,
      durationText: duration?['text'] as String?,
    );
  }
}
