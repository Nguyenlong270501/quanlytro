import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanlytro/core/services/local_location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => '.',
    );
    await LocalLocationService().loadData();
  });

  group('normalizeAdminUnitLabel', () {
    test('strips Phường prefix', () {
      expect(
        LocalLocationService.normalizeAdminUnitLabel('Phường Giảng Võ'),
        'Giảng Võ',
      );
    });

    test('strips Xã prefix', () {
      expect(
        LocalLocationService.normalizeAdminUnitLabel('Xã An Phú'),
        'An Phú',
      );
    });
  });

  group('resolveWardCodename', () {
    test('maps Goong v2 label without prefix to codename', () {
      final codename = LocalLocationService().resolveWardCodename(
        city: 'Hà Nội',
        raw: 'Giảng Võ',
      );
      expect(codename, 'phuong_giang_vo');
    });

    test('maps JSON display name with prefix to codename', () {
      final codename = LocalLocationService().resolveWardCodename(
        city: 'Hà Nội',
        raw: 'Phường Hoàn Kiếm',
      );
      expect(codename, 'phuong_hoan_kiem');
    });

    test('returns raw when no match in city', () {
      final codename = LocalLocationService().resolveWardCodename(
        city: 'Hà Nội',
        raw: 'Không Tồn Tại XYZ',
      );
      expect(codename, 'Không Tồn Tại XYZ');
    });
  });
}
