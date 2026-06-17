import 'package:cloud_firestore/cloud_firestore.dart';
import 'room_amenity.dart';

class RoomModel {
  final String roomId;
  final String propertyId;

  // Chi tiết phòng
  final String roomName;
  final String roomLocation; 
  final int price;
  final int priceDeposit;
  final double area;
  final int maxTenants;
  final List<RoomAmenity> amenities;
  final List<String> imageUrls;

  // Trạng thái
  final bool isAvailable;

  // Thời gian
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomModel({
    required this.roomId,
    required this.propertyId,
    required this.roomName,
    required this.roomLocation,
    required this.price,
    required this.priceDeposit,
    required this.area,
    required this.maxTenants,
    required this.amenities,
    required this.imageUrls,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  RoomModel copyWith({
    String? roomId,
    String? propertyId,
    String? roomName,
    String? roomLocation,
    int? price,
    int? priceDeposit,
    double? area,
    int? maxTenants,
    List<RoomAmenity>? amenities,
    List<String>? imageUrls,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      propertyId: propertyId ?? this.propertyId,
      roomName: roomName ?? this.roomName,
      roomLocation: roomLocation ?? this.roomLocation,
      price: price ?? this.price,
      priceDeposit: priceDeposit ?? this.priceDeposit,
      area: area ?? this.area,
      maxTenants: maxTenants ?? this.maxTenants,
      amenities: amenities ?? this.amenities,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'propertyId': propertyId,
      'roomName': roomName,
      'roomLocation': roomLocation,
      'price': price,
      'priceDeposit': priceDeposit,
      'area': area,
      'maxTenants': maxTenants,
      'amenities': amenities.map((e) => e.toMap()).toList(),
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      roomId: map['roomId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      roomName: map['roomName'] ?? '',
      roomLocation: map['roomLocation'] ?? '',
      price: (map['price'] ?? 0).toInt(),
      priceDeposit: (map['priceDeposit'] ?? 0).toInt(),
      area: (map['area'] ?? 0).toDouble(),
      maxTenants: map['maxTenants']?.toInt() ?? 1,
      amenities: (map['amenities'] as List<dynamic>?)
              ?.map((e) => RoomAmenity.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}