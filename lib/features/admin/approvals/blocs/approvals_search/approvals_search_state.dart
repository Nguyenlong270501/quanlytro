import 'package:equatable/equatable.dart';

class ApprovalsSearchState extends Equatable {
  const ApprovalsSearchState({
    this.isSearchActive = false,
    this.searchQuery = '',
  });

  final bool isSearchActive;
  final String searchQuery;

  ApprovalsSearchState copyWith({
    bool? isSearchActive,
    String? searchQuery,
    bool clearSearchQuery = false,
  }) {
    return ApprovalsSearchState(
      isSearchActive: isSearchActive ?? this.isSearchActive,
      searchQuery: clearSearchQuery ? '' : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [isSearchActive, searchQuery];
}
