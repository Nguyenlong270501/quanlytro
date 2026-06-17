import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'admin_navigation_state.dart';

enum AdminTab { dashboard, review, users, settings }

class AdminNavigationCubit extends Cubit<AdminNavigationState> {
  AdminNavigationCubit() : super(const AdminNavigationState());

  void changeTab(AdminTab tab) => emit(state.copyWith(currentTab: tab));

  void changeTabByIndex(int index) {
    if (index < 0 || index >= AdminTab.values.length) return;
    emit(state.copyWith(currentTab: AdminTab.values[index]));
  }
}
