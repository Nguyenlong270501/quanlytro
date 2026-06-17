import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/property_constants.dart';
import '../../../../../core/services/image_picker_service.dart';
import '../../data/models/room_amenity.dart';
import '../../data/models/room_model.dart';
import 'room_detail_state.dart';

class RoomDetailCubit extends Cubit<RoomDetailState> {
  final ImagePickerService _imagePickerService;

  static const int minImages = 5;
  static const int maxImages = 20;

  RoomDetailCubit(
    this._imagePickerService, {
    Set<String>? initialAmenities,
    List<String>? initialImages,
    bool initialIsAvailable = true,
  }) : super(
         RoomDetailState(
           activeAmenities: initialAmenities ?? {},
           imageUrls: initialImages ?? [],
           isAvailable: initialIsAvailable,
         ),
       );

  void toggleAmenity(String label) {
    final next = Set<String>.from(state.activeAmenities);
    if (next.contains(label)) {
      next.remove(label);
    } else {
      next.add(label);
    }
    emit(state.copyWith(activeAmenities: next));
  }

  Future<String?> pickImages() async {
    if (state.imageUrls.length >= maxImages) {
      return 'Mỗi phòng chỉ được tối đa $maxImages ảnh.';
    }

    final files = await _imagePickerService.pickMultipleImages();
    if (files.isEmpty) return null;

    final currentImages = List<String>.from(state.imageUrls);
    for (var file in files) {
      if (currentImages.length < maxImages) {
        currentImages.add(file.path);
      }
    }
    emit(state.copyWith(imageUrls: currentImages));
    return null;
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= state.imageUrls.length) return;
    final next = [...state.imageUrls]..removeAt(index);
    emit(state.copyWith(imageUrls: next));
  }

  void clearErrors() {
    if (state.showErrors) emit(state.copyWith(showErrors: false));
  }

  void updateAvailability(bool value) {
    emit(state.copyWith(isAvailable: value));
  }

  RoomModel? validateAndCreate({
    required String name,
    required String location,
    required String price,
    required String deposit,
    required String area,
    required String occupancy,
    RoomModel? identity,
  }) {
    final isTextValid =
        name.isNotEmpty &&
        location.isNotEmpty &&
        price.isNotEmpty &&
        deposit.isNotEmpty &&
        area.isNotEmpty &&
        occupancy.isNotEmpty;

    final isImagesValid = state.imageUrls.length >= minImages;

    if (!isTextValid || !isImagesValid) {
      emit(state.copyWith(showErrors: true));
      return null;
    }

    final now = DateTime.now();
    return RoomModel(
      roomId: identity?.roomId ?? '',
      propertyId: identity?.propertyId ?? '',
      roomName: name,
      roomLocation: location,
      price: int.tryParse(price) ?? 0,
      priceDeposit: int.tryParse(deposit) ?? 0,
      area: double.tryParse(area) ?? 0,
      maxTenants: int.tryParse(occupancy) ?? 0,
      amenities: state.activeAmenities.map((labelName) {
        final matchedOption = PropertyConstants.roomAmenities.firstWhere(
          (opt) => opt.label == labelName,
        );
        return RoomAmenity(matchedOption.emoji, labelName);
      }).toList(),
      imageUrls: state.imageUrls,
      isAvailable: state.isAvailable,
      createdAt: identity?.createdAt ?? now,
      updatedAt: now,
    );
  }
}
