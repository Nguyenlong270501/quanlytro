import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../core/constants/property_constants.dart';
import '../../../../../../core/services/local_location_service.dart';
import '../../../../../../core/utils/review_helper.dart';
import '../../../../../landlord/create_property/data/models/pending_property_update.dart';
import '../../../../../landlord/create_property/data/models/property_model.dart';
import '../../../../../landlord/create_property/data/models/room_amenity.dart';
import '../../../../../landlord/create_property/data/models/room_model.dart';

enum PendingChangeKind { property, room, roomCreate }

class PendingChangeLine {
  const PendingChangeLine({
    required this.label,
    required this.newValue,
    this.fieldKey,
    this.kind = PendingChangeKind.property,
    this.imageUrls = const [],
  });

  final String label;
  final String newValue;
  final String? fieldKey;
  final PendingChangeKind kind;
  final List<String> imageUrls;

  bool get hasImages => imageUrls.isNotEmpty;
}

class PendingRoomCreateBundle {
  const PendingRoomCreateBundle({
    required this.index,
    required this.roomName,
    required this.fieldsByKey,
  });

  final int index;
  final String roomName;
  final Map<String, PendingChangeLine> fieldsByKey;

  List<PendingChangeLine> get lines =>
      fieldsByKey.values.toList(growable: false);
}

class PendingUpdateIndex {
  const PendingUpdateIndex({
    required this.propertyByKey,
    required this.roomById,
    required this.newRooms,
  });

  final Map<String, PendingChangeLine> propertyByKey;
  final Map<String, Map<String, PendingChangeLine>> roomById;
  final List<PendingRoomCreateBundle> newRooms;

  static const _addressKeys = {
    'streetAddress',
    'ward',
    'city',
    'location',
  };

  bool get isEmpty =>
      propertyByKey.isEmpty && roomById.isEmpty && newRooms.isEmpty;

  bool hasRoomChanges(String roomId) =>
      roomById[roomId]?.isNotEmpty ?? false;

  PendingChangeLine? property(String key) => propertyByKey[key];

  Map<String, PendingChangeLine>? roomFields(String roomId) => roomById[roomId];

  bool get hasAddressChange =>
      _addressKeys.any((key) => propertyByKey.containsKey(key));

  PendingChangeLine? buildPendingAddressLine(PropertyModel property) {
    if (!hasAddressChange) return null;

    final location = LocalLocationService();
    final pendingStreet =
        propertyByKey['streetAddress']?.newValue ?? property.streetAddress;
    final pendingWardRaw = propertyByKey.containsKey('ward')
        ? propertyByKey['ward']!.newValue
        : location.wardDisplayName(city: property.city, value: property.ward);
    final pendingCity =
        propertyByKey['city']?.newValue ?? property.city;

    final parts = [
      pendingStreet,
      pendingWardRaw,
      pendingCity,
    ].where((e) => e.trim().isNotEmpty);

    final joined = parts.join(', ');
    if (joined.isEmpty) return null;

    return PendingChangeLine(
      label: 'Địa chỉ',
      fieldKey: 'address',
      newValue: joined,
    );
  }

  int? pendingPriceForRoom(String roomId) {
    final line = roomById[roomId]?['price'];
    if (line == null) return null;
    final digits = line.newValue.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits);
  }

  int? pendingPriceForNewRoom(PendingRoomCreateBundle bundle) {
    final line = bundle.fieldsByKey['price'];
    if (line == null) return null;
    final digits = line.newValue.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits);
  }
}

class PendingUpdateDisplayFormatter {
  const PendingUpdateDisplayFormatter._();

  static const _propertyFieldLabels = <String, String>{
    'title': 'Tiêu đề',
    'description': 'Mô tả',
    'propertyTypes': 'Loại hình',
    'city': 'Tỉnh/Thành',
    'ward': 'Phường/Xã',
    'streetAddress': 'Địa chỉ đường',
    'location': 'Tọa độ bản đồ',
    'imageUrls': 'Ảnh tòa nhà',
    'facilities': 'Tiện ích chung',
    'rules': 'Nội quy',
    'rulesDescription': 'Ghi chú nội quy',
    'serviceFee': 'Phí dịch vụ',
  };

  static const _roomFieldLabels = <String, String>{
    'roomName': 'Tên phòng',
    'roomLocation': 'Vị trí phòng',
    'price': 'Giá thuê',
    'priceDeposit': 'Tiền cọc',
    'area': 'Diện tích',
    'maxTenants': 'Số người tối đa',
    'amenities': 'Tiện ích phòng',
    'imageUrls': 'Ảnh phòng',
    'isAvailable': 'Còn trống',
  };

  static const _ruleLabels = <String, String>{
    RuleKeys.noShared: 'Không chung chủ',
    RuleKeys.allowPet: 'Cho nuôi Pet',
    RuleKeys.freeTime: 'Giờ giấc tự do',
    RuleKeys.electricBike: 'Cho để xe điện',
  };

