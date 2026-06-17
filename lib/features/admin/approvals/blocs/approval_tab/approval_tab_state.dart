import 'package:equatable/equatable.dart';

enum ApprovalSubTab { landlord, post }

class ApprovalTabState extends Equatable {
  const ApprovalTabState({this.currentTab = ApprovalSubTab.landlord});

  final ApprovalSubTab currentTab;

  int get currentIndex => currentTab.index;

  ApprovalTabState copyWith({ApprovalSubTab? currentTab}) =>
      ApprovalTabState(currentTab: currentTab ?? this.currentTab);

  @override
  List<Object?> get props => [currentTab];
}
