import '../../features/landlord/create_property/data/models/property_model.dart';
import '../../features/landlord/create_property/data/models/room_amenity.dart';
import '../../features/landlord/create_property/data/models/room_model.dart';
import '../services/local_location_service.dart';

class PropertyHelper {
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

  /// Định dạng giá kèm đơn vị (Ví dụ: 3.000.000 đ/tháng)
  static String formatFeePerUnit(String rawValue, String suffix) {
    final value = int.tryParse(rawValue) ?? 0;
    return '${formatPrice(value)} $suffix';
  }

  // --- 2. XỬ LÝ ĐỊA CHỈ (Đã chuyển từ HomeScreen sang) ---

  /// Trả về chuỗi địa chỉ rút gọn: "Phường/Xã, Quận/Huyện"
  static String propertyLocationSubtitle(PropertyModel p) {
    final street = p.streetAddress.trim();
    final ward = _wardDisplayName(p);
    final city = p.city.trim();
    if (ward.isEmpty && city.isEmpty && street.isEmpty) return '';
    if (ward.isEmpty && city.isEmpty) return street;
    if (ward.isEmpty) return city;
    if (city.isEmpty) return ward;
    return '$street, $ward, $city';
  }

  /// Trả về địa chỉ dự phòng cho phòng: "Đường, Phường" hoặc "Thành phố"
  static String roomFallbackLocation(RoomModel room, PropertyModel p) {
    final street = p.streetAddress.trim();
    final ward = _wardDisplayName(p);
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (ward.isNotEmpty) parts.add(ward);
    if (parts.isEmpty) return p.city.trim();
    return parts.join(', ');
  }

  static String _wardDisplayName(PropertyModel p) {
    return LocalLocationService().wardDisplayName(city: p.city, value: p.ward);
  }

  static List<RoomAmenity> getAmenitiesAndRules(PropertyModel property) {
    final chips = <RoomAmenity>[];
    for (final label in property.facilities ?? []) {
      chips.add(RoomAmenity('✅', label));
    }

    // Quét nội quy quan trọng
    final rules = property.rules ?? [];

    if (rules.contains('noShared')) {
      // Thay bằng RuleKeys.noShared nếu có
      chips.add(const RoomAmenity('🗝️', 'Không chung chủ'));
    }
    if (rules.contains('allowPet')) {
      // Thay bằng RuleKeys.allowPet nếu có
      chips.add(const RoomAmenity('🐾', 'Cho nuôi Pet'));
    }

    // Xử lý giờ giấc
    if (rules.contains('freeTime')) {
      chips.add(const RoomAmenity('🕛', 'Giờ giấc tự do'));
    } else if (property.curfewTime != null &&
        property.curfewTime!.trim().isNotEmpty) {
      chips.add(RoomAmenity('🕛', 'Đóng cửa ${property.curfewTime}'));
    }

    if (rules.contains('electricBike')) {
      chips.add(const RoomAmenity('🛵', 'Cho để xe điện'));
    }

    return chips;
  }

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
      return (
        'Giá từ: ',
        '${toTrieu(minPrice)} đến ${toTrieu(maxPrice)} triệu/tháng',
      );
    }
  }

  /// Định dạng nhãn tiền cọc
  static String buildDepositLabel(int firstRoomDeposit) {
    if (firstRoomDeposit <= 0) return 'Không yêu cầu cọc';
    return '${formatPrice(firstRoomDeposit)} đ';
  }

  /// Định dạng diện tích (Ví dụ: 25.0 -> 25 m2)
  static String formatAreaLabel(String area) {
    if (area.trim().isEmpty) return '—';
    final cleanArea = area.replaceAll(RegExp(r'\.0*$'), '');
    return '$cleanArea m2';
  }

  /// Định dạng thời gian đăng bài (Ví dụ: "Đăng 3 giờ trước")
  static String formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  /// Thâm niên hiển thị trên card chủ nhà (ví dụ: `13 tháng`, hoặc `Dưới 1 tháng`).
  static String landlordHostingTenureLabel(DateTime memberSince) {
    final diff = DateTime.now().difference(memberSince).inDays;
    if (diff < 30) return 'Dưới 1 tháng';
    final months = diff ~/ 30;
    return '$months tháng';
  }

  static const Duration newListingMaxAge = Duration(days: 7);

  static bool isNewListing(
    DateTime createdAt, {
    Duration maxAge = newListingMaxAge,
  }) {
    final age = DateTime.now().difference(createdAt);

    return age < maxAge;
  }
}
