import 'package:flutter_bloc/flutter_bloc.dart';

import 'property_filter_state.dart';

class PropertyFilterCubit extends Cubit<PropertyFilterState> {
  PropertyFilterCubit() : super(const PropertyFilterState());

  void changeFilter(PropertyFilter filter) =>
      emit(state.copyWith(currentFilter: filter));
}
