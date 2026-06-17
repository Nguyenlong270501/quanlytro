import 'package:flutter/material.dart';

import '../../../../data/models/room_model.dart';

class RoomPreviewPendingImages {
  const RoomPreviewPendingImages({
    required this.caption,
    required this.imageUrls,
    this.subtitle,
  });

  final String caption;
  final List<String> imageUrls;
  final String? subtitle;
}

class RoomPreviewScreenArgs {
  const RoomPreviewScreenArgs({
    required this.room,
    this.footerSections = const [],
    this.pendingImages,
    this.isReadOnly = true,
    this.roomIndex,
    this.persistRoomEdit,
  });

  final RoomModel room;
  final List<Widget> footerSections;
  final RoomPreviewPendingImages? pendingImages;
  final bool isReadOnly;

  /// Chỉ số phòng trong [Step3Cubit] (luồng tạo/sửa bài).
  final int? roomIndex;

  final Future<bool> Function(RoomModel updated)? persistRoomEdit;
}
