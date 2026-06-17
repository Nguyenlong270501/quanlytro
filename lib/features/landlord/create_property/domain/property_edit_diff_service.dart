import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import '../blocs/step1/step1_state.dart';
import '../blocs/step2/step2_state.dart';
import '../blocs/step3/step3_state.dart';
import '../data/models/pending_property_update.dart';
import '../data/models/property_model.dart';
import '../data/models/room_amenity.dart';
import 'property_edit_diff.dart';

class PropertyEditDiffService {
  PropertyEditDiffService({DeepCollectionEquality? equality})
    : _equality = equality ?? const DeepCollectionEquality();

  final DeepCollectionEquality _equality;

  static const _autoPropertyFields = {
    'electricityPrice',
    'waterPrice',
    'wifiPrice',
    'parkingFee',
    'serviceFee',
    'title',
    'description',
    'serviceDescription',
    'curfewTime',
    'rulesDescription',
    'minimumRentalDuration',
  };

  static const _mustReviewPropertyFields = {
    'city',
    'ward',
    'streetAddress',
    'location',
    'imageUrls',
    'propertyTypes',
    'facilities',
    'rules',
  };

  static const _autoRoomFields = {'roomName', 'roomLocation', 'isAvailable'};

  static const _mustReviewRoomFields = {
    'price',
    'priceDeposit',
    'area',
    'maxTenants',
    'imageUrls',
    'amenities',
  };

  PropertyEditDiff compare({
    required PropertyModel baseline,
    required Step1State step1,
    required Step2State step2,
    required Step3State step3,
    required String requestedBy,
    required String Function(Step1State step1) wardCodeResolver,
  }) {
    final edited = _buildEditedProperty(
      baseline: baseline,
      step1: step1,
      step2: step2,
      step3: step3,
      wardCodeResolver: wardCodeResolver,
    );

    final autoPropertyPatch = <String, dynamic>{};
    final pendingData = <String, dynamic>{};
    final changedFields = <String>[];

    for (final field in _autoPropertyFields) {
      final patch = _diffPropertyField(baseline, edited, field);
      if (patch != null) {
        autoPropertyPatch[field] = patch;
      }
    }

    for (final field in _mustReviewPropertyFields) {
      final patch = _diffPropertyField(baseline, edited, field);
      if (patch != null) {
        pendingData[field] = patch;
        changedFields.add(field);
      }
    }

    final baselineRooms = {
      for (final r in baseline.rooms ?? const <RoomModel>[])
        if (r.roomId.isNotEmpty) r.roomId: r,
    };
    final editedRooms = edited.rooms ?? const <RoomModel>[];

    final autoRoomChanges = <String, Map<String, dynamic>>{};
    final pendingRoomChanges = <String, Map<String, dynamic>>{};
    final autoRoomDeletes = <String>[];
    final roomCreates = <Map<String, dynamic>>[];

    final editedIds = <String>{};
    for (final room in editedRooms) {
      final roomId = room.roomId.trim();
      if (roomId.isNotEmpty) {
        editedIds.add(roomId);
      }
    }

    for (final id in baselineRooms.keys) {
      if (!editedIds.contains(id)) {
        autoRoomDeletes.add(id);
      }
    }

    var needsImageUpload = _hasLocalImagePaths(pendingData);

    for (final room in editedRooms) {
      var roomId = room.roomId.trim();
      final isNew = roomId.isEmpty || !baselineRooms.containsKey(roomId);

      if (isNew) {
        final createMap = room.toMap()..remove('roomId');
        roomCreates.add(createMap);
        changedFields.add('roomCreates');
        needsImageUpload =
            needsImageUpload ||
            _hasLocalImagePaths({'imageUrls': room.imageUrls});
        continue;
      }

      final baseRoom = baselineRooms[roomId]!;
      final roomAuto = <String, dynamic>{};
      final roomPending = <String, dynamic>{};

      for (final field in _autoRoomFields) {
        final patch = _diffRoomField(baseRoom, room, field);
        if (patch == null) continue;
        roomAuto[field] = field == 'isAvailable' ? patch == true : patch;
      }

      for (final field in _mustReviewRoomFields) {
        final patch = _diffRoomField(baseRoom, room, field);
        if (patch == null) continue;

        if (field == 'price' &&
            !_isPriceMustReview(baseRoom.price, room.price)) {
          roomAuto['price'] = room.price;
          continue;
        }

        roomPending[field] = patch;
        changedFields.add('room:$roomId:$field');
      }

      if (roomAuto.isNotEmpty) {
        autoRoomChanges[roomId] = roomAuto;
      }
      if (roomPending.isNotEmpty) {
        pendingRoomChanges[roomId] = roomPending;
        needsImageUpload = needsImageUpload || _hasLocalImagePaths(roomPending);
      }
    }

    PendingPropertyUpdate? pendingUpdate;
    if (pendingData.isNotEmpty ||
        pendingRoomChanges.isNotEmpty ||
        roomCreates.isNotEmpty) {
      pendingUpdate = PendingPropertyUpdate(
        changedFields: changedFields,
        data: pendingData,
        roomChanges: pendingRoomChanges,
        roomCreates: roomCreates,
        requestedBy: requestedBy,
        requestedAt: DateTime.now(),
      );
    }

    return PropertyEditDiff(
      autoPropertyPatch: autoPropertyPatch,
      autoRoomChanges: autoRoomChanges,
      autoRoomDeletes: autoRoomDeletes,
      pendingUpdate: pendingUpdate,
      needsImageUpload: needsImageUpload,
    );
  }

