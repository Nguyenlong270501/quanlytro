import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import 'full_screen_map.dart';

class PropertyMapSection extends StatefulWidget {
  const PropertyMapSection({
    super.key,
    required this.location,
    required this.fullAddress,
  });

  final LatLng location;
  final String fullAddress;

  @override
  State<PropertyMapSection> createState() => _PropertyMapSectionState();
}

class _PropertyMapSectionState extends State<PropertyMapSection> {
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('propertyLocation'),
        position: widget.location,
        infoWindow: InfoWindow(title: widget.fullAddress),
      ),
    );
  }

  Future<void> _openGoogleMapsApp() async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.location.latitude},${widget.location.longitude}';
    final url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _openFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FullScreenMapScreen(
          location: widget.location,
          fullAddress: widget.fullAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 250.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.location,
                    zoom: 15,
                  ),
                  liteModeEnabled: true,
                  zoomControlsEnabled: false,
                  markers: _markers,
                  mapType: MapType.normal,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: GestureDetector(
                    onTap: () => _openFullScreenMap(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.open_in_full,
                        size: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10.h,
                  right: 10.w,
                  child: ElevatedButton(
                    onPressed: _openGoogleMapsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 4,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 16.sp,
                          color: Colors.blue,
                        ),
                        AppSizes.gapW4,
                        Text(
                          'Mở Google Maps',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSizes.gapH12,
        Text(
          widget.fullAddress,
          style: AppTypography.bold14(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
