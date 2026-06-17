import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:quanlytro/core/widgets/app_alerts.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/route/app_routes.dart';
import '../../../blocs/step1/step1_cubit.dart';
import '../../../blocs/step1/step1_state.dart';
import '../../../blocs/step3/step3_cubit.dart';
import '../../../blocs/step3/step3_state.dart';
import '../../../room_quota_caps.dart';
import 'widgets/add_room_button.dart';
import 'widgets/duplicate_room_dialog.dart';
import 'widgets/room_card.dart';

class StepRoomsScreen extends StatelessWidget {
  const StepRoomsScreen({super.key});

  int _maxList(Step1State s1, Step3Cubit step3) {
    return RoomQuotaCaps.maxListForStep3(
      step1: s1,
      initialRoomListLength: step3.roomsAtWizardOpen,
      isEditFlow: s1.quotaSelectionLocked,
    );
  }

  Future<void> _handleAddNew(
    BuildContext context, {
    required int maxList,
  }) async {
    final step3 = context.read<Step3Cubit>();
    if (step3.state.rooms.length >= maxList) {
      _showAtCapSnack(context, maxList: maxList);
      return;
    }
    final result = await context.push<RoomModel>(RouteNames.roomDetail);
    if (result == null || !context.mounted) return;
    if (context.read<Step3Cubit>().state.rooms.length >= maxList) {
      Alerts.of(context).showError(
        'Đã đạt giới hạn số phòng cho lượt này theo hạn mức. Vui lòng lưu và chỉnh sửa sau để thêm tiếp.',
      );
      return;
    }
    context.read<Step3Cubit>().addRoom(result);
  }

  void _showAtCapSnack(BuildContext context, {required int maxList}) {
    final s1 = context.read<Step1Cubit>().state;
    final qm = RoomQuotaCaps.quotaMaxRooms(s1);
    final batch = RoomQuotaCaps.kRoomsPerUploadBatch;
    if (qm != null &&
        qm > batch &&
        maxList < qm) {
      Alerts.of(context).showWarning(
        'Mỗi lượt tối đa $batch phòng để đảm bảo hiệu năng. Bạn đã đạt $maxList phòng trong lượt này — lưu bài rồi vào Quản lý để thêm đến tối đa $qm phòng.',
      );
    } else {
      Alerts.of(context).showWarning(
        'Đã đạt tối đa $maxList phòng theo hạn mức đã chọn.',
      );
    }
  }

  void _showDuplicateDialog(
    BuildContext context,
    RoomModel roomToCopy, {
    required int maxList,
  }) {
    final step3 = context.read<Step3Cubit>();
    final current = step3.state.rooms.length;
    final slots = maxList - current;
    if (slots <= 0) {
      _showAtCapSnack(context, maxList: maxList);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return DuplicateRoomDialog(
          roomToCopy: roomToCopy,
          maxDuplicateCount: slots,
          onConfirm: (count) {
            if (!context.mounted) return;
            final cubit = context.read<Step3Cubit>();
            final currentRoomCount = cubit.state.rooms.length;

            if (currentRoomCount + count > maxList) {
              Alerts.of(context).showError(
                'Vượt quá số phòng cho phép trong lượt này. Vui lòng lưu và chỉnh sửa sau để thêm tiếp.',
              );
              return;
            }

            cubit.duplicateRoom(
              sourceRoom: roomToCopy,
              duplicateCount: count,
              maxTotalRoomsOnList: maxList,
            );

            Alerts.of(
              context,
            ).showSuccess('Đã nhân bản $count phòng thành công!');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Step1Cubit, Step1State>(
      buildWhen: (a, b) =>
          a.quotaSelectionLocked != b.quotaSelectionLocked ||
          a.selectedQuotaId != b.selectedQuotaId ||
          a.availableQuotas != b.availableQuotas ||
          a.lockedQuotaSnapshot != b.lockedQuotaSnapshot,
      builder: (context, s1) {
        return BlocBuilder<Step3Cubit, Step3State>(
          builder: (context, s3) {
            final step3 = context.read<Step3Cubit>();
            final rooms = s3.rooms;
            final maxList = _maxList(s1, step3);
            final canAddMore = maxList > 0 && rooms.length < maxList;
            final canDuplicateMore =
                maxList > 0 && rooms.length < maxList;

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              itemCount: rooms.length + (canAddMore ? 1 : 0),
              separatorBuilder: (context, index) => AppSizes.gapH16,
              itemBuilder: (context, index) {
                if (index == rooms.length) {
                  return AddRoomButton(
                    onTap: () => _handleAddNew(context, maxList: maxList),
                  );
                }
                return RoomCard(
                  room: rooms[index],
                  onEdit: () => _handleEdit(context, index),
                  onDelete: () => _handleDelete(context, index),
                  onDuplicate: canDuplicateMore
                      ? () => _showDuplicateDialog(
                          context,
                          rooms[index],
                          maxList: maxList,
                        )
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _handleEdit(BuildContext context, int index) async {
    final cubit = context.read<Step3Cubit>();
    final result = await context.push<RoomModel>(
      RouteNames.roomDetail,
      extra: cubit.state.rooms[index],
    );
    if (result == null || !context.mounted) return;
    cubit.updateRoomAt(index, result);
  }

  void _handleDelete(BuildContext context, int index) {
    context.read<Step3Cubit>().removeRoomAt(index);
  }
}
