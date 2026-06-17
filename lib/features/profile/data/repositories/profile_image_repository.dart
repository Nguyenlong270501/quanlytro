import 'package:image_picker/image_picker.dart';

abstract class ProfileImageRepository {
  Future<XFile?> pickImageFromGallery();

  /// Sao chép ảnh đã chọn vào thư mục cache app để preview trước khi upload.
  Future<String> copyImageToCache(XFile imageFile);

  Future<String> uploadAvatarAndSaveUrl(XFile imageFile);

  Future<void> updateProfileInfo({
    required String userName,
    required String phoneNumber,
  });
}
