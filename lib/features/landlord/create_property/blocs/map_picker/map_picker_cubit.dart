import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/map_location_picker_constants.dart';
import '../../../../../core/services/location_service.dart';
import '../../data/models/picked_location.dart';
import 'map_picker_state.dart';

class MapPickerCubit extends Cubit<MapPickerState> {
  MapPickerCubit(this._service) : super(const MapPickerState());

  final LocationService _service;

  Future<void> initLocation(double? lat, double? lng, String? address) async {
    if (lat != null && lng != null) {
      emit(
        state.copyWith(
          pickedLocation: PickedLocation(
            latitude: lat,
            longitude: lng,
            address: address ?? '',
          ),
        ),
      );

      if ((address ?? '').isEmpty) {
        await resolveAddress(lat, lng);
      }
    } else {
      emit(
        state.copyWith(
          pickedLocation: PickedLocation(
            latitude: kMapPickerFallbackLocation.latitude,
            longitude: kMapPickerFallbackLocation.longitude,
            address: '',
          ),
        ),
      );
      unawaited(_moveToInitialCurrentLocation());
    }
  }

  Future<void> _moveToInitialCurrentLocation() async {
    emit(state.copyWith(isLoadingCurrentLocation: true));

    final permission = await _service.checkAndRequestPermission();
    if (permission != PermissionStatus.granted) {
      emit(
        state.copyWith(
          isLoadingCurrentLocation: false,
          permissionStatus: permission,
        ),
      );
      return;
    }

    final lastKnown = await _service.getLastKnownPosition();
    if (lastKnown != null) {
      syncPickCoordinates(lastKnown.latitude, lastKnown.longitude);
    }

    final position = await _service.getCurrentPosition(
      accuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 8),
    );
    final resolvedPosition = position ?? lastKnown;
    if (resolvedPosition != null) {
      await resolveAddress(
        resolvedPosition.latitude,
        resolvedPosition.longitude,
      );
    }

    emit(state.copyWith(isLoadingCurrentLocation: false));
  }

  Future<void> moveToCurrentLocation() async {
    emit(state.copyWith(isLoadingCurrentLocation: true));

    final permission = await _service.checkAndRequestPermission();
    if (permission != PermissionStatus.granted) {
      emit(
        state.copyWith(
          isLoadingCurrentLocation: false,
          permissionStatus: permission,
        ),
      );
      return;
    }

    final position = await _service.getCurrentPosition();
    if (position != null) {
      await resolveAddress(position.latitude, position.longitude);
    }

    emit(state.copyWith(isLoadingCurrentLocation: false));
  }

  void syncPickCoordinates(double lat, double lng) {
    final previous = state.pickedLocation;
    emit(
      state.copyWith(
        pickedLocation: PickedLocation(
          latitude: lat,
          longitude: lng,
          address: previous?.address ?? '',
          city: previous?.city,
          ward: previous?.ward,
          street: previous?.street,
        ),
      ),
    );
  }

  Future<void> resolveAddress(
    double lat,
    double lng, {
    String? fallbackAddress,
  }) async {
    emit(state.copyWith(isResolvingAddress: true));

    final trimmedFallback = fallbackAddress?.trim();
    if (trimmedFallback != null && trimmedFallback.isNotEmpty) {
      emit(
        state.copyWith(
          pickedLocation: PickedLocation(
            latitude: lat,
            longitude: lng,
            address: trimmedFallback,
          ),
        ),
      );
    }

    final enriched = await _service.getAddressFromCoordinates(lat, lng);
    final displayAddress =
        (trimmedFallback != null && trimmedFallback.isNotEmpty)
        ? trimmedFallback
        : enriched.address;

    emit(
      state.copyWith(
        isResolvingAddress: false,
        pickedLocation: enriched.copyWith(address: displayAddress),
      ),
    );
  }
}
