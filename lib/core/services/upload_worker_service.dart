import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/landlord/create_property/data/datasources/property_update_data_source_impl.dart';
import '../../features/landlord/create_property/data/models/pending_property_update.dart';
import '../../features/landlord/create_property/data/models/property_model.dart';
import '../../features/landlord/create_property/data/models/room_model.dart';
import '../../features/landlord/create_property/data/repositories/create_property_repository.dart';
import '../utils/upload_queue_sanitize.dart';
import 'pending_storage_cleanup.dart';
import 'storage_services.dart';

class UploadWorkerService {
  static const String _boxName = 'upload_queue';

  static void _clearRamImageCache() {
    try {
      imageCache.clear();
      imageCache.clearLiveImages();
    } catch (_) {}
  }

  static Future<Directory> _ensurePendingSafeDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final safeDir = Directory(p.join(appDir.path, 'pending_properties'));
    if (!await safeDir.exists()) {
      await safeDir.create(recursive: true);
    }
    return safeDir;
  }

  static bool _isRemoteUrl(String path) {
    final lower = path.trim().toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  static Future<String> _moveToSafeZone({
    required String originalPath,
    required Directory safeDir,
    required Map<String, String> safePathCache,
  }) async {
    final trimmedPath = originalPath.trim();
    if (trimmedPath.isEmpty || _isRemoteUrl(trimmedPath)) {
      return trimmedPath;
    }

    final cachedSafePath = safePathCache[trimmedPath];
    if (cachedSafePath != null) {
      return cachedSafePath;
    }

    final file = File(trimmedPath);
    if (!await file.exists()) {
      return trimmedPath;
    }

    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_${p.basename(trimmedPath)}';
    final safePath = p.join(safeDir.path, fileName);
    await file.copy(safePath);
    safePathCache[trimmedPath] = safePath;
    return safePath;
  }

  static Future<List<String>> _moveImageUrlsToSafeZone({
    required Iterable<String> imageUrls,
    required Directory safeDir,
    required Map<String, String> safePathCache,
  }) async {
    final safeUrls = <String>[];
    for (final imageUrl in imageUrls) {
      safeUrls.add(
        await _moveToSafeZone(
          originalPath: imageUrl,
          safeDir: safeDir,
          safePathCache: safePathCache,
        ),
      );
    }
    return safeUrls;
  }

  static Future<void> saveDraftToQueue({
    required Map<String, dynamic> propertyData,
    required List<Map<String, dynamic>> roomsData,
    Map<String, dynamic>? editSyncMeta,
  }) async {
    final box = await Hive.openBox(_boxName);

    final safeDir = await _ensurePendingSafeDir();
    final safePathCache = <String, String>{};

    final propForQueue = Map<String, dynamic>.from(propertyData);
    final roomsForQueue = roomsData
        .map((r) => Map<String, dynamic>.from(r))
        .toList();

    if (propForQueue['imageUrls'] != null) {
      final oldUrls = List<String>.from(propForQueue['imageUrls']);
      final safeUrls = await _moveImageUrlsToSafeZone(
        imageUrls: oldUrls,
        safeDir: safeDir,
        safePathCache: safePathCache,
      );
      propForQueue['imageUrls'] = safeUrls;
    }

    for (final room in roomsForQueue) {
      if (room['imageUrls'] != null) {
        final oldUrls = List<String>.from(room['imageUrls']);
        final safeUrls = await _moveImageUrlsToSafeZone(
          imageUrls: oldUrls,
          safeDir: safeDir,
          safePathCache: safePathCache,
        );
        room['imageUrls'] = safeUrls;
      }
    }

    final sanitizedProperty = Map<String, dynamic>.from(
      sanitizeForFirestoreMapForHive(propForQueue) as Map,
    );
    final sanitizedRooms = roomsForQueue
        .map(
          (r) => Map<String, dynamic>.from(
            sanitizeForFirestoreMapForHive(r) as Map,
          ),
        )
        .toList();

    final draft = <String, dynamic>{
      'property': sanitizedProperty,
      'rooms': sanitizedRooms,
      if (editSyncMeta != null)
        'editSyncMeta': sanitizeForFirestoreMapForHive(editSyncMeta),
    };

    await box.add(draft);
    log('Đã ném vào hàng đợi Hive! (Kho đang có ${box.length} bài chờ up)');
  }

  static Future<void> saveModerationEditToQueue({
    required String propertyId,
    required Map<String, dynamic> autoPropertyPatch,
    required Map<String, Map<String, dynamic>> autoRoomChanges,
    required PendingPropertyUpdate pendingUpdate,
    PendingPropertyUpdate? previousPending,
  }) async {
    final box = await Hive.openBox(_boxName);
    final safeDir = await _ensurePendingSafeDir();
    final safePathCache = <String, String>{};

    final pendingMap = Map<String, dynamic>.from(pendingUpdate.toHiveMap());
    await _moveLocalImagesInPendingMap(
      pendingMap,
      (path) => _moveToSafeZone(
        originalPath: path,
        safeDir: safeDir,
        safePathCache: safePathCache,
      ),
    );

    final draft = <String, dynamic>{
      'moderationEdit': true,
      'propertyId': propertyId,
      'autoPropertyPatch': sanitizeForFirestoreMapForHive(autoPropertyPatch),
      'autoRoomChanges': sanitizeForFirestoreMapForHive(autoRoomChanges),
      'pendingUpdate': sanitizeForFirestoreMapForHive(pendingMap),
      if (previousPending != null)
        'previousPendingUpdate': sanitizeForFirestoreMapForHive(
          previousPending.toHiveMap(),
        ),
    };

    await box.add(draft);
    log('Đã queue chỉnh sửa moderation ($propertyId)');
  }

  static Future<void> _moveLocalImagesInPendingMap(
    Map<String, dynamic> pendingRoot,
    Future<String> Function(String path) moveToSafeZone,
  ) async {
    final data = pendingRoot['data'];
    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      await _moveLocalImagesInFieldMap(dataMap, moveToSafeZone);
      pendingRoot['data'] = dataMap;
    }

    final roomChanges = pendingRoot['roomChanges'];
    if (roomChanges is Map) {
      for (final entry in roomChanges.entries) {
        if (entry.value is Map) {
          final roomMap = Map<String, dynamic>.from(entry.value as Map);
          await _moveLocalImagesInFieldMap(roomMap, moveToSafeZone);
          roomChanges[entry.key] = roomMap;
        }
      }
    }

    final roomCreates = pendingRoot['roomCreates'];
    if (roomCreates is List) {
      for (var i = 0; i < roomCreates.length; i++) {
        if (roomCreates[i] is Map) {
          final roomMap = Map<String, dynamic>.from(roomCreates[i] as Map);
          await _moveLocalImagesInFieldMap(roomMap, moveToSafeZone);
          roomCreates[i] = roomMap;
        }
      }
    }
  }

  static Future<void> _moveLocalImagesInFieldMap(
    Map<String, dynamic> map,
    Future<String> Function(String path) moveToSafeZone,
  ) async {
    final urls = map['imageUrls'];
    if (urls is! List) return;
    final safeUrls = <String>[];
    for (final url in urls) {
      safeUrls.add(await moveToSafeZone(url.toString()));
    }
    map['imageUrls'] = safeUrls;
  }

  static Future<void> checkAndUploadDraft(
    CreatePropertyRepository repository, {
    void Function(String propertyTitle)? onSuccess,
  }) async {
    final box = await Hive.openBox(_boxName);

    if (box.isEmpty) {
      log('Kho rỗng, công nhân ngồi chơi xơi nước.');
      return;
    }

    log('Phát hiện ${box.length} bài đang chờ! Bắt đầu làm việc...');

    final keys = box.keys.toList();

    for (var key in keys) {
      try {
        final draft = box.get(key);
        if (draft is Map && draft['moderationEdit'] == true) {
          await _processModerationDraft(draft);
          await box.delete(key);
          continue;
        }

        final propertyMap = Map<String, dynamic>.from(draft['property']);
        final roomsList = List<Map<dynamic, dynamic>>.from(
          draft['rooms'],
        ).map((e) => Map<String, dynamic>.from(e)).toList();

        Map<String, dynamic>? editSyncMeta;
        final rawMeta = draft['editSyncMeta'];
        if (rawMeta != null && rawMeta is Map) {
          editSyncMeta = Map<String, dynamic>.from(rawMeta);
        }

        String? propertyId = propertyMap['propertyId']?.toString();
        if (propertyId == null || propertyId.isEmpty || propertyId == 'null') {
          propertyId = FirebaseFirestore.instance
              .collection('properties')
              .doc()
              .id;
          propertyMap['propertyId'] = propertyId;
        }

        final propertyTitle = propertyMap['title'] ?? '';
        log('Đang xử lý ngầm bài: $propertyId');

        final pid = propertyId;

        final localImageDedupe = <String, String>{};

        final prevPropUrls = List<String>.from(
          editSyncMeta?['previousPropertyImageUrls'] as List? ?? [],
        );
        await StorageServices.syncDeletedFirebaseImages(
          previousUrls: prevPropUrls,
          nextUrls: List<String>.from(propertyMap['imageUrls'] ?? []),
        );

        final uploadedGeneralUrls = await StorageServices.uploadMixedPaths(
          pathsOrUrls: List<String>.from(propertyMap['imageUrls'] ?? []),
          folderPath: 'properties/$pid/general_images',
          localPathDedupeCache: localImageDedupe,
        );
        propertyMap['imageUrls'] = uploadedGeneralUrls;

        Map<String, List<String>> prevRoomUrlsById = {};
        final prevRoomsRaw = editSyncMeta?['previousRoomImages'];
        if (prevRoomsRaw is Map) {
          prevRoomsRaw.forEach((key, value) {
            if (key is String && value is List) {
              prevRoomUrlsById[key] = List<String>.from(value);
            }
          });
        }

        for (var room in roomsList) {
          String roomId = room['roomId']?.toString() ?? '';
          if (roomId.isEmpty || roomId == 'null') {
            roomId = FirebaseFirestore.instance
                .collection('properties')
                .doc()
                .id;
            room['roomId'] = roomId;
          }

          final prevRoomUrls = prevRoomUrlsById[roomId] ?? [];
          await StorageServices.syncDeletedFirebaseImages(
            previousUrls: prevRoomUrls,
            nextUrls: List<String>.from(room['imageUrls'] ?? []),
          );

          final uploadedRoomUrls = await StorageServices.uploadMixedPaths(
            pathsOrUrls: List<String>.from(room['imageUrls'] ?? []),
            folderPath: 'properties/$pid/rooms/$roomId',
            localPathDedupeCache: localImageDedupe,
          );
          room['imageUrls'] = uploadedRoomUrls;
        }

        final deletedRoomIds = _deletedRoomIdsFromEditMeta(editSyncMeta);
        final deletedRoomImagesRaw = editSyncMeta?['deletedRoomImages'];
        if (deletedRoomImagesRaw is Map) {
          for (final roomId in deletedRoomIds) {
            final urlsRaw = deletedRoomImagesRaw[roomId];
            final urls = urlsRaw is List
                ? List<String>.from(urlsRaw)
                : const <String>[];
            await StorageServices.syncDeletedFirebaseImages(
              previousUrls: urls,
              nextUrls: const [],
            );
          }
        }

        final propertyModel = PropertyModel.fromMap(propertyMap);
        final roomModels = roomsList.map((r) => RoomModel.fromMap(r)).toList();

        final result = await repository.createProperty(
          property: propertyModel,
          rooms: roomModels,
          deletedRoomIds: deletedRoomIds,
        );
        result.fold((message) => throw Exception(message), (_) {});

        await box.delete(key);
        log('Đã đăng tin ngầm THÀNH CÔNG bài $propertyId!');

        _cleanupSafeZoneFiles(localImageDedupe.keys);

        onSuccess?.call(propertyTitle);
      } catch (e) {
        log(
          'Lỗi up ngầm bài $key (Có thể do rớt mạng hoặc thiếu Permission): $e',
        );
        continue;
      }
    }

    _clearRamImageCache();
  }

  static Future<void> _processModerationDraft(Map draft) async {
    final propertyId = draft['propertyId']?.toString() ?? '';
    if (propertyId.isEmpty) {
      throw Exception('Thiếu propertyId trong moderation draft');
    }

    final pendingMap = Map<String, dynamic>.from(
      draft['pendingUpdate'] as Map? ?? const {},
    );
    final previousPendingRaw = draft['previousPendingUpdate'];
    final previousPending = previousPendingRaw is Map
        ? PendingPropertyUpdate.fromMap(
            Map<String, dynamic>.from(previousPendingRaw),
          )
        : null;

    final localImageDedupe = <String, String>{};
    await _uploadPendingImagesInMap(
      propertyId: propertyId,
      pendingRoot: pendingMap,
      dedupe: localImageDedupe,
    );

    final pendingUpdate = PendingPropertyUpdate.fromMap(pendingMap);
    final dataSource = PropertyUpdateDataSourceImpl();

    if (previousPending != null) {
      await PendingStorageCleanup.deleteUnusedOnOverwrite(
        oldPending: previousPending,
        newPending: pendingUpdate,
      );
    }

    await dataSource.setPendingUpdate(
      propertyId: propertyId,
      pendingUpdate: pendingUpdate,
    );

    _cleanupSafeZoneFiles(localImageDedupe.keys);
    log('Moderation edit queued upload done: $propertyId');
  }

  static Future<void> _uploadPendingImagesInMap({
    required String propertyId,
    required Map<String, dynamic> pendingRoot,
    required Map<String, String> dedupe,
  }) async {
    final data = pendingRoot['data'];
    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      await _uploadImageUrlsField(
        propertyId: propertyId,
        map: dataMap,
        folder: 'general_images',
        dedupe: dedupe,
      );
      pendingRoot['data'] = dataMap;
    }

    final roomChanges = pendingRoot['roomChanges'];
    if (roomChanges is Map) {
      for (final entry in roomChanges.entries) {
        if (entry.key is! String || entry.value is! Map) continue;
        final roomMap = Map<String, dynamic>.from(entry.value as Map);
        await _uploadImageUrlsField(
          propertyId: propertyId,
          map: roomMap,
          folder: 'rooms/${entry.key}',
          dedupe: dedupe,
        );
        roomChanges[entry.key] = roomMap;
      }
    }

    final roomCreates = pendingRoot['roomCreates'];
    if (roomCreates is List) {
      for (var i = 0; i < roomCreates.length; i++) {
        if (roomCreates[i] is! Map) continue;
        final roomMap = Map<String, dynamic>.from(roomCreates[i] as Map);
        await _uploadImageUrlsField(
          propertyId: propertyId,
          map: roomMap,
          folder: 'rooms/create_$i',
          dedupe: dedupe,
        );
        roomCreates[i] = roomMap;
      }
    }
  }

  static Future<void> _uploadImageUrlsField({
    required String propertyId,
    required Map<String, dynamic> map,
    required String folder,
    required Map<String, String> dedupe,
  }) async {
    final urls = map['imageUrls'];
    if (urls is! List || urls.isEmpty) return;
    map['imageUrls'] = await StorageServices.uploadMixedPaths(
      pathsOrUrls: List<String>.from(urls),
      folderPath: 'pending/$propertyId/$folder',
      localPathDedupeCache: dedupe,
    );
  }

  static List<String> _deletedRoomIdsFromEditMeta(
    Map<String, dynamic>? editSyncMeta,
  ) {
    final raw = editSyncMeta?['deletedRoomIds'];
    if (raw is! List) {
      return const [];
    }
    return raw
        .map((e) => e.toString().trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
  }

  static void _cleanupSafeZoneFiles(Iterable<String> localPaths) {
    for (final path in localPaths) {
      try {
        final file = File(path);
        if (file.existsSync() && path.contains('pending_properties')) {
          file.deleteSync();
        }
      } catch (_) {}
    }
  }
}
