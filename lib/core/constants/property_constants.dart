import '../../features/landlord/create_property/data/models/amenity_option.dart';

class RuleKeys {
  static const String noShared = 'no_shared';
  static const String allowPet = 'allow_pet';
  static const String freeTime = 'free_time';
  static const String electricBike = 'electric_bike';
}

class PropertyConstants {
  static const List<String> propertyTypes = [
    'Phòng trọ bình dân',
    'Chung cư mini',
    'Căn hộ Studio',
    'Ký túc xá / Ở ghép',
    'Nhà nguyên căn / Căn hộ chung cư',
  ];

  static const List<String> cities = ['Hà Nội', 'TP. HCM'];

  static const List<AmenityOption> amenities = [
    AmenityOption(emoji: '🛜', label: 'Wifi Free', initiallyActive: true),
    AmenityOption(emoji: '🅿️', label: 'Bãi để xe', initiallyActive: true),
    AmenityOption(emoji: '🛗', label: 'Thang máy'),
    AmenityOption(emoji: '📹', label: 'Camera 24/7', initiallyActive: true),
    AmenityOption(emoji: '🧺', label: 'Máy giặt chung'),
    AmenityOption(emoji: '🚿', label: 'Nhà tắm riêng'),
  ];

  static const List<AmenityOption> rentalRules = [
    AmenityOption(
      key: RuleKeys.noShared,
      emoji: '🗝️',
      label: 'Không chung chủ',
      inactiveEmoji: '🏠',
      inactiveLabel: 'Chung chủ',
    ),

    AmenityOption(
      key: RuleKeys.allowPet,
      emoji: '🐾',
      label: 'Cho nuôi Pet',
      inactiveEmoji: '🚫',
      inactiveLabel: 'Không nuôi Pet',
    ),

    AmenityOption(
      key: RuleKeys.freeTime,
      emoji: '🕛',
      label: 'Giờ giấc tự do',
      inactiveEmoji: '⏰',
      inactiveLabel: 'Giờ giấc giới hạn',
    ),

    AmenityOption(
      key: RuleKeys.electricBike,
      emoji: '🛵',
      label: 'Cho để xe điện',
      inactiveEmoji: '🚳',
      inactiveLabel: 'Không để xe điện',
    ),
  ];

  static const List<AmenityOption> roomAmenities = [
    AmenityOption(emoji: '❄️', label: 'Điều hòa', initiallyActive: true),
    AmenityOption(emoji: '🚿', label: 'Nóng lạnh', initiallyActive: true),
    AmenityOption(emoji: '🛏️', label: 'Giường nệm'),
    AmenityOption(emoji: '🧺', label: 'Máy giặt riêng'),
    AmenityOption(emoji: '🧊', label: 'Tủ lạnh'),
    AmenityOption(emoji: '🍳', label: 'Kệ bếp', initiallyActive: true),
    AmenityOption(emoji: '🪟', label: 'Cửa sổ'),
    AmenityOption(emoji: '🪜', label: 'Gác xép'),
    AmenityOption(emoji: '🌅', label: 'Ban công'),
    AmenityOption(emoji: '🍳', label: 'Bếp'),
    AmenityOption(emoji: '🚪', label: 'Tủ quần áo'),
  ];
}
