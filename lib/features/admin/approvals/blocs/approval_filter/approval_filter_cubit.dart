import 'package:flutter_bloc/flutter_bloc.dart';

import 'approval_filter_state.dart';

class ApprovalFilterCubit extends Cubit<ApprovalFilterState> {
  ApprovalFilterCubit() : super(const ApprovalFilterState());

  void changeFilter(ApprovalFilter filter) =>
      emit(state.copyWith(currentFilter: filter));
}
