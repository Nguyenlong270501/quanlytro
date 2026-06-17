import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'landlord_navigation_state.dart';

enum LandlordTab { home, posts, createPost, messages, account }

class LandlordNavigationCubit extends Cubit<LandlordNavigationState> {
  LandlordNavigationCubit({LandlordTab initialTab = LandlordTab.home})
      : super(LandlordNavigationState(currentTab: initialTab));

  void changeTab(LandlordTab tab) => emit(state.copyWith(currentTab: tab));

  void changeTabByIndex(int index) {
    if (index < 0 || index >= LandlordTab.values.length) return;
    emit(state.copyWith(currentTab: LandlordTab.values[index]));
  }
}
