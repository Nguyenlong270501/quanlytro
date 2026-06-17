import 'package:flutter_bloc/flutter_bloc.dart';

import 'step3_state.dart';

class Step3Cubit extends Cubit<Step3State> {
  Step3Cubit({List<RoomModel> initialRooms = const <RoomModel>[]})
    : roomsAtWizardOpen = initialRooms.length,
      super(Step3State(rooms: List<RoomModel>.from(initialRooms)));

  /// Số phòng khi mở wizard (dùng với cap theo quota / usedRooms).
  final int roomsAtWizardOpen;

  void addRoom(RoomModel draft) {
    emit(state.copyWith(rooms: [...state.rooms, draft]));
  }

  void updateRoomAt(int index, RoomModel draft) {
    if (index < 0 || index >= state.rooms.length) return;
    final next = [...state.rooms];
    next[index] = draft;
    emit(state.copyWith(rooms: next));
  }

  void removeRoomAt(int index) {
    if (index < 0 || index >= state.rooms.length) return;
    final next = [...state.rooms]..removeAt(index);
    emit(state.copyWith(rooms: next));
  }


  void duplicateRoom({
    required RoomModel sourceRoom,
    required int duplicateCount,
    required int maxTotalRoomsOnList,
  }) {
    final currentRooms = List<RoomModel>.from(state.rooms);

    if (duplicateCount <= 0) return;
    if (currentRooms.length + duplicateCount > maxTotalRoomsOnList) return;

    for (int i = 0; i < duplicateCount; i++) {
      String newName = '${sourceRoom.roomName} (${i + 1})';

      final newRoom = sourceRoom.copyWith(
        roomId: '',
        roomName: newName,
        imageUrls: List<String>.from(sourceRoom.imageUrls),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      currentRooms.add(newRoom);
    }

    emit(state.copyWith(rooms: currentRooms));
  }

  void reset() => emit(const Step3State());
}
