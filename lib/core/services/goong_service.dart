import 'dart:developer';

import 'package:dio/dio.dart';

import '../config/app_evn.dart';

class GoongPlaceSuggestion {
  const GoongPlaceSuggestion({
    required this.placeId,
    required this.description,
    this.commune,
    this.province,
  });

  final String placeId;
  final String description;
  final String? commune;
  final String? province;

  factory GoongPlaceSuggestion.fromMap(Map<String, dynamic> map) {
    final compound = map['compound'] as Map<String, dynamic>?;
    return GoongPlaceSuggestion(
      placeId: (map['place_id'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      commune: compound?['commune']?.toString(),
      province: compound?['province']?.toString(),
    );
  }
}

class GoongPlaceDetail {
  const GoongPlaceDetail({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;
}

class GoongGeocodeResult {
  const GoongGeocodeResult({
    required this.formattedAddress,
    this.streetLine,
    this.province,
    this.commune,
  });

  final String formattedAddress;
  final String? streetLine;
  final String? province;
  final String? commune;
}

class GoongService {
  GoongService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _baseUrl = 'https://rsapi.goong.io';

  Future<List<GoongPlaceSuggestion>> autocomplete(
    String input, {
    double? locationLat,
    double? locationLng,
    int limit = 5,
  }) async {
    final keyword = input.trim();
    if (keyword.isEmpty) return const [];

    try {
      final query = <String, dynamic>{
        'api_key': AppEnv.goongApiKey,
        'input': keyword,
        'limit': limit,
      };
      if (locationLat != null && locationLng != null) {
        query['location'] = '$locationLat,$locationLng';
      }

      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/v2/place/autocomplete',
        queryParameters: query,
      );

      final data = response.data ?? <String, dynamic>{};
      final predictions = data['predictions'] as List<dynamic>? ?? const [];

      return predictions
          .whereType<Map<String, dynamic>>()
          .map(GoongPlaceSuggestion.fromMap)
          .where((item) => item.placeId.isNotEmpty)
          .toList();
    } catch (e, stackTrace) {
      log('Goong autocomplete failed', error: e, stackTrace: stackTrace);
      return const [];
    }
  }

  Future<GoongPlaceDetail?> getPlaceDetail(String placeId) async {
    final id = placeId.trim();
    if (id.isEmpty) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/v2/place/detail',
        queryParameters: {
          'api_key': AppEnv.goongApiKey,
          'place_id': id,
        },
      );

      final data = response.data ?? <String, dynamic>{};
      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) return null;

      final geometry = result['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      if (location == null) return null;

      final lat = (location['lat'] as num?)?.toDouble();
      final lng = (location['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;

      return GoongPlaceDetail(
        latitude: lat,
        longitude: lng,
        formattedAddress: (result['formatted_address'] ?? '').toString(),
      );
    } catch (e, stackTrace) {
      log('Goong place detail failed', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<GoongGeocodeResult?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/v2/geocode',
        queryParameters: {
          'api_key': AppEnv.goongApiKey,
          'latlng': '$latitude,$longitude',
        },
      );

      final data = response.data ?? <String, dynamic>{};
      final results = data['results'] as List<dynamic>? ?? const [];
      if (results.isEmpty) return null;

      final first = results.first;
      if (first is! Map<String, dynamic>) return null;

      final formatted =
          (first['formatted_address'] ?? first['address'] ?? '').toString().trim();
      if (formatted.isEmpty) return null;

      final compound = first['compound'] as Map<String, dynamic>?;
      return GoongGeocodeResult(
        formattedAddress: formatted,
        streetLine: extractStreetLine(first),
        province: compound?['province']?.toString(),
        commune: compound?['commune']?.toString(),
      );
    } catch (e, stackTrace) {
      log('Goong reverse geocode failed', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Lấy phần số nhà/đường/POI — bỏ tỉnh và phường đã có ở field riêng.
  static String? extractStreetLine(Map<String, dynamic> result) {
    final compound = result['compound'] as Map<String, dynamic>?;
    final adminNames = <String>{
      compound?['province']?.toString().trim() ?? '',
      compound?['commune']?.toString().trim() ?? '',
    }..removeWhere((name) => name.isEmpty);

    final components = result['address_components'] as List<dynamic>? ?? const [];
    final streetParts = components
        .whereType<Map<String, dynamic>>()
        .map((c) => (c['long_name'] ?? '').toString().trim())
        .where((name) => name.isNotEmpty && !_isAdminUnit(name, adminNames))
        .toList();

    if (streetParts.isNotEmpty) {
      return streetParts.join(', ');
    }

    final name = (result['name'] ?? '').toString().trim();
    if (name.isNotEmpty && !_isAdminUnit(name, adminNames)) {
      return name;
    }

    final formatted =
        (result['formatted_address'] ?? result['address'] ?? '').toString().trim();
    if (formatted.isEmpty) return null;

    return _stripAdminSuffixes(formatted, adminNames);
  }

  static bool _isAdminUnit(String value, Set<String> adminNames) {
    final normalized = value.trim().toLowerCase();
    for (final admin in adminNames) {
      if (normalized == admin.trim().toLowerCase()) return true;
    }
    return false;
  }

  static String? _stripAdminSuffixes(
    String formatted,
    Set<String> adminNames,
  ) {
    final parts = formatted
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    while (parts.isNotEmpty && _isAdminUnit(parts.last, adminNames)) {
      parts.removeLast();
    }

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }
}
