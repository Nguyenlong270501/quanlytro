import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../../../../core/config/app_evn.dart';
import '../../../../../../../core/constants/map_location_picker_constants.dart';
import '../../../../../../../core/services/goong_service.dart';
import '../../../../../../../core/services/location_service.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../../../../core/widgets/app_alerts.dart';
import '../../../../blocs/map_picker/map_picker_cubit.dart';
import '../../../../blocs/map_picker/map_picker_state.dart';
import '../../../../data/models/picked_location.dart';
part 'map_location_picker_components.dart';

class MapLocationPickerScreen extends StatelessWidget {
  const MapLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MapPickerCubit(LocationService())
            ..initLocation(initialLatitude, initialLongitude, initialAddress),
      child: const _MapLocationPickerView(),
    );
  }
}

class _MapLocationPickerView extends StatefulWidget {
  const _MapLocationPickerView();

  @override
  State<_MapLocationPickerView> createState() => _MapLocationPickerViewState();
}

class _MapLocationPickerViewState extends State<_MapLocationPickerView> {
  final GlobalKey<_MapSearchOverlayState> _searchOverlayKey =
      GlobalKey<_MapSearchOverlayState>();
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final ValueNotifier<bool> _isConfirmingNotifier = ValueNotifier(false);

  MapLibreMapController? _mapController;
  CameraPosition? _currentCameraPosition;
  Timer? _reverseGeocodeTimer;

