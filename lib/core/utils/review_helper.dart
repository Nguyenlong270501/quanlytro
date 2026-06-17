import '../constants/property_constants.dart';
import '../services/local_location_service.dart';
import '../../features/landlord/create_property/blocs/step1/step1_state.dart';
import '../../features/landlord/create_property/blocs/step2/step2_state.dart';
import '../../features/landlord/create_property/data/models/room_model.dart';

class ReviewHelper {
  // --- FORMAT CHUNG ---
  static String orPlaceholder(String? value, String placeholder) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? placeholder : trimmed;
  }

  static String formatPrice(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String formatFeePerUnit(String rawValue, String suffix) {
    final value = int.tryParse(rawValue) ?? 0;
    return '${formatPrice(value)} $suffix';
  }

  // --- LOGIC STEP 1 ---
  static String buildAddress(Step1State s) {
    final wardLabel = LocalLocationService().wardDisplayName(
      city: s.city,
      value: s.ward,
    );
    final parts = <String>[
      if (s.street.trim().isNotEmpty) s.street.trim(),
      if (wardLabel.isNotEmpty) wardLabel,
      if ((s.city ?? '').isNotEmpty) s.city!,
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    if (s.pinnedAddress.trim().isNotEmpty) return s.pinnedAddress.trim();
    if (s.isLocationPinned) {
      return '${s.latitude!.toStringAsFixed(6)}, ${s.longitude!.toStringAsFixed(6)}';
    }
    return 'Chưa ghim vị trí / chưa có địa chỉ chi tiết.';
  }

  // --- LOGIC STEP 2 ---
static List<Map<String, String>> getAmenities(
  Step2State s,
) {
  final chips = <Map<String, String>>[];

  for (final label in s.activeAmenities) {
    final option = PropertyConstants.amenities
        .where((a) => a.label == label)
        .firstOrNull;

    chips.add({
      'emoji': option?.emoji ?? '✅',
      'label': label,
    });
  }

  return chips;
}

static List<Map<String, String>> getRules(
  Step2State s,
) {
  final chips = <Map<String, String>>[];

  for (final option in PropertyConstants.rentalRules) {
    final isActive = s.activeRules.contains(option.key);

    chips.add({
      'emoji': option.displayEmoji(isActive),
      'label': option.displayLabel(isActive),
    });
  }

  if (!s.activeRules.contains(RuleKeys.freeTime) &&
      s.curfew.trim().isNotEmpty) {
    chips.add({
      'emoji': '🕛',
      'label': 'Đóng cửa ${s.curfew}',
    });
  }

  return chips;
}



  // --- LOGIC STEP 3 ---

static (String, String) priceRangeLabel(List<RoomModel> rooms) {
  if (rooms.isEmpty) return ('Giá: ', '—');
  final prices = rooms.map((r) => r.price).toList(); 
  final minPrice = prices.reduce((a, b) => a < b ? a : b);
  final maxPrice = prices.reduce((a, b) => a > b ? a : b);

  String toTrieu(int p) {
    double trieu = p / 1000000;
    return trieu == trieu.toInt()
        ? trieu.toInt().toString()
        : trieu.toString().replaceAll('.', ',');
  }

  if (minPrice == maxPrice) {
    return ('Giá: ', '${toTrieu(minPrice)} triệu/tháng');
  } else {
    return ('Giá từ: ', '${toTrieu(minPrice)} đến ${toTrieu(maxPrice)} triệu/tháng');
  }
}

  static String buildDepositLabel(int firstRoomDeposit) {
    if (firstRoomDeposit <= 0) return 'Không yêu cầu cọc';

    return '${formatPrice(firstRoomDeposit)} đ';
  }

  static String formatAreaLabel(String area) {
    if (area.trim().isEmpty) return '—';
    final cleanArea = area.replaceAll(RegExp(r'\.0*$'), '');
    return '$cleanArea m2';
  }
}
