import 'package:cloud_firestore/cloud_firestore.dart';

/// Chuyển giá trị từ map Firestore-like (Timestamp, GeoPoint, …) sang kiểu an toàn cho Hive.
/// Không mutate input — trả về cấu trúc mới.
dynamic sanitizeForFirestoreMapForHive(dynamic value) {
  if (value is FieldValue) {
    return DateTime.now().toUtc().toIso8601String();
  }
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is GeoPoint) {
    return <String, double>{
      'lat': value.latitude,
      'lng': value.longitude,
    };
  }
  if (value is List) {
    return value.map(sanitizeForFirestoreMapForHive).toList();
  }
  if (value is Map) {
    final out = <String, dynamic>{};
    value.forEach((k, v) {
      out[k.toString()] = sanitizeForFirestoreMapForHive(v);
    });
    return out;
  }
  return value;
}
