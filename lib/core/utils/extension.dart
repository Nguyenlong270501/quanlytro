import 'package:cloud_firestore/cloud_firestore.dart';


class Extension {
  static DateTime? parseTimestamp(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
