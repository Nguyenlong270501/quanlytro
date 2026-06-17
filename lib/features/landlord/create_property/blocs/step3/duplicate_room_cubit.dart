import 'package:flutter_bloc/flutter_bloc.dart';

class DuplicateRoomCubit extends Cubit<int> {
  DuplicateRoomCubit({required this.maxCount})
    : assert(maxCount >= 1, 'maxCount must be at least 1'),
      super(1);

  final int maxCount;

  void increment() {
    if (state < maxCount) {
      emit(state + 1);
    }
  }

  void decrement() {
    if (state > 1) {
      emit(state - 1);
    }
  }
}