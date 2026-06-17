import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanlytro/core/services/goong_service.dart';

void main() {
  late Map<String, dynamic> geocodeFixture;
  late Map<String, dynamic> autocompleteFixture;
  late Map<String, dynamic> detailFixture;

  setUpAll(() {
    geocodeFixture = jsonDecode(
      File('test/fixtures/goong/v2_geocode_hanoi.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    autocompleteFixture = jsonDecode(
      File('test/fixtures/goong/v2_autocomplete.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    detailFixture = jsonDecode(
      File('test/fixtures/goong/v2_place_detail.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  group('GoongService v2 parsing', () {
    test('reverseGeocode maps commune and province from fixture', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: geocodeFixture,
                statusCode: 200,
              ),
            );
          },
        ),
      );

      final service = GoongService(dio: dio);
      final result = await service.reverseGeocode(
        latitude: 21.0285,
        longitude: 105.8542,
      );

      expect(result, isNotNull);
      expect(result!.commune, 'Hoàn Kiếm');
      expect(result.province, 'Hà Nội');
      expect(result.formattedAddress, isNotEmpty);
    });

    test('autocomplete parses compound on predictions', () {
      final predictions =
          autocompleteFixture['predictions'] as List<dynamic>? ?? [];
      expect(predictions, isNotEmpty);

      final first = GoongPlaceSuggestion.fromMap(
        predictions.first as Map<String, dynamic>,
      );
      expect(first.placeId, isNotEmpty);
      expect(first.description, isNotEmpty);
      expect(first.province, 'Hà Nội');
    });

    test('getPlaceDetail parses geometry from fixture', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: detailFixture,
                statusCode: 200,
              ),
            );
          },
        ),
      );

      final service = GoongService(dio: dio);
      final detail = await service.getPlaceDetail('test-place-id');

      expect(detail, isNotNull);
      expect(detail!.latitude, closeTo(21.0286, 0.001));
      expect(detail.longitude, closeTo(105.8542, 0.001));
    });

    test('extractStreetLine excludes commune and province only', () {
      final first = (geocodeFixture['results'] as List).first
          as Map<String, dynamic>;
      final street = GoongService.extractStreetLine(first);

      expect(street, isNotNull);
      expect(street!.toLowerCase(), isNot(contains('hà nội')));
    });
  });
}
