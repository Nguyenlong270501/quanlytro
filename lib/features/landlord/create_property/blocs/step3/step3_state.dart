import 'package:equatable/equatable.dart';

import '../../data/models/room_model.dart';

export '../../data/models/room_model.dart';


class Step3State extends Equatable {
  const Step3State({this.rooms = const <RoomModel>[]});

  final List<RoomModel> rooms;

  bool get isValid => rooms.isNotEmpty;

  Step3State copyWith({List<RoomModel>? rooms}) {
    return Step3State(rooms: rooms ?? this.rooms);
  }

  @override
  List<Object?> get props => [rooms];
}
