import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../utils/vietnamese_search.dart';

class WardModel {
  final String name;
  final String codename;

  WardModel({required this.name, required this.codename});

  factory WardModel.fromJson(Map<String, dynamic> json) {
    return WardModel(
      name: json['name'] ?? '',
      codename: json['codename'] ?? '',
    );
  }
}

class LocalLocationService {
  static final LocalLocationService _instance =
      LocalLocationService._internal();
  factory LocalLocationService() => _instance;
  LocalLocationService._internal();

  static final RegExp _adminPrefixPattern = RegExp(
    r'^(phường|xa|xã|thị trấn|p\.|x\.)\s+',
    caseSensitive: false,
  );

  Map<String, List<WardModel>> allData = {};
  bool _isLoaded = false;

  Future<void> loadData() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data_vietnam.json',
      );

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      jsonMap.forEach((key, value) {
        if (value is List) {
          allData[key] = value.map((e) => WardModel.fromJson(e)).toList();
        }
      });

      _isLoaded = true;
    } catch (e) {
      log('Lỗi đọc file data_vietnam.json: $e');
    }
  }

  /// Bỏ tiền tố Phường/Xã để khớp tên Goong v2 với JSON.
  static String normalizeAdminUnitLabel(String input) {
    return input.trim().replaceFirst(_adminPrefixPattern, '').trim();
  }

  List<WardModel> getHaNoiWards() {
    return allData['ha_noi'] ?? [];
  }

  List<WardModel> getHcmWards() {
    return allData['tp_hcm'] ?? [];
  }

  List<WardModel> getWardsByCityKey(String cityKey) {
    return allData[cityKey] ?? [];
  }

  String cityKeyForName(String? city) {
    final value = city?.trim();
    if (value == 'Hà Nội') return 'ha_noi';
    if (value == 'TP. HCM') return 'tp_hcm';
    return '';
  }

  WardModel? findWardByCodeOrName({
    required String? city,
    required String value,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final cityKey = cityKeyForName(city);
    final wards = cityKey.isNotEmpty
        ? getWardsByCityKey(cityKey)
        : <WardModel>[];
    final needle = normalizeAdminUnitLabel(trimmed);

    for (final ward in wards) {
      if (ward.codename == trimmed || ward.name == trimmed) {
        return ward;
      }
      if (normalizeAdminUnitLabel(ward.name) == needle) {
        return ward;
      }
    }
    return null;
  }

  String wardDisplayName({required String? city, required String value}) {
    return findWardByCodeOrName(city: city, value: value)?.name ?? value.trim();
  }

  bool isKnownWardCodename({required String? city, required String value}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final ward = findWardByCodeOrName(city: city, value: trimmed);
    return ward != null && ward.codename == trimmed;
  }

  /// Chuẩn hóa [raw] (tên Goong hoặc codename) → codename trong JSON.
  /// Exact normalized trước, contains normalized sau; không khớp → [raw].
  String resolveWardCodename({required String? city, required String raw}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    final exact = findWardByCodeOrName(city: city, value: trimmed);
    if (exact != null) return exact.codename;

    final cityKey = cityKeyForName(city);
    if (cityKey.isEmpty) return trimmed;

    final needle = normalizeAdminUnitLabel(trimmed);
    for (final ward in getWardsByCityKey(cityKey)) {
      final label = normalizeAdminUnitLabel(ward.name);
      if (vietnameseContainsNormalized(label, needle) ||
          vietnameseContainsNormalized(needle, label)) {
        return ward.codename;
      }
    }

    return trimmed;
  }
}
