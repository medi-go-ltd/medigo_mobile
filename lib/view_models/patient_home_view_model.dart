import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/route_info.dart';
import 'package:medigo_mobile/services/directions_service.dart';
import 'package:medigo_mobile/services/location_service.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/location_utils.dart';

class PatientHomeViewModel extends ChangeNotifier {
  List<Doctor> _doctors = [];
  List<Doctor> _sortedDoctors = [];
  Doctor? _selectedDoctor;
  Location? _userLocation;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  StreamSubscription<Location>? _locationSubscription;
  BitmapDescriptor? _doctorIcon;
  RouteInfo? _routeInfo;
  TravelMode _selectedTravelMode = TravelMode.driving;
  bool _isLoading = false;

  static Location get _defaultUserLocation => Location(
    latitude: 51.43854898069703,
    longitude: 0.30173826852075025,
    address: '13 Raven Close, Castle Hill, Ebbsfleet Valley, DA10 1DD',
  );

  // Getters
  List<Doctor> get doctors => _doctors;
  List<Doctor> get sortedDoctors => _sortedDoctors;
  Doctor? get selectedDoctor => _selectedDoctor;
  Location? get userLocation => _userLocation;
  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  BitmapDescriptor? get doctorIcon => _doctorIcon;
  RouteInfo? get routeInfo => _routeInfo;
  TravelMode get selectedTravelMode => _selectedTravelMode;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await _loadDoctorIcon();
    await _initializeLocationAndLoadDoctors();
  }

  Future<void> _loadDoctorIcon() async {
    try {
      final byteData =
          await rootBundle.load('assets/images/doctor-marker.png');
      final codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: 40,
        targetHeight: 40,
      );
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(image.width.toDouble(), image.height.toDouble());

      final paint = Paint()
        ..colorFilter = const ColorFilter.mode(
          AppColors.primary,
          BlendMode.srcIn,
        );

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      if (pngBytes != null) {
        _doctorIcon = BitmapDescriptor.bytes(
          pngBytes.buffer.asUint8List(),
        );
      } else {
        _doctorIcon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueCyan,
        );
      }
    } catch (e) {
      _doctorIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueCyan,
      );
    }
    notifyListeners();
  }

  Future<void> _initializeLocationAndLoadDoctors() async {
    Location? currentLocation = _defaultUserLocation.address != null
        ? await LocationService.getLocationFromAddress(
            _defaultUserLocation.address!,
          )
        : null;

    currentLocation ??= await LocationService.getCurrentLocation();

    _userLocation = currentLocation ?? _defaultUserLocation;
    notifyListeners();

    await _loadDoctors();
    _updateMarkers();
    _startLocationTracking();
  }

  void _startLocationTracking() {
    _locationSubscription = LocationService.getPositionStream().listen(
      (newLocation) {
        _userLocation = newLocation;
        _updateDistancesAndSort();
        _updateMarkers();
        notifyListeners();
      },
      onError: (error) {
        // Handle location stream errors silently
      },
    );
  }

  void _updateDistancesAndSort() {
    if (_userLocation == null || _doctors.isEmpty) return;

    final sortedDoctors = LocationUtils.sortByDistance(
      _userLocation!,
      _doctors,
    );

    final doctorsWithUpdatedTime = sortedDoctors.map((doctor) {
      final distance = LocationUtils.distanceToDoctor(_userLocation!, doctor);
      final estimatedTime = LocationUtils.estimateTravelTime(distance);
      return Doctor(
        id: doctor.id,
        firstName: doctor.firstName,
        lastName: doctor.lastName,
        specialty: doctor.specialty,
        fee: doctor.fee,
        profileImageUrl: doctor.profileImageUrl,
        rating: doctor.rating,
        reviewCount: doctor.reviewCount,
        location: doctor.location,
        estimatedTime: estimatedTime,
      );
    }).toList();

    _sortedDoctors = doctorsWithUpdatedTime;
    notifyListeners();
  }

  Future<void> _loadDoctors() async {
    try {
      _isLoading = true;
      notifyListeners();

      final String jsonString = await rootBundle.loadString(
        'assets/mock_data/mock_doctors.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final doctors = jsonList.map((json) => Doctor.fromJson(json)).toList();

      final sortedDoctors = _userLocation != null
          ? LocationUtils.sortByDistance(_userLocation!, doctors)
          : doctors;

      final doctorsWithUpdatedTime = sortedDoctors.map((doctor) {
        if (_userLocation != null) {
          final distance = LocationUtils.distanceToDoctor(
            _userLocation!,
            doctor,
          );
          final estimatedTime = LocationUtils.estimateTravelTime(distance);
          return Doctor(
            id: doctor.id,
            firstName: doctor.firstName,
            lastName: doctor.lastName,
            specialty: doctor.specialty,
            fee: doctor.fee,
            profileImageUrl: doctor.profileImageUrl,
            rating: doctor.rating,
            reviewCount: doctor.reviewCount,
            location: doctor.location,
            estimatedTime: estimatedTime,
          );
        }
        return doctor;
      }).toList();

      _doctors = doctors;
      _sortedDoctors = doctorsWithUpdatedTime;
      _selectedDoctor = doctorsWithUpdatedTime.isNotEmpty
          ? doctorsWithUpdatedTime[0]
          : null;

      _isLoading = false;
      notifyListeners();
      _updateMarkers();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateMarkers() {
    final Set<Marker> markers = {};

    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    for (final doctor in _doctors) {
      final icon =
          _doctorIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

      markers.add(
        Marker(
          markerId: MarkerId(doctor.id),
          position: LatLng(doctor.location.latitude, doctor.location.longitude),
          icon: icon,
          infoWindow: InfoWindow(
            title: doctor.fullName,
            snippet: doctor.specialty,
          ),
          onTap: () {
            final sortedDoctor = _sortedDoctors.firstWhere(
              (d) => d.id == doctor.id,
              orElse: () => doctor,
            );
            selectDoctor(sortedDoctor);
            zoomToDoctorAndShowRoute(doctor);
          },
        ),
      );
    }

    _markers = markers;
    notifyListeners();

    if (_userLocation != null && _doctors.isNotEmpty) {
      _fitBounds();
    }
  }

  void _fitBounds() {
    if (_mapController == null || _doctors.isEmpty || _userLocation == null) {
      return;
    }

    final allLocations = [_userLocation!, ..._doctors.map((d) => d.location)];

    double minLat = allLocations.first.latitude;
    double maxLat = allLocations.first.latitude;
    double minLon = allLocations.first.longitude;
    double maxLon = allLocations.first.longitude;

    for (final location in allLocations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLon) minLon = location.longitude;
      if (location.longitude > maxLon) maxLon = location.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLon),
      northeast: LatLng(maxLat, maxLon),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    if (_doctors.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _fitBounds();
      });
    }
  }

  void selectDoctor(Doctor doctor) {
    _selectedDoctor = doctor;
    notifyListeners();
  }

  void clearSelection() {
    _selectedDoctor = null;
    _polylines.clear();
    _routeInfo = null;
    notifyListeners();
  }

  Future<void> zoomToDoctorAndShowRoute(Doctor doctor) async {
    if (_userLocation == null || _mapController == null) return;

    final userLatLng = LatLng(
      _userLocation!.latitude,
      _userLocation!.longitude,
    );
    final doctorLatLng = LatLng(
      doctor.location.latitude,
      doctor.location.longitude,
    );

    // Fetch the actual route from Google Directions API
    final routeResult = await DirectionsService.getRoute(
      origin: userLatLng,
      destination: doctorLatLng,
      mode: _selectedTravelMode,
    );

    // Use the route points if available, otherwise fall back to straight line
    final points = routeResult.points.isNotEmpty
        ? routeResult.points
        : [userLatLng, doctorLatLng];

    // Create polyline with the route
    final polyline = Polyline(
      polylineId: const PolylineId('route_to_doctor'),
      points: points,
      color: const Color(0xFF4DA8BC), // AppColors.primary
      width: 4,
      patterns: [],
    );

    _polylines = {polyline};
    _routeInfo = routeResult.routeInfo;
    notifyListeners();

    // Calculate bounds to show the entire route
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLon),
      northeast: LatLng(maxLat, maxLon),
    );

    // Zoom to show the entire route with padding
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 120));
  }

  Future<void> updateRouteForSelectedDoctor() async {
    if (_selectedDoctor != null) {
      await zoomToDoctorAndShowRoute(_selectedDoctor!);
    }
  }

  void setTravelMode(TravelMode mode) {
    _selectedTravelMode = mode;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