  PropertyModel _buildEditedProperty({
    required PropertyModel baseline,
    required Step1State step1,
    required Step2State step2,
    required Step3State step3,
    required String Function(Step1State step1) wardCodeResolver,
  }) {
    final rooms = step3.rooms
        .map(
          (r) => r.copyWith(
            propertyId: baseline.propertyId,
          ),
        )
        .toList();

    return baseline.copyWith(
      title: step1.name,
      description: step1.description,
      propertyTypes: step1.propertyTypes,
      minimumRentalDuration: int.tryParse(step1.minimumRentalDuration) ?? 0,
      city: step1.city ?? '',
      ward: wardCodeResolver(step1),
      streetAddress: step1.street,
      location: step1.latitude != null && step1.longitude != null
          ? GeoPoint(step1.latitude!, step1.longitude!)
          : null,
      electricityPrice: int.tryParse(step1.electricityPrice) ?? 0,
      waterPrice: int.tryParse(step1.waterPrice) ?? 0,
      wifiPrice: int.tryParse(step1.wifiPrice ?? '') ?? 0,
      parkingFee: int.tryParse(step1.parkingFee ?? '') ?? 0,
      serviceFee: int.tryParse(step1.serviceFee ?? '') ?? 0,
      serviceDescription: step1.serviceDescription,
      facilities: step2.activeAmenities.toList(),
      rules: step2.activeRules.toList(),
      rulesDescription: step2.ruleNotes,
      curfewTime: step2.curfew,
      imageUrls: step2.imageUrls,
      rooms: rooms,
      updatedAt: DateTime.now(),
    );
  }

