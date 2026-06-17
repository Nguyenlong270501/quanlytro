import 'package:flutter_test/flutter_test.dart';
import 'package:quanlytro/features/landlord/create_property/blocs/step1/step1_state.dart';
import 'package:quanlytro/features/landlord/create_property/blocs/step2/step2_state.dart';
import 'package:quanlytro/features/landlord/create_property/blocs/step3/step3_state.dart';
import 'package:quanlytro/features/landlord/create_property/data/models/property_model.dart';
import 'package:quanlytro/features/landlord/create_property/domain/property_edit_diff_service.dart';

PropertyModel _baseline({
  int roomPrice = 1_000_000,
  int minimumRentalDuration = 3,
  String title = 'Nhà A',
}) {
  return PropertyModel(
    propertyId: 'p1',
    landlordId: 'u1',
    quotaId: 'q1',
    title: title,
    description: 'Mô tả',
    propertyTypes: const ['phong_tro'],
    minimumRentalDuration: minimumRentalDuration,
    city: 'Hà Nội',
    ward: 'ba_dinh',
    streetAddress: '12 Lê Lợi',
    electricityPrice: 3500,
    waterPrice: 20000,
    wifiPrice: 0,
    serviceFee: 0,
    parkingFee: 0,
    facilities: const [],
    rules: const [],
    imageUrls: const ['https://example.com/a.jpg'],
    rooms: [
      RoomModel(
        roomId: 'r1',
        propertyId: 'p1',
        roomName: 'P101',
        roomLocation: 'Tầng 1',
        price: roomPrice,
        priceDeposit: 0,
        area: 20,
        maxTenants: 2,
        amenities: const [],
        imageUrls: const [],
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    ],
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    status: PropertyStatus.approved,
  );
}

Step1State _step1From(PropertyModel p, {String? electricity}) {
  return Step1State(
    name: p.title,
    propertyTypes: p.propertyTypes,
    description: p.description,
    minimumRentalDuration: p.minimumRentalDuration?.toString() ?? '',
    city: p.city,
    ward: p.ward,
    street: p.streetAddress,
    electricityPrice: electricity ?? p.electricityPrice.toString(),
    waterPrice: p.waterPrice.toString(),
    latitude: p.location?.latitude,
    longitude: p.location?.longitude,
  );
}

Step2State _step2From(PropertyModel p) {
  return Step2State(
    imageUrls: List<String>.from(p.imageUrls ?? const []),
    activeAmenities: Set<String>.from(p.facilities ?? const []),
    activeRules: Set<String>.from(p.rules ?? const []),
    ruleNotes: p.rulesDescription ?? '',
    curfew: p.curfewTime ?? '',
  );
}

Step3State _step3From(PropertyModel p, {List<RoomModel>? rooms}) {
  return Step3State(rooms: rooms ?? List<RoomModel>.from(p.rooms ?? const []));
}

void main() {
  final service = PropertyEditDiffService();

  test('auto-pass: chỉ đổi điện/nước', () {
    final base = _baseline();
    final diff = service.compare(
      baseline: base,
      step1: _step1From(base, electricity: '4000'),
      step2: _step2From(base),
      step3: _step3From(base),
      requestedBy: 'u1',
      wardCodeResolver: (s) => s.ward,
    );

    expect(diff.hasMustReview, isFalse);
    expect(diff.autoPropertyPatch['electricityPrice'], 4000);
  });

  test('auto-pass: đổi title', () {
    final base = _baseline();
    final diff = service.compare(
      baseline: base,
      step1: _step1From(base).copyWith(name: 'Nhà B'),
      step2: _step2From(base),
      step3: _step3From(base),
      requestedBy: 'u1',
      wardCodeResolver: (s) => s.ward,
    );

    expect(diff.hasMustReview, isFalse);
    expect(diff.autoPropertyPatch['title'], 'Nhà B');
  });

  test('auto-pass: đổi roomName', () {
    final base = _baseline();
    final rooms = [
      (base.rooms!.first).copyWith(roomName: 'P102'),
    ];
    final diff = service.compare(
      baseline: base,
      step1: _step1From(base),
      step2: _step2From(base),
      step3: _step3From(base, rooms: rooms),
      requestedBy: 'u1',
      wardCodeResolver: (s) => s.ward,
    );

    expect(diff.hasMustReview, isFalse);
    expect(diff.autoRoomChanges['r1']?['roomName'], 'P102');
  });

  test('giá phòng +15% auto-pass', () {
    final base = _baseline(roomPrice: 1_000_000);
    final rooms = [
      (base.rooms!.first).copyWith(price: 1_150_000),
    ];
    final diff = service.compare(
      baseline: base,
      step1: _step1From(base),
      step2: _step2From(base),
      step3: _step3From(base, rooms: rooms),
      requestedBy: 'u1',
      wardCodeResolver: (s) => s.ward,
    );

    expect(diff.hasMustReview, isFalse);
    expect(diff.autoRoomChanges['r1']?['price'], 1_150_000);
  });

  test('giá phòng +50% must-review', () {
    final base = _baseline(roomPrice: 1_000_000);
    final rooms = [
      (base.rooms!.first).copyWith(price: 1_500_000),
    ];
    final diff = service.compare(
      baseline: base,
      step1: _step1From(base),
      step2: _step2From(base),
      step3: _step3From(base, rooms: rooms),
      requestedBy: 'u1',
      wardCodeResolver: (s) => s.ward,
    );

    expect(diff.hasMustReview, isTrue);
    expect(diff.pendingUpdate?.roomChanges['r1']?['price'], 1_500_000);
  });

  test('auto-pass: xóa phòng', () {
    final base = _baseline();
    final diff = service.compare(
      baseline: base,
      step1: _step1From(base),
      step2: _step2From(base),
      step3: const Step3State(rooms: []),
      requestedBy: 'u1',
      wardCodeResolver: (s) => s.ward,
    );

    expect(diff.hasMustReview, isFalse);
    expect(diff.autoRoomDeletes, ['r1']);
    expect(diff.pendingUpdate, isNull);
  });

  test('must-review: thêm phòng mới', () {
    final base = _baseline();
    final existing = base.rooms!.first;
    final newRoom = existing.copyWith(
      roomId: '',
      roomName: 'P201',
    );
    final diff = service.compare(
      baseline: base,
      step1: _step1From(base),
      step2: _step2From(base),
      step3: Step3State(rooms: [existing, newRoom]),
      requestedBy: 'u1',
      wardCodeResolver: (s) => s.ward,
    );

    expect(diff.hasMustReview, isTrue);
    expect(diff.pendingUpdate?.roomCreates, isNotEmpty);
    expect(diff.autoRoomDeletes, isEmpty);
  });

  test('deep equality: đổi thứ tự propertyTypes không diff', () {
    final base = _baseline().copyWith(
      propertyTypes: const ['a', 'b'],
    );
    final diff = service.compare(
      baseline: base,
      step1: _step1From(base).copyWith(propertyTypes: const ['b', 'a']),
      step2: _step2From(base),
      step3: _step3From(base),
      requestedBy: 'u1',
      wardCodeResolver: (s) => s.ward,
    );

    expect(diff.isEmpty, isTrue);
  });

  test('auto-pass: update minimum rental duration', () {
    final base = _baseline(minimumRentalDuration: 3);
    final editedStep1 = _step1From(
      base,
    ).copyWith(minimumRentalDuration: '6');

    final diff = service.compare(
      baseline: base,
      step1: editedStep1,
      step2: _step2From(base),
      step3: _step3From(base),
      requestedBy: 'u1',
      wardCodeResolver: (s) => s.ward,
    );

    expect(diff.hasMustReview, isFalse);
    expect(diff.autoPropertyPatch['minimumRentalDuration'], 6);
  });
}
