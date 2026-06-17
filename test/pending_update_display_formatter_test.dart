import 'package:flutter_test/flutter_test.dart';
import 'package:quanlytro/features/admin/approvals/presentation/property_request/widgets/pending_update_display_formatter.dart';
import 'package:quanlytro/features/landlord/create_property/data/models/pending_property_update.dart';
import 'package:quanlytro/features/landlord/create_property/data/models/property_model.dart';
import 'package:quanlytro/features/landlord/create_property/data/models/room_model.dart';

void main() {
  test('formats propertyTypes with Vietnamese labels', () {
    final property = PropertyModel(
      propertyId: 'p1',
      landlordId: 'u1',
      quotaId: 'q1',
      title: 'Nhà cũ',
      description: 'Mô tả',
      propertyTypes: const ['Chung cư mini'],
      city: 'Hà Nội',
      ward: 'ba_dinh',
      streetAddress: '12 Lê Lợi',
      electricityPrice: 3500,
      waterPrice: 20000,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
      status: PropertyStatus.approved,
      pendingUpdate: PendingPropertyUpdate(
        data: {
          'propertyTypes': ['Phòng trọ bình dân', 'Chung cư mini'],
        },
      ),
    );

    final lines = PendingUpdateDisplayFormatter.format(
      property: property,
      pending: property.pendingUpdate!,
    );

    expect(lines.length, 1);
    expect(lines.first.label, 'Loại hình');
    expect(
      lines.first.newValue,
      'Phòng trọ bình dân, Chung cư mini',
    );
  });

  test('formats isAvailable with Vietnamese label and values', () {
    final property = PropertyModel(
      propertyId: 'p1',
      landlordId: 'u1',
      quotaId: 'q1',
      title: 'Nhà',
      description: 'Mô tả',
      propertyTypes: const ['Chung cư mini'],
      city: 'Hà Nội',
      ward: 'ba_dinh',
      streetAddress: '12 Lê Lợi',
      electricityPrice: 3500,
      waterPrice: 20000,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
      status: PropertyStatus.approved,
      rooms: const [],
      pendingUpdate: PendingPropertyUpdate(
        roomChanges: {
          'r1': {'isAvailable': false},
        },
      ),
    );

    final lines = PendingUpdateDisplayFormatter.format(
      property: property,
      pending: property.pendingUpdate!,
    );

    expect(lines.length, 1);
    expect(lines.first.label, contains('Còn trống'));
    expect(lines.first.newValue, 'Đã thuê');
  });

  test('buildIndex groups room changes by roomId', () {
    final property = PropertyModel(
      propertyId: 'p1',
      landlordId: 'u1',
      quotaId: 'q1',
      title: 'Nhà',
      description: 'Mô tả',
      propertyTypes: const ['Chung cư mini'],
      city: 'Hà Nội',
      ward: 'ba_dinh',
      streetAddress: '12 Lê Lợi',
      electricityPrice: 3500,
      waterPrice: 20000,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
      status: PropertyStatus.approved,
      rooms: [
        RoomModel(
          roomId: 'r1',
          propertyId: 'p1',
          roomName: '101',
          roomLocation: 'Tầng 1',
          price: 2000000,
          priceDeposit: 0,
          area: 20,
          maxTenants: 2,
          amenities: const [],
          imageUrls: const [],
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ],
      pendingUpdate: PendingPropertyUpdate(
        roomChanges: {
          'r1': {'price': 2500000},
        },
        roomCreates: [
          {'roomName': '401', 'price': 3000000},
        ],
      ),
    );

    final index = PendingUpdateDisplayFormatter.buildIndex(
      property: property,
      pending: property.pendingUpdate!,
    );

    expect(index.hasRoomChanges('r1'), isTrue);
    expect(index.roomFields('r1')?['price']?.newValue, contains('2.500.000'));
    expect(index.newRooms.length, 1);
    expect(index.newRooms.first.roomName, '401');
  });
}
