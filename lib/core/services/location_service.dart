import 'package:geolocator/geolocator.dart';

import '../../features/landlord/create_property/data/models/picked_location.dart';
import '../constants/property_constants.dart';
import 'goong_service.dart';

enum PermissionStatus { granted, denied, deniedForever, serviceDisabled }

class LocationService {
  LocationService({GoongService? goongService})
      : _goongService = goongService ?? GoongService();

  static const String unsupportedRegionMessage =
      'Hiện chỉ hỗ trợ đăng tin tại Hà Nội và TP. HCM. Vui lòng chọn vị trí trong hai thành phố này.';

  /// Bbox rộng (đồ án): mép ngoại thành vẫn được, tránh chặn nhầm.
  static const double _haNoiLatMin = 20.85;
  static const double _haNoiLatMax = 21.25;
  static const double _haNoiLngMin = 105.65;
  static const double _haNoiLngMax = 106.05;

  static const double _hcmLatMin = 10.55;
  static const double _hcmLatMax = 11.05;
  static const double _hcmLngMin =  106.35;
  static const double _hcmLngMax = 107.05;

  final GoongService _goongService;

  static bool isInSupportedRegion(double lat, double lng) {
    final inHaNoi = lat >= _haNoiLatMin &&
        lat <= _haNoiLatMax &&
        lng >= _haNoiLngMin &&
        lng <= _haNoiLngMax;
    final inHcm = lat >= _hcmLatMin &&
        lat <= _hcmLatMax &&
        lng >= _hcmLngMin &&
        lng <= _hcmLngMax;
    return inHaNoi || inHcm;
  }

  Future<PermissionStatus> checkAndRequestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return PermissionStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) return PermissionStatus.denied;
    if (permission == LocationPermission.deniedForever) {
      return PermissionStatus.deniedForever;
    }

    return PermissionStatus.granted;
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<PickedLocation> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    final coordFallback =
        '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

    try {
      final geocode = await _goongService.reverseGeocode(
        latitude: lat,
        longitude: lng,
      );

      if (geocode == null) {
        return PickedLocation(
          latitude: lat,
          longitude: lng,
          address: coordFallback,
        );
      }

      final pickedCity = _firstNotEmpty([geocode.province]);
      final pickedWard = _firstNotEmpty([geocode.commune]);
      final pickedStreet = _firstNotEmpty([
        geocode.streetLine,
      ]);

      return PickedLocation(
        latitude: lat,
        longitude: lng,
        address: geocode.formattedAddress,
        city: pickedCity,
        ward: pickedWard,
        street: pickedStreet,
      );
    } catch (_) {
      return PickedLocation(
        latitude: lat,
        longitude: lng,
        address: coordFallback,
      );
    }
  }

  String _firstNotEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  String normalizeLocationName(String? value) => (value ?? '').trim();

  String? matchSupportedCity(String city) {
    if (city.isEmpty) return null;
    final lower = city.toLowerCase();

    if (lower.contains('ha noi') || lower.contains('hà nội')) {
      return 'Hà Nội';
    }
    if (lower.contains('ho chi minh') ||
        lower.contains('hồ chí minh') ||
        lower.contains('tp. hcm') ||
        lower.contains('tp hcm')) {
      return 'TP. HCM';
    }

    for (final option in PropertyConstants.cities) {
      if (option.toLowerCase() == lower) return option;
    }
    return null;
  }

  bool isSupportedCityName(String? city) =>
      matchSupportedCity(normalizeLocationName(city)) != null;

  /// Ghim map: phải nằm trong bbox HN/HCM và Goong trả tỉnh/TP được hỗ trợ.
  bool isPickedLocationSupported(PickedLocation location) {
    if (!isInSupportedRegion(location.latitude, location.longitude)) {
      return false;
    }
    return isSupportedCityName(location.city);
  }
}
