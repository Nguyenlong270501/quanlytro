import 'package:equatable/equatable.dart';

enum ApprovalFilter { pending, pendingUpdate, approved, rejected }

class ApprovalFilterState extends Equatable {
  const ApprovalFilterState({this.currentFilter = ApprovalFilter.pending});

  final ApprovalFilter currentFilter;

  ApprovalFilterState copyWith({ApprovalFilter? currentFilter}) =>
      ApprovalFilterState(currentFilter: currentFilter ?? this.currentFilter);

  @override
  List<Object?> get props => [currentFilter];
}