  static PendingUpdateIndex buildIndex({
    required PropertyModel property,
    required PendingPropertyUpdate pending,
  }) {
    final propertyByKey = <String, PendingChangeLine>{};
    final roomById = <String, Map<String, PendingChangeLine>>{};
    final newRooms = <PendingRoomCreateBundle>[];
    final location = LocalLocationService();

    for (final entry in pending.data.entries) {
      final label = _propertyFieldLabels[entry.key];
      if (label == null) continue;
      final formatted = _formatPropertyValue(
        key: entry.key,
        value: entry.value,
        property: property,
        location: location,
      );
      if (formatted == null) continue;
      propertyByKey[entry.key] = PendingChangeLine(
        label: label,
        fieldKey: entry.key,
        newValue: formatted.text,
        imageUrls: formatted.imageUrls,
      );
    }

    for (final entry in pending.roomChanges.entries) {
      final roomId = entry.key;
      final fields = <String, PendingChangeLine>{};
      for (final fieldEntry in entry.value.entries) {
        final line = _roomChangeLine(
          fieldKey: fieldEntry.key,
          value: fieldEntry.value,
          kind: PendingChangeKind.room,
        );
        if (line != null) fields[fieldEntry.key] = line;
      }
      if (fields.isNotEmpty) roomById[roomId] = fields;
    }

    for (var i = 0; i < pending.roomCreates.length; i++) {
      final roomMap = pending.roomCreates[i];
      final roomName = (roomMap['roomName'] ?? '').toString().trim();
      final fields = <String, PendingChangeLine>{};
      for (final fieldEntry in roomMap.entries) {
        if (_skipRoomCreateField(fieldEntry.key)) continue;
        final line = _roomChangeLine(
          fieldKey: fieldEntry.key,
          value: fieldEntry.value,
          kind: PendingChangeKind.roomCreate,
        );
        if (line != null) fields[fieldEntry.key] = line;
      }
      if (fields.isNotEmpty) {
        newRooms.add(
          PendingRoomCreateBundle(
            index: i,
            roomName: roomName.isNotEmpty ? roomName : 'Phòng mới ${i + 1}',
            fieldsByKey: fields,
          ),
        );
      }
    }

    return PendingUpdateIndex(
      propertyByKey: propertyByKey,
      roomById: roomById,
      newRooms: newRooms,
    );
  }

  /// Dựng [RoomModel] từ `roomCreates` để xem preview như phòng thường.
  static RoomModel roomFromPendingCreate(
    Map<String, dynamic> map, {
    required String propertyId,
    required String landlordId,
  }) {
    final normalized = Map<String, dynamic>.from(map);
    normalized.putIfAbsent('roomId', () => 'pending-new');
    normalized.putIfAbsent('propertyId', () => propertyId);
    normalized.putIfAbsent('landlordId', () => landlordId);
    normalized.putIfAbsent('createdAt', () => DateTime.now());
    normalized.putIfAbsent('updatedAt', () => DateTime.now());
    return RoomModel.fromMap(normalized);
  }

  static List<PendingChangeLine> format({
    required PropertyModel property,
    required PendingPropertyUpdate pending,
  }) {
    final index = buildIndex(property: property, pending: pending);
    final lines = <PendingChangeLine>[];

    for (final line in index.propertyByKey.values) {
      if (!PendingUpdateIndex._addressKeys.contains(line.fieldKey)) {
        lines.add(line);
      }
    }
    final address = index.buildPendingAddressLine(property);
    if (address != null) lines.add(address);

    final roomsById = {
      for (final r in property.rooms ?? const <RoomModel>[])
        if (r.roomId.isNotEmpty) r.roomId: r,
    };

    for (final entry in index.roomById.entries) {
      final roomId = entry.key;
      final roomName = roomsById[roomId]?.roomName.trim();
      final header = roomName != null && roomName.isNotEmpty
          ? 'Phòng $roomName'
          : 'Phòng $roomId';
      for (final line in entry.value.values) {
        lines.add(
          PendingChangeLine(
            label: '$header — ${line.label}',
            fieldKey: line.fieldKey,
            newValue: line.newValue,
            kind: line.kind,
            imageUrls: line.imageUrls,
          ),
        );
      }
    }

    for (final bundle in index.newRooms) {
      final header = 'Phòng mới: ${bundle.roomName}';
      for (final line in bundle.lines) {
        lines.add(
          PendingChangeLine(
            label: '$header — ${line.label}',
            fieldKey: line.fieldKey,
            newValue: line.newValue,
            kind: PendingChangeKind.roomCreate,
            imageUrls: line.imageUrls,
          ),
        );
      }
    }

    return lines;
  }

  static bool _skipRoomCreateField(String key) =>
      key == 'roomId' ||
      key == 'propertyId' ||
      key == 'landlordId' ||
      key == 'createdAt' ||
      key == 'updatedAt';

  static PendingChangeLine? _roomChangeLine({
    required String fieldKey,
    required dynamic value,
    required PendingChangeKind kind,
  }) {
    final fieldLabel = _roomFieldLabels[fieldKey] ?? fieldKey;
    final formatted = _formatRoomValue(key: fieldKey, value: value);
    if (formatted == null) return null;
    return PendingChangeLine(
      label: fieldLabel,
      fieldKey: fieldKey,
      newValue: formatted.text,
      kind: kind,
      imageUrls: formatted.imageUrls,
    );
  }

