import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart' show XFile;

class StorageServices {
  static final _storage = FirebaseStorage.instance;
  static final _random = Random();

  // ==========================================
  // HÀM 1: BẮN 1 ẢNH LÊN FIREBASE
  // ==========================================
  static Future<String?> uploadSingleImage(File file, String folderPath) async {
    try {
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}.jpg';
      final ref = _storage.ref().child('$folderPath/$fileName');
      
      // Đẩy file lên
      await ref.putFile(file);
      
      // Trả về cái Link tải (URL) để lát lưu vào Firestore
      return await ref.getDownloadURL();
    } catch (e) {
      log('Lỗi upload ảnh: $e');
      return null;
    }
  }

  static Future<String?> _uploadJpegBytes(
    Uint8List bytes,
    String folderPath,
  ) async {
    try {
      if (bytes.isEmpty) return null;
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}.jpg';
      final ref = _storage.ref().child('$folderPath/$fileName');
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (e) {
      log('Lỗi upload ảnh (bytes): $e');
      return null;
    }
  }
  // ==========================================
  // HÀM 2: TRÙM CUỐI - CHIA CỤM UPLOAD ĐẠI TRÀ (SIÊU TỐC)
  // ==========================================
  static Future<List<String>> uploadMultipleImagesBatched({
    required List<File> imageFiles,
    required String folderPath,
    int batchSize = 5, // Mỗi lần đẩy 5 cụm cùng lúc
  }) async {
    List<String> downloadUrls = [];

    // Cắt nhỏ danh sách ảnh ra thành từng cụm
    for (int i = 0; i < imageFiles.length; i += batchSize) {
      // Lấy ra cụm ảnh của đợt này
      final chunk = imageFiles.skip(i).take(batchSize).toList();

      // Bê nguyên cục ảnh đã mượt sẵn đẩy thẳng lên Firebase (chạy song song)
      final urls = await Future.wait(
        chunk.map((file) => uploadSingleImage(file, folderPath)),
      );

      // Gom link thành công vào giỏ (lọc bỏ các link null nếu có lỗi)
      downloadUrls.addAll(urls.whereType<String>());
    }

    // Trả về danh sách link Firebase gọn gàng
    return downloadUrls;
  }

  /// Giữ nguyên URL remote; upload file cục bộ qua [File] hoặc [XFile] (Android content://).
  ///
  /// [localPathDedupeCache]: nếu có, các đường dẫn local trùng (cùng chuỗi sau trim) chỉ upload một lần;
  /// các lần sau tái dùng URL đã có (tiết kiệm Storage khi nhiều phòng dùng chung ảnh local).
  static Future<List<String>> uploadMixedPaths({
    required List<String> pathsOrUrls,
    required String folderPath,
    Map<String, String>? localPathDedupeCache,
  }) async {
    final result = <String>[];
    for (final raw in pathsOrUrls) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final lower = trimmed.toLowerCase();
      if (lower.startsWith('http://') || lower.startsWith('https://')) {
        result.add(trimmed);
        continue;
      }

      final cache = localPathDedupeCache;
      if (cache != null && cache.containsKey(trimmed)) {
        result.add(cache[trimmed]!);
        continue;
      }

      final file = File(trimmed);
      if (await file.exists()) {
        final url = await uploadSingleImage(file, folderPath);
        if (url != null) {
          result.add(url);
          cache?[trimmed] = url;
        }
        continue;
      }
      try {
        final bytes = await XFile(trimmed).readAsBytes();
        final url = await _uploadJpegBytes(bytes, folderPath);
        if (url != null) {
          result.add(url);
          cache?[trimmed] = url;
        }
      } catch (e) {
        log('Không upload được ảnh local ($trimmed): $e');
      }
    }
    return result;
  }
  static bool _looksLikeFirebaseStorageDownloadUrl(String url) {
    final u = url.trim().toLowerCase();
    return u.contains('firebasestorage.googleapis.com') ||
        u.contains('firebasestorage.app');
  }

  /// Xóa object trên Firebase Storage nếu [url] là link download của bucket (Firebase SDK).
  static Future<void> deleteDownloadUrlIfFirebaseStorage(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty || !_looksLikeFirebaseStorageDownloadUrl(trimmed)) {
      return;
    }
    try {
      await _storage.refFromURL(trimmed).delete();
      log('Đã xóa ảnh trên Firebase Storage');
    } catch (e) {
      log('Bỏ qua xóa ảnh Storage: $e');
    }
  }

  /// URL có trong [previousUrls] nhưng không còn trong [nextUrls] → xóa trên Storage (chỉ URL Firebase).
  static Future<void> syncDeletedFirebaseImages({
    required Iterable<String> previousUrls,
    required Iterable<String> nextUrls,
  }) async {
    final nextSet =
        nextUrls.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
    for (final prev in previousUrls) {
      final p = prev.trim();
      if (p.isEmpty || nextSet.contains(p)) continue;
      await deleteDownloadUrlIfFirebaseStorage(p);
    }
  }
}