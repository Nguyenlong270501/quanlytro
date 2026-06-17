part of 'admin_navigation_cubit.dart';

final class AdminNavigationState extends Equatable {
  const AdminNavigationState({this.currentTab = AdminTab.dashboard});

  final AdminTab currentTab;

  int get currentIndex => currentTab.index;

  AdminNavigationState copyWith({AdminTab? currentTab}) =>
      AdminNavigationState(currentTab: currentTab ?? this.currentTab);

  @override
  List<Object?> get props => [currentTab];
}
