import 'package:cloud_firestore/cloud_firestore.dart';

import 'landlord_summary_model.dart';
import 'pending_property_update.dart';
import 'room_model.dart';

enum PropertyStatus {
  pending, // Chờ duyệt
  approved, // Đã duyệt (Đang hiển thị)
  rejected, // Bị từ chối
  hidden, // Ẩn
}

class PropertyModel {
  final String propertyId;
  final String landlordId;
  final String quotaId;
  final LandlordSummaryModel? landlordSummary;

  // Thông tin chung
  final String title;
  final String description;
  final List<String> propertyTypes;

  final int? minRoomPrice;
  final int? maxRoomPrice;

  // Vị trí
  final String city;
  final String ward;
  final String streetAddress;
  final GeoPoint? location;
  final double? latitude;
  final double? longitude;

  // Chi phí & Tiện ích
  final int electricityPrice;
  final int waterPrice;
  final int? wifiPrice;
  final int? serviceFee;
  final int? parkingFee;
  final String? serviceDescription;
  final List<String>? facilities;
  final List<String>? rules;
  final String? rulesDescription;
  final String? curfewTime;
  final List<String>? imageUrls;
  final int? minimumRentalDuration;

  // Quản lý & Thống kê
  final PropertyStatus status;
  final PropertyStatus? previousStatus;
  final bool hasPendingUpdate;
  final PendingPropertyUpdate? pendingUpdate;
  final String? rejectedReason;
  final double ratingAverage;
  final int totalReviews;
  final int totalRatingPoints;
  final Map<String, int> ratingDistribution;

  // Dữ liệu mở rộng (không lưu trực tiếp vào collection properties)
  final List<RoomModel>? rooms;

