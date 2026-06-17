import 'dart:math' as math;

import 'blocs/step1/step1_state.dart';


abstract final class RoomQuotaCaps {
  static const int kRoomsPerUploadBatch = 10;

  static int? quotaMaxRooms(Step1State s) {
    if (s.quotaSelectionLocked) {
      return s.lockedQuotaSnapshot?.maxRooms;
    }
    final id = s.selectedQuotaId?.trim();
    if (id == null || id.isEmpty) return null;
    for (final q in s.availableQuotas) {
      if (q.quotaId == id) return q.maxRooms;
    }
    return null;
  }

  static int roomsCommittedAtOpenForEdit({
    required int initialRoomListLength,
    required int? quotaUsedRooms,
  }) {
    final fromQuota = quotaUsedRooms ?? 0;
    return math.max(fromQuota, initialRoomListLength);
  }

  static int roomsCommittedAtOpenForCreate() => 0;

  static int maxRoomsOnListThisSession({
    required int quotaMaxRooms,
    required int roomsCommittedAtOpen,
  }) {
    if (quotaMaxRooms <= 0) return 0;
    final batchIncrement = quotaMaxRooms > kRoomsPerUploadBatch
        ? kRoomsPerUploadBatch
        : quotaMaxRooms;
    return math.min(quotaMaxRooms, roomsCommittedAtOpen + batchIncrement);
  }

  static int maxListForStep3({
    required Step1State step1,
    required int initialRoomListLength,
    required bool isEditFlow,
  }) {
    final qm = quotaMaxRooms(step1);
    if (qm == null || qm <= 0) return 0;
    final committed = isEditFlow
        ? roomsCommittedAtOpenForEdit(
            initialRoomListLength: initialRoomListLength,
            quotaUsedRooms: step1.lockedQuotaSnapshot?.usedRooms,
          )
        : roomsCommittedAtOpenForCreate();
    return maxRoomsOnListThisSession(
      quotaMaxRooms: qm,
      roomsCommittedAtOpen: committed,
    );
  }
}
