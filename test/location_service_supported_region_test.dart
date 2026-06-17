import 'package:flutter_test/flutter_test.dart';
import 'package:quanlytro/core/services/location_service.dart';
import 'package:quanlytro/features/landlord/create_property/data/models/picked_location.dart';

void main() {
  group('LocationService.isInSupportedRegion', () {
    test('accepts central Hanoi', () {
      expect(LocationService.isInSupportedRegion(21.0285, 105.8542), isTrue);
    });

    test('accepts central Ho Chi Minh City', () {
      expect(LocationService.isInSupportedRegion(10.7769, 106.7009), isTrue);
    });

    test('rejects Da Nang', () {
      expect(LocationService.isInSupportedRegion(16.0544, 108.2022), isFalse);
    });
  });

  group('LocationService.isPickedLocationSupported', () {
    final service = LocationService();

    test('accepts Hanoi pick inside bbox with supported city name', () {
      expect(
        service.isPickedLocationSupported(
          const PickedLocation(
            latitude: 21.0285,
            longitude: 105.8542,
            address: 'Hà Nội',
            city: 'Hà Nội',
          ),
        ),
        isTrue,
      );
    });

    test('rejects pick outside supported bboxes', () {
      expect(
        service.isPickedLocationSupported(
          const PickedLocation(
            latitude: 16.0544,
            longitude: 108.2022,
            address: 'Đà Nẵng',
            city: 'Đà Nẵng',
          ),
        ),
        isFalse,
      );
    });

    test('rejects in-bbox coordinates with unsupported province name', () {
      expect(
        service.isPickedLocationSupported(
          const PickedLocation(
            latitude: 21.0285,
            longitude: 105.8542,
            address: 'Test',
            city: 'Đà Nẵng',
          ),
        ),
        isFalse,
      );
    });
  });
}
