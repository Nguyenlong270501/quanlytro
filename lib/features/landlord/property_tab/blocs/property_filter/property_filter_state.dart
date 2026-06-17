import 'package:equatable/equatable.dart';

enum PropertyFilter { all, pending, approved, rejected, hidden }

class PropertyFilterState extends Equatable {
  const PropertyFilterState({this.currentFilter = PropertyFilter.all});

  final PropertyFilter currentFilter;

  PropertyFilterState copyWith({PropertyFilter? currentFilter}) =>
      PropertyFilterState(currentFilter: currentFilter ?? this.currentFilter);

  @override
  List<Object?> get props => [currentFilter];
}
