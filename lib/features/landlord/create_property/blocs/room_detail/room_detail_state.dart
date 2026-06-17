class RoomDetailState {
  final Set<String> activeAmenities;
  final List<String> imageUrls;
  final bool isAvailable;
  final bool showErrors;

  const RoomDetailState({
    this.activeAmenities = const {},
    this.imageUrls = const [],
    this.isAvailable = true,
    this.showErrors = false,
  });

  RoomDetailState copyWith({
    Set<String>? activeAmenities,
    List<String>? imageUrls,
    bool? isAvailable,
    bool? showErrors,
  }) {
    return RoomDetailState(
      activeAmenities: activeAmenities ?? this.activeAmenities,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      showErrors: showErrors ?? this.showErrors,
    );
  }
}