  dynamic _diffPropertyField(
    PropertyModel baseline,
    PropertyModel edited,
    String field,
  ) {
    return switch (field) {
      'title' => _diffScalar(baseline.title, edited.title),
      'description' => _diffScalar(baseline.description, edited.description),
      'imageUrls' => _diffList(baseline.imageUrls, edited.imageUrls),
      'city' => _diffScalar(baseline.city, edited.city),
      'ward' => _diffScalar(baseline.ward, edited.ward),
      'streetAddress' => _diffScalar(
        baseline.streetAddress,
        edited.streetAddress,
      ),
      'location' => _diffGeo(baseline.location, edited.location),
      'propertyTypes' => _diffListOrderIndependent(
        baseline.propertyTypes,
        edited.propertyTypes,
      ),
      'facilities' => _diffListOrderIndependent(
        baseline.facilities,
        edited.facilities,
      ),
      'rules' => _diffListOrderIndependent(baseline.rules, edited.rules),
      'rulesDescription' => _diffScalar(
        baseline.rulesDescription,
        edited.rulesDescription,
      ),
      'serviceFee' => _diffScalar(baseline.serviceFee, edited.serviceFee),
      'electricityPrice' => _diffScalar(
        baseline.electricityPrice,
        edited.electricityPrice,
      ),
      'waterPrice' => _diffScalar(baseline.waterPrice, edited.waterPrice),
      'wifiPrice' => _diffScalar(baseline.wifiPrice, edited.wifiPrice),
      'parkingFee' => _diffScalar(baseline.parkingFee, edited.parkingFee),
      'minimumRentalDuration' => _diffScalar(
        baseline.minimumRentalDuration,
        edited.minimumRentalDuration,
      ),
      'serviceDescription' => _diffScalar(
        baseline.serviceDescription,
        edited.serviceDescription,
      ),
      'curfewTime' => _diffScalar(baseline.curfewTime, edited.curfewTime),
      _ => null,
    };
  }

  dynamic _diffRoomField(RoomModel baseline, RoomModel edited, String field) {
    return switch (field) {
      'roomName' => _diffScalar(baseline.roomName, edited.roomName),
      'roomLocation' => _diffScalar(baseline.roomLocation, edited.roomLocation),
      'price' => _diffScalar(baseline.price, edited.price),
      'priceDeposit' => _diffScalar(baseline.priceDeposit, edited.priceDeposit),
      'area' => _diffScalar(baseline.area, edited.area),
      'maxTenants' => _diffScalar(baseline.maxTenants, edited.maxTenants),
      'amenities' => _diffAmenities(baseline.amenities, edited.amenities),
      'imageUrls' => _diffList(baseline.imageUrls, edited.imageUrls),
      'isAvailable' => _diffScalar(baseline.isAvailable, edited.isAvailable),
      _ => null,
    };
  }

  dynamic _diffScalar(dynamic a, dynamic b) {
    if (a is String || b is String) {
      final left = (a?.toString() ?? '').trim();
      final right = (b?.toString() ?? '').trim();
      if (left == right) return null;
      return b;
    }
    if (a == b) return null;
    return b;
  }

  dynamic _diffList(List<dynamic>? a, List<dynamic>? b) {
    final left = a ?? const [];
    final right = b ?? const [];
    if (_equality.equals(left, right)) return null;
    return right;
  }

  dynamic _diffListOrderIndependent(List<dynamic>? a, List<dynamic>? b) {
    final left = List<dynamic>.from(a ?? const [])..sort();
    final right = List<dynamic>.from(b ?? const [])..sort();
    if (_equality.equals(left, right)) return null;
    return b ?? const [];
  }

  dynamic _diffAmenities(List<RoomAmenity> a, List<RoomAmenity> b) {
    final left = a.map((e) => e.toMap()).toList();
    final right = b.map((e) => e.toMap()).toList();
    if (_equality.equals(left, right)) return null;
    return right;
  }

  dynamic _diffGeo(GeoPoint? a, GeoPoint? b) {
    if (a == null && b == null) return null;
    if (a != null &&
        b != null &&
        a.latitude == b.latitude &&
        a.longitude == b.longitude) {
      return null;
    }
    if (b == null) return null;
    return {'latitude': b.latitude, 'longitude': b.longitude};
  }

  static bool _isPriceMustReview(int oldPrice, int newPrice) {
    if (oldPrice == newPrice) return false;
    if (oldPrice <= 0) return true;
    final delta = (newPrice - oldPrice).abs() / oldPrice;
    return delta > 0.2;
  }

  static bool _hasLocalImagePaths(Map<String, dynamic> data) {
    for (final value in data.values) {
      if (value is List) {
        for (final item in value) {
          final path = item?.toString() ?? '';
          if (path.isNotEmpty && !_isRemoteUrl(path)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static bool _isRemoteUrl(String path) {
    final lower = path.trim().toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }
}
