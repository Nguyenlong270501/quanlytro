part of 'landlord_navigation_cubit.dart';

final class LandlordNavigationState extends Equatable {
  const LandlordNavigationState({this.currentTab = LandlordTab.home});

  final LandlordTab currentTab;

  int get currentIndex => currentTab.index;

  LandlordNavigationState copyWith({LandlordTab? currentTab}) =>
      LandlordNavigationState(currentTab: currentTab ?? this.currentTab);

  @override
  List<Object?> get props => [currentTab];
}