  static _FormattedValue? _formatPropertyValue({
    required String key,
    required dynamic value,
    required PropertyModel property,
    required LocalLocationService location,
  }) {
    return switch (key) {
      'imageUrls' => _formatImageUrls(value),
      'propertyTypes' || 'facilities' => _formatStringList(value),
      'rules' => _formatRules(value),
      'location' => _formatLocation(value),
      'ward' => _formatWard(value, property, location),
      'serviceFee' => _formatMoney(value, 'đ/tháng'),
      'title' || 'description' || 'city' || 'streetAddress' ||
      'rulesDescription' =>
        _formatText(value),
      _ => _formatText(value),
    };
  }

  static _FormattedValue? _formatRoomValue({
    required String key,
    required dynamic value,
  }) {
    return switch (key) {
      'imageUrls' => _formatImageUrls(value),
      'amenities' => _formatRoomAmenities(value),
      'price' || 'priceDeposit' => _formatMoney(value, 'đ/tháng'),
      'area' => _formatArea(value),
      'maxTenants' => _formatText(value),
      'roomName' || 'roomLocation' => _formatText(value),
      'isAvailable' => _formatBool(value),
      _ => _formatText(value),
    };
  }

  static _FormattedValue? _formatText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return _FormattedValue(text);
  }

  static _FormattedValue? _formatBool(dynamic value) {
    if (value is! bool) return null;
    return _FormattedValue(value ? 'Còn trống' : 'Đã thuê');
  }

  static _FormattedValue? _formatStringList(dynamic value) {
    if (value is! List || value.isEmpty) return null;
    final items = value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty);
    final joined = items.join(', ');
    if (joined.isEmpty) return null;
    return _FormattedValue(joined);
  }

  static _FormattedValue? _formatRules(dynamic value) {
    if (value is! List || value.isEmpty) return null;
    final labels = value
        .map((e) => _ruleLabels[e.toString()] ?? e.toString())
        .where((e) => e.isNotEmpty);
    final joined = labels.join(', ');
    if (joined.isEmpty) return null;
    return _FormattedValue(joined);
  }

  static _FormattedValue? _formatImageUrls(dynamic value) {
    if (value is! List || value.isEmpty) return null;
    final urls = value
        .map((e) => e.toString().trim())
        .where(_isRemoteUrl)
        .toList(growable: false);
    if (urls.isEmpty) {
      return _FormattedValue('${value.length} ảnh (đang tải)');
    }
    return _FormattedValue('${urls.length} ảnh', imageUrls: urls);
  }

  static _FormattedValue? _formatLocation(dynamic value) {
    if (value is GeoPoint) {
      return _FormattedValue(
        '${value.latitude.toStringAsFixed(6)}, ${value.longitude.toStringAsFixed(6)}',
      );
    }
    if (value is Map) {
      final lat = (value['latitude'] as num?)?.toDouble();
      final lng = (value['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        return _FormattedValue(
          '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
        );
      }
    }
    return _formatText(value);
  }

  static _FormattedValue? _formatWard(
    dynamic value,
    PropertyModel property,
    LocalLocationService location,
  ) {
    final code = value?.toString().trim() ?? '';
    if (code.isEmpty) return null;
    final name = location.wardDisplayName(city: property.city, value: code);
    return _FormattedValue(name.isNotEmpty ? name : code);
  }

  static _FormattedValue? _formatMoney(dynamic value, String suffix) {
    final amount = (value as num?)?.toInt();
    if (amount == null) return null;
    return _FormattedValue('${ReviewHelper.formatPrice(amount)} $suffix');
  }

  static _FormattedValue? _formatArea(dynamic value) {
    final area = (value as num?)?.toDouble();
    if (area == null) return null;
    final text = area == area.roundToDouble()
        ? '${area.toInt()} m²'
        : '${area.toStringAsFixed(1)} m²';
    return _FormattedValue(text);
  }

  static _FormattedValue? _formatRoomAmenities(dynamic value) {
    if (value is! List || value.isEmpty) return null;
    final labels = <String>[];
    for (final item in value) {
      if (item is Map) {
        final label = (item['label'] ?? '').toString().trim();
        if (label.isNotEmpty) {
          labels.add(label);
          continue;
        }
        try {
          labels.add(RoomAmenity.fromMap(Map<String, dynamic>.from(item)).label);
        } catch (_) {}
      } else {
        final text = item.toString().trim();
        if (text.isNotEmpty) labels.add(text);
      }
    }
    if (labels.isEmpty) return null;
    return _FormattedValue(labels.join(', '));
  }

  static bool _isRemoteUrl(String path) {
    final lower = path.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }
}

class _FormattedValue {
  const _FormattedValue(this.text, {this.imageUrls = const []});

  final String text;
  final List<String> imageUrls;
}
