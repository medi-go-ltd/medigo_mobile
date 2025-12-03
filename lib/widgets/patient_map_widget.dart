import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medigo_mobile/view_models/patient_home_view_model.dart';

class PatientMapWidget extends StatelessWidget {
  const PatientMapWidget({
    super.key,
    required this.viewModel,
    required this.onMapCreated,
    required this.onMapTap,
    this.bottomPadding = 100,
    this.rightPadding = 0,
  });

  final PatientHomeViewModel viewModel;
  final void Function(GoogleMapController) onMapCreated;
  final VoidCallback onMapTap;
  final double bottomPadding;
  final double rightPadding;

  @override
  Widget build(BuildContext context) {
    if (viewModel.userLocation == null) {
      return Container(
        color: const Color(0xFFF5F5DC),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          viewModel.userLocation!.latitude,
          viewModel.userLocation!.longitude,
        ),
        zoom: 12.0,
      ),
      markers: viewModel.markers,
      polylines: viewModel.polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      zoomControlsEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: false,
      padding: EdgeInsets.only(
        bottom: bottomPadding,
        top: 0,
        left: 0,
        right: rightPadding,
      ),
      onMapCreated: onMapCreated,
      onTap: (_) => onMapTap(),
    );
  }
}
