import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class FullScreenMapScreen extends StatelessWidget {
  const FullScreenMapScreen({
    super.key,
    required this.location,
    required this.fullAddress,
  });

  final LatLng location;
  final String fullAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          fullAddress,
          style: AppTypography.bold16(color: AppColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: location, zoom: 16),
        markers: {
          Marker(
            markerId: const MarkerId('full_screen_property'),
            position: location,
            infoWindow: InfoWindow(title: fullAddress, snippet: fullAddress),
          ),
        },
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        compassEnabled: true,
      ),
    );
  }
}