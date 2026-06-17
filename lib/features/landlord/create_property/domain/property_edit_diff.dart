import '../data/models/pending_property_update.dart';

class PropertyEditDiff {
  const PropertyEditDiff({
    this.autoPropertyPatch = const {},
    this.autoRoomChanges = const {},
    this.autoRoomDeletes = const [],
    this.pendingUpdate,
    this.needsImageUpload = false,
  });

  final Map<String, dynamic> autoPropertyPatch;
  final Map<String, Map<String, dynamic>> autoRoomChanges;
  final List<String> autoRoomDeletes;
  final PendingPropertyUpdate? pendingUpdate;
  final bool needsImageUpload;

  bool get hasAutoPass =>
      autoPropertyPatch.isNotEmpty ||
      autoRoomChanges.isNotEmpty ||
      autoRoomDeletes.isNotEmpty;

  bool get hasMustReview => pendingUpdate != null;

  bool get isEmpty => !hasAutoPass && !hasMustReview;
}