  bool _suppressReverseGeocode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _reverseGeocodeTimer?.cancel();
    _isConfirmingNotifier.dispose();
    _searchController.dispose();
    super.dispose();
  }

  LatLng? _centerLatLng() {
    final camera = _mapController?.cameraPosition ?? _currentCameraPosition;
    return camera?.target;
  }

  Future<void> _confirmSelection() async {
    if (_isConfirmingNotifier.value) return;

    final center = _centerLatLng();
    if (center == null) {
      Alerts.of(context).showWarning('Vui lòng chọn một vị trí trên bản đồ.');
      return;
    }

    final cubit = context.read<MapPickerCubit>();
    final picked = cubit.state.pickedLocation;
    _isConfirmingNotifier.value = true;
    try {
      if (_shouldResolveAddress(picked, center)) {
        await cubit.resolveAddress(center.latitude, center.longitude);
      }

      if (!mounted) return;
      final location = cubit.state.pickedLocation;
      final validationMessage = _validateConfirmedLocation(
        location,
        isSupported:
            location != null &&
            _locationService.isPickedLocationSupported(location),
      );
      if (validationMessage != null) {
        Alerts.of(context).showWarning(validationMessage);
        return;
      }

      FocusScope.of(context).unfocus();
      context.pop(location!);
    } finally {
      if (mounted) _isConfirmingNotifier.value = false;
    }
  }

  bool _shouldResolveAddress(PickedLocation? picked, LatLng center) {
    return picked == null ||
        picked.address.trim().isEmpty ||
        (picked.city ?? '').trim().isEmpty ||
        (picked.latitude - center.latitude).abs() > 0.000001 ||
        (picked.longitude - center.longitude).abs() > 0.000001;
  }

  String? _validateConfirmedLocation(
    PickedLocation? location, {
    required bool isSupported,
  }) {
    if (location == null) {
      return 'Vui lòng chọn một vị trí trên bản đồ.';
    }

    if (!isSupported) {
      return LocationService.unsupportedRegionMessage;
    }

    return null;
  }

  Future<void> _onSuggestionTap(GoongPlaceSuggestion suggestion) async {
    FocusScope.of(context).unfocus();

    final detail = await GoongService().getPlaceDetail(suggestion.placeId);
    if (detail == null || !mounted) return;

    await _moveCameraProgrammatically(
      LatLng(detail.latitude, detail.longitude),
      zoom: 16,
    );

    if (!mounted) return;
    await context.read<MapPickerCubit>().resolveAddress(
      detail.latitude,
      detail.longitude,
      fallbackAddress: detail.formattedAddress,
    );
  }

  Future<void> _moveCameraProgrammatically(
    LatLng target, {
    double? zoom,
  }) async {
    _suppressReverseGeocode = true;
    _reverseGeocodeTimer?.cancel();
    try {
      final targetZoom =
          zoom ??
          _mapController?.cameraPosition?.zoom ??
          _currentCameraPosition?.zoom ??
          16.0;
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(target, targetZoom),
      );
    } finally {
      _suppressReverseGeocode = false;
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;

    final location = context.read<MapPickerCubit>().state.pickedLocation;
    if (location == null) return;

    unawaited(
      _moveCameraProgrammatically(
        LatLng(location.latitude, location.longitude),
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    _currentCameraPosition = position;
    if (_suppressReverseGeocode) return;

    _reverseGeocodeTimer?.cancel();
    _reverseGeocodeTimer = Timer(
      kMapPickerReverseGeocodeDebounce,
      _resolveCenterAddress,
    );
  }

  void _resolveCenterAddress() {
    if (!mounted || _suppressReverseGeocode) return;

    final center = _centerLatLng();
    if (center == null) return;

    context.read<MapPickerCubit>().resolveAddress(
      center.latitude,
      center.longitude,
    );
  }

  void _dismissSearchOverlay() {
    FocusScope.of(context).unfocus();
    _searchOverlayKey.currentState?.hideSuggestions();
  }

  void _handlePermissionError(BuildContext context, PermissionStatus status) {
    if (status == PermissionStatus.serviceDisabled) {
      Alerts.of(
        context,
      ).showWarning('Vui lòng bật GPS (Dịch vụ vị trí) trên điện thoại.');
    } else if (status == PermissionStatus.denied) {
      Alerts.of(context).showWarning('Bạn chưa cấp quyền vị trí.');
    } else if (status == PermissionStatus.deniedForever) {
      _showLocationPermissionSettingsDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickedLocation = context.read<MapPickerCubit>().state.pickedLocation;
    final initialLatLng = pickedLocation != null
        ? LatLng(pickedLocation.latitude, pickedLocation.longitude)
        : kMapPickerFallbackLocation;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Ghim vị trí khu trọ',
          style: AppTypography.bold16(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocListener<MapPickerCubit, MapPickerState>(
        listenWhen: (previous, current) =>
            previous.permissionStatus != current.permissionStatus ||
            previous.pickedLocation?.latitude !=
                current.pickedLocation?.latitude ||
            previous.pickedLocation?.longitude !=
                current.pickedLocation?.longitude ||
            (previous.isLoadingCurrentLocation &&
                !current.isLoadingCurrentLocation),
        listener: (context, state) {
          if (state.permissionStatus != null &&
              state.permissionStatus != PermissionStatus.granted) {
            _handlePermissionError(context, state.permissionStatus!);
          }

          final loc = state.pickedLocation;
          if (loc != null && _mapController != null) {
            unawaited(
              _moveCameraProgrammatically(LatLng(loc.latitude, loc.longitude)),
            );
          }
        },
        child: Stack(
          children: [
            _MapCanvas(
              initialLatLng: initialLatLng,
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              onMapTap: _dismissSearchOverlay,
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: Icon(Icons.location_pin, size: 48, color: Colors.red),
              ),
            ),
            Positioned(
              top: 8.h,
              left: 16.w,
              right: 16.w,
              child: _MapSearchOverlay(
                key: _searchOverlayKey,
                controller: _searchController,
                centerLatLng: _centerLatLng,
                onSuggestionTap: _onSuggestionTap,
              ),
            ),
            Positioned(
              right: 16.w,
              bottom: 160.h,
              child: const _MyLocationButton(),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: _MapConfirmCardConnector(
                isConfirmingListenable: _isConfirmingNotifier,
                onConfirm: _confirmSelection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
