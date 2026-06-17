import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/utils/review_helper.dart';
import '../../../../../landlord/create_property/data/models/property_model.dart';
import '../../../../../landlord/create_property/data/models/room_model.dart';
import '../../../../../landlord/create_property/presentation/steps/step4/widgets/room_mini_card.dart';
import '../../../../../landlord/create_property/presentation/steps/step4/models/room_preview_screen_args.dart';
import '../../../../../landlord/create_property/presentation/steps/step4/room_preview_screen.dart'
    show openRoomPreviewScreen;
import 'pending_update_display_formatter.dart';
import 'pending_value_banner.dart';

enum AdminRoomListEntryKind { live, newRoom }

class AdminRoomListEntry {
  const AdminRoomListEntry({
    required this.kind,
    required this.room,
    required this.displayName,
    required this.priceLabel,
    required this.highlightCard,
    this.pendingLines = const [],
  });

  final AdminRoomListEntryKind kind;
  final RoomModel room;
  final String displayName;
  final String priceLabel;
  final bool highlightCard;
  final List<PendingChangeLine> pendingLines;
}

class AdminPendingRoomList extends StatelessWidget {
  const AdminPendingRoomList({super.key, required this.entries});

  final List<AdminRoomListEntry> entries;

  static List<AdminRoomListEntry> buildEntries({
    required PropertyModel property,
    required List<RoomModel> liveRooms,
    required PendingUpdateIndex? pendingIndex,
  }) {
    if (pendingIndex == null || pendingIndex.isEmpty) {
      final sorted = [...liveRooms]
        ..sort((a, b) => compareNatural(a.roomName, b.roomName));
      return sorted
          .map(
            (r) => AdminRoomListEntry(
              kind: AdminRoomListEntryKind.live,
              room: r,
              displayName: r.roomName,
              priceLabel: '${ReviewHelper.formatPrice(r.price)} đ/tháng',
              highlightCard: false,
            ),
          )
          .toList();
    }

    final pending = property.pendingUpdate;
    final roomCreates = pending?.roomCreates ?? const <Map<String, dynamic>>[];

    final top = <AdminRoomListEntry>[];
    final bottom = <AdminRoomListEntry>[];

    for (final bundle in pendingIndex.newRooms) {
      final roomMap = bundle.index < roomCreates.length
          ? roomCreates[bundle.index]
          : <String, dynamic>{'roomName': bundle.roomName};
      final room = PendingUpdateDisplayFormatter.roomFromPendingCreate(
        roomMap,
        propertyId: property.propertyId,
        landlordId: property.landlordId,
      );
      top.add(
        AdminRoomListEntry(
          kind: AdminRoomListEntryKind.newRoom,
          room: room,
          displayName: '${bundle.roomName} (phòng mới)',
          priceLabel: '${ReviewHelper.formatPrice(room.price)} đ/tháng',
          highlightCard: true,
        ),
      );
    }

    top.sort((a, b) => compareNatural(a.displayName, b.displayName));

    for (final room in liveRooms) {
      final fields = pendingIndex.roomFields(room.roomId);
      if (fields != null && fields.isNotEmpty) {
        final pendingPrice = pendingIndex.pendingPriceForRoom(room.roomId);
        final price = pendingPrice ?? room.price;
        top.add(
          AdminRoomListEntry(
            kind: AdminRoomListEntryKind.live,
            room: room,
            displayName: '${room.roomName} (có chỉnh sửa mới)',
            priceLabel: '${ReviewHelper.formatPrice(price)} đ/tháng',
            highlightCard: true,
            pendingLines: fields.values.toList(),
          ),
        );
      } else {
        bottom.add(
          AdminRoomListEntry(
            kind: AdminRoomListEntryKind.live,
            room: room,
            displayName: room.roomName,
            priceLabel: '${ReviewHelper.formatPrice(room.price)} đ/tháng',
            highlightCard: false,
          ),
        );
      }
    }

    bottom.sort((a, b) => compareNatural(a.displayName, b.displayName));

    return [...top, ...bottom];
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Text(
        'Không có dữ liệu phòng.',
        style: AppTypography.medium12(color: AppColors.textMuted),
      );
    }

    return SizedBox(
      height: min(entries.length * 90.h, 260.h),
      child: ListView.separated(
        itemCount: entries.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, i) {
          final entry = entries[i];

          return RoomMiniCard(
            name: entry.displayName,
            priceLabel: entry.priceLabel,
            highlightPending: entry.highlightCard,
            onTap: () => _openRoomDetail(context, entry),
          );
        },
      ),
    );
  }
}

void _openRoomDetail(BuildContext context, AdminRoomListEntry entry) {
  RoomPreviewPendingImages? pendingImages;
  final pendingFooters = <Widget>[];

  for (final line in entry.pendingLines) {
    if (line.hasImages) {
      pendingImages = RoomPreviewPendingImages(
        caption: line.label,
        imageUrls: line.imageUrls,
        subtitle: line.newValue.isNotEmpty ? line.newValue : null,
      );
    } else {
      pendingFooters.add(PendingValueBanner(line: line, caption: line.label));
    }
  }

  openRoomPreviewScreen(
    context,
    room: entry.room,
    pendingImages: pendingImages,
    footerSections: pendingFooters,
  );
}
