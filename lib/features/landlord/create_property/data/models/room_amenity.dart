class RoomAmenity {
  const RoomAmenity(this.emoji, this.label);
  final String emoji;
  final String label;

  Map<String, dynamic> toMap() {
    return {
      'emoji': emoji,
      'label': label,
    };
  }

  factory RoomAmenity.fromMap(Map<String, dynamic> map) {
    return RoomAmenity(
      map['emoji'] ?? '',
      map['label'] ?? '',
    );
  }
}