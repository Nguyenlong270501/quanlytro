import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../landlord/create_property/presentation/shared_widgets/section_card.dart';
import '../../property_request/widgets/admin_pending_room_list.dart';

class PropertyDetailRoomsSection extends StatelessWidget {
  const PropertyDetailRoomsSection({
    super.key,
    required this.roomCount,
    required this.isLoading,
    required this.entries,
  });

  final int roomCount;
  final bool isLoading;
  final List<AdminRoomListEntry> entries;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      emoji: '🛏️',
      title: isLoading
          ? 'Chi tiết phòng'
          : 'Chi tiết phòng ($roomCount phòng)',
      child: isLoading
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : AdminPendingRoomList(entries: entries),
    );
  }
}
