import 'package:flutter_bloc/flutter_bloc.dart';

import 'approval_tab_state.dart';

class ApprovalTabCubit extends Cubit<ApprovalTabState> {
  ApprovalTabCubit() : super(const ApprovalTabState());

  void changeTab(ApprovalSubTab tab) => emit(state.copyWith(currentTab: tab));

  void changeTabByIndex(int index) {
    if (index < 0 || index >= ApprovalSubTab.values.length) return;
    emit(state.copyWith(currentTab: ApprovalSubTab.values[index]));
  }
}