  // Thời gian
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  PropertyModel({
    required this.propertyId,
    required this.landlordId,
    this.deletedAt,
    required this.quotaId,
    required this.title,
    required this.description,
    required this.propertyTypes,
    this.landlordSummary,
    this.minRoomPrice,
    this.maxRoomPrice,
    required this.city,
    required this.ward,
    required this.streetAddress,
    this.location,
    this.latitude,
    this.longitude,
    required this.electricityPrice,
    required this.waterPrice,
    this.wifiPrice,
    this.serviceFee,
    this.parkingFee,
    this.serviceDescription,
    this.facilities,
    this.rules,
    this.rulesDescription,
    this.curfewTime,
    this.imageUrls,
    this.minimumRentalDuration = 0,
    this.status = PropertyStatus.pending,
    this.previousStatus,
    this.hasPendingUpdate = false,
    this.pendingUpdate,
    this.rejectedReason,
    this.ratingAverage = 0.0,
    this.totalReviews = 0,
    this.totalRatingPoints = 0,
    this.ratingDistribution = const {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
    this.rooms,
    required this.createdAt,
    required this.updatedAt,
  });

  PropertyModel copyWith({
    String? propertyId,
    String? landlordId,
    String? quotaId,
    String? title,
    String? description,
    List<String>? propertyTypes,
    LandlordSummaryModel? landlordSummary,
    String? city,
    String? ward,
    String? streetAddress,
    GeoPoint? location,
    double? latitude,
    double? longitude,
    int? minRoomPrice,
    int? maxRoomPrice,
    int? electricityPrice,
    int? waterPrice,
    int? wifiPrice,
    int? parkingFee,
    int? serviceFee,
    String? serviceDescription,
    List<String>? facilities,
    List<String>? rules,
    String? rulesDescription,
    String? curfewTime,
    List<String>? imageUrls,
    int? minimumRentalDuration,
    PropertyStatus? status,
    PropertyStatus? previousStatus,
    bool clearPreviousStatus = false,
    bool? hasPendingUpdate,
    PendingPropertyUpdate? pendingUpdate,
    bool clearPendingUpdate = false,
    String? rejectedReason,
    bool clearRejectedReason = false,
    double? ratingAverage,
    int? totalReviews,
    int? totalRatingPoints,
    Map<String, int>? ratingDistribution,
    List<RoomModel>? rooms,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PropertyModel(
      propertyId: propertyId ?? this.propertyId,
      landlordId: landlordId ?? this.landlordId,
      quotaId: quotaId ?? this.quotaId,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      landlordSummary: landlordSummary ?? this.landlordSummary,
      city: city ?? this.city,
      ward: ward ?? this.ward,
      streetAddress: streetAddress ?? this.streetAddress,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      minRoomPrice: minRoomPrice ?? this.minRoomPrice,
      maxRoomPrice: maxRoomPrice ?? this.maxRoomPrice,
      electricityPrice: electricityPrice ?? this.electricityPrice,
      waterPrice: waterPrice ?? this.waterPrice,
      wifiPrice: wifiPrice ?? this.wifiPrice,
      serviceFee: serviceFee ?? this.serviceFee,
      parkingFee: parkingFee ?? this.parkingFee,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      facilities: facilities ?? this.facilities,
      rules: rules ?? this.rules,
      rulesDescription: rulesDescription ?? this.rulesDescription,
      curfewTime: curfewTime ?? this.curfewTime,
      imageUrls: imageUrls ?? this.imageUrls,
      minimumRentalDuration:
          minimumRentalDuration ?? this.minimumRentalDuration,
      status: status ?? this.status,
      previousStatus: clearPreviousStatus
          ? null
          : (previousStatus ?? this.previousStatus),
      hasPendingUpdate: hasPendingUpdate ?? this.hasPendingUpdate,
      pendingUpdate: clearPendingUpdate
          ? null
          : (pendingUpdate ?? this.pendingUpdate),
      rejectedReason: clearRejectedReason
          ? null
          : (rejectedReason ?? this.rejectedReason),
      ratingAverage: ratingAverage ?? this.ratingAverage,
      totalReviews: totalReviews ?? this.totalReviews,
      totalRatingPoints: totalRatingPoints ?? this.totalRatingPoints,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
      rooms: rooms ?? this.rooms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'landlordId': landlordId,
      'quotaId': quotaId,
      'title': title,
      'description': description,
      'propertyTypes': propertyTypes,
      'landlordSummary': landlordSummary?.toMap(),
      'city': city,
      'ward': ward,
      'streetAddress': streetAddress,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'electricityPrice': electricityPrice,
      'waterPrice': waterPrice,
      'wifiPrice': wifiPrice,
      'serviceFee': serviceFee,
      'parkingFee': parkingFee,
      'serviceDescription': serviceDescription,
      'facilities': facilities,
      'rules': rules,
      'rulesDescription': rulesDescription,
      'curfewTime': curfewTime,
      'imageUrls': imageUrls,
      'minimumRentalDuration': minimumRentalDuration,
      'status': status.name,
      'previousStatus': previousStatus?.name,
      'hasPendingUpdate': hasPendingUpdate,
      if (pendingUpdate != null) 'pendingUpdate': pendingUpdate!.toMap(),
      'rejectedReason': rejectedReason,
      'ratingAverage': ratingAverage,
      'totalReviews': totalReviews,
      'totalRatingPoints': totalRatingPoints,
      'ratingDistribution': ratingDistribution,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    final statusString = map['status'] ?? 'pending';
    final parsedStatus = PropertyStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => PropertyStatus.pending,
    );
    final previousStatusString = map['previousStatus']?.toString();
    final parsedPreviousStatus = previousStatusString == null
        ? null
        : PropertyStatus.values.firstWhere(
            (e) => e.name == previousStatusString,
            orElse: () => parsedStatus,
          );

    return PropertyModel(
      propertyId: map['propertyId'] ?? '',
      landlordId: map['landlordId'] ?? '',
      quotaId: map['quotaId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      propertyTypes: _parsePropertyTypes(map),
      landlordSummary: _parseLandlordSummary(map['landlordSummary']),
      city: map['city'] ?? '',
      ward: map['ward'] ?? '',
      streetAddress: map['streetAddress'] ?? '',
      location: _parseGeoPoint(map['location']),
      latitude: _parseOptionalDouble(map['latitude']),
      longitude: _parseOptionalDouble(map['longitude']),
      electricityPrice: (map['electricityPrice'] ?? 0).toInt(),
      waterPrice: (map['waterPrice'] ?? 0).toInt(),
      wifiPrice: map['wifiPrice']?.toInt(),
      serviceFee: map['serviceFee']?.toInt(),
      parkingFee: map['parkingFee']?.toInt(),
      serviceDescription: map['serviceDescription'] ?? '',
      facilities: List<String>.from(map['facilities'] ?? []),
      rules: List<String>.from(map['rules'] ?? []),
      rulesDescription: map['rulesDescription'] ?? '',
      curfewTime: map['curfewTime'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      minimumRentalDuration: map['minimumRentalDuration']?.toInt() ?? 0,
      status: parsedStatus,
      previousStatus: parsedPreviousStatus,
      hasPendingUpdate: map['hasPendingUpdate'] == true,
      pendingUpdate: PendingPropertyUpdate.fromMap(
        map['pendingUpdate'] is Map
            ? Map<String, dynamic>.from(map['pendingUpdate'] as Map)
            : null,
      ),
      rejectedReason: map['rejectedReason'] ?? '',
      ratingAverage: (map['ratingAverage'] ?? 0).toDouble(),
      totalReviews: map['totalReviews']?.toInt() ?? 0,
      totalRatingPoints: map['totalRatingPoints']?.toInt() ?? 0,
      ratingDistribution: _parseRatingDistribution(map['ratingDistribution']),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      deletedAt: _parseOptionalDateTime(map['deletedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static DateTime? _parseOptionalDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static GeoPoint? _parseGeoPoint(dynamic value) {
    if (value is GeoPoint) return value;
    if (value is Map) {
      final m = Map<String, dynamic>.from(value);
      if (m.containsKey('lat') && m.containsKey('lng')) {
        final lat = (m['lat'] as num?)?.toDouble();
        final lng = (m['lng'] as num?)?.toDouble();
        if (lat != null && lng != null) return GeoPoint(lat, lng);
      }
      final lat = (m['latitude'] ?? m['_latitude'] ?? 0).toDouble();
      final lng = (m['longitude'] ?? m['_longitude'] ?? 0).toDouble();
      return GeoPoint(lat, lng);
    }
    return null;
  }

  static List<String> _parsePropertyTypes(Map<String, dynamic> map) {
    final rawTypes = map['propertyTypes'];
    if (rawTypes is List) {
      final normalized = <String>[];
      for (final type in rawTypes) {
        final text = type?.toString().trim() ?? '';
        if (text.isNotEmpty) {
          normalized.add(text);
        }
      }
      return normalized;
    }

    return const [];
  }

  static double? _parseOptionalDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static LandlordSummaryModel? _parseLandlordSummary(dynamic value) {
    if (value is Map<String, dynamic>) {
      return LandlordSummaryModel.fromMap(value);
    }
    if (value is Map) {
      return LandlordSummaryModel.fromMap(Map<String, dynamic>.from(value));
    }
    return null;
  }

  static Map<String, int> _parseRatingDistribution(dynamic value) {
    const defaults = <String, int>{'1': 0, '2': 0, '3': 0, '4': 0, '5': 0};
    if (value is! Map) {
      return defaults;
    }

    final parsed = <String, int>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final item = entry.value;
      if (!defaults.containsKey(key) || item is! int) {
        continue;
      }
      parsed[key] = item;
    }

    return <String, int>{...defaults, ...parsed};
  }
}
