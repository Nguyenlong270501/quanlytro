import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImageFromGallery() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
    );
  }

  Future<List<File>> pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1280,
    );
    return images.map((x) => File(x.path)).toList();
  }
}
