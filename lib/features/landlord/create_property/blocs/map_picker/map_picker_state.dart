import '../../../../../core/services/location_service.dart';
import '../../data/models/picked_location.dart';

class MapPickerState {
  final PickedLocation? pickedLocation;
  final bool isResolvingAddress;
  final bool isLoadingCurrentLocation;
  final PermissionStatus? permissionStatus;

  const MapPickerState({
    this.pickedLocation,
    this.isResolvingAddress = false,
    this.isLoadingCurrentLocation = false,
    this.permissionStatus,
  });

  MapPickerState copyWith({
    PickedLocation? pickedLocation,
    bool? isResolvingAddress,
    bool? isLoadingCurrentLocation,
    PermissionStatus? permissionStatus,
  }) {
    return MapPickerState(
      // Dùng cú pháp này để giữ được null nếu muốn
      pickedLocation: pickedLocation ?? this.pickedLocation,
      isResolvingAddress: isResolvingAddress ?? this.isResolvingAddress,
      isLoadingCurrentLocation: isLoadingCurrentLocation ?? this.isLoadingCurrentLocation,
      permissionStatus: permissionStatus, // Mỗi lần emit lỗi permission xong thì reset lại
    );
  }
}