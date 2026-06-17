import 'package:flutter_bloc/flutter_bloc.dart';

import 'approvals_search_state.dart';

class ApprovalsSearchCubit extends Cubit<ApprovalsSearchState> {
  ApprovalsSearchCubit() : super(const ApprovalsSearchState());

  void enterSearch() => emit(state.copyWith(isSearchActive: true));

  void exitSearch() => emit(
    state.copyWith(
      isSearchActive: false,
      clearSearchQuery: true,
    ),
  );

  void updateSearchQuery(String query) =>
      emit(state.copyWith(searchQuery: query));
}
