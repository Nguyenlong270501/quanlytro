import 'dart:developer';

import '../../features/landlord/create_property/data/models/pending_property_update.dart';
import 'storage_services.dart';

class PendingStorageCleanup {
  const PendingStorageCleanup._();

  static List<String> collectImageUrls(PendingPropertyUpdate? pending) {
    if (pending == null) return const [];
    final urls = <String>{};

    void addFromMap(Map<String, dynamic> map) {
      for (final value in map.values) {
        if (value is List) {
          for (final item in value) {
            final url = item?.toString().trim() ?? '';
            if (url.isNotEmpty) {
              urls.add(url);
            }
          }
        }
      }
    }

    addFromMap(pending.data);
    for (final room in pending.roomChanges.values) {
      addFromMap(room);
    }
    for (final room in pending.roomCreates) {
      addFromMap(room);
    }

    return urls.toList(growable: false);
  }

  static Future<void> deleteUrls(Iterable<String> urls) async {
    for (final url in urls) {
      try {
        await StorageServices.deleteDownloadUrlIfFirebaseStorage(url);
      } catch (e, stackTrace) {
        log('PendingStorageCleanup delete failed', error: e, stackTrace: stackTrace);
      }
    }
  }

  static Future<void> deleteUnusedOnOverwrite({
    required PendingPropertyUpdate? oldPending,
    required PendingPropertyUpdate newPending,
  }) async {
    final oldUrls = collectImageUrls(oldPending).toSet();
    final newUrls = collectImageUrls(newPending).toSet();
    final toDelete = oldUrls.difference(newUrls);
    await deleteUrls(toDelete);
  }
}
