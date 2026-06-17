import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/route/app_routes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/widgets/app_alerts.dart';
import '../../../blocs/step3/step3_cubit.dart';
import '../../../data/models/room_model.dart';
import 'models/room_preview_screen_args.dart';
import 'widgets/room_preview_content.dart';

void openRoomPreviewScreen(
  BuildContext context, {
  required RoomModel room,
  List<Widget> footerSections = const [],
  RoomPreviewPendingImages? pendingImages,
  bool isReadOnly = true,
  int? roomIndex,
  Future<bool> Function(RoomModel updated)? persistRoomEdit,
}) {
  context.push(
    RouteNames.roomPreview,
    extra: RoomPreviewScreenArgs(
      room: room,
      footerSections: footerSections,
      pendingImages: pendingImages,
      isReadOnly: isReadOnly,
      roomIndex: roomIndex,
      persistRoomEdit: persistRoomEdit,
    ),
  );
}

class RoomPreviewScreen extends StatelessWidget {
  const RoomPreviewScreen({super.key, required this.args});

  final RoomPreviewScreenArgs args;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final isReadOnly = args.isReadOnly;
    final room = args.room;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        centerTitle: true,
        title: Text(
          'Chi tiết phòng',
          style: AppTypography.bold20(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoomPreviewHeader(
            room: room,
            onEdit: isReadOnly ? null : () => _handleEditRoom(context, room),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20.w,
                16.h,
                20.w,
                20.h + bottomInset,
              ),
              child: RoomPreviewContent(
                room: room,
                isReadOnly: true,
                pendingImages: args.pendingImages,
                footerSections: args.footerSections,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEditRoom(
    BuildContext context,
    RoomModel currentData,
  ) async {
    final result = await context.push<RoomModel>(
      RouteNames.roomDetail,
      extra: currentData,
    );
    if (result == null || !context.mounted) return;

    final index = args.roomIndex;
    if (index != null) {
      try {
        context.read<Step3Cubit>().updateRoomAt(index, result);
        context.pop();
      } catch (_) {}
      return;
    }

    final persist = args.persistRoomEdit;
    if (persist != null) {
      try {
        final saved = await persist(result);
        if (saved && context.mounted) {
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          Alerts.of(context).showError(e.toString());
        }
      }
    }
  }
}
