class AmenityOption {
  const AmenityOption({
    this.key,
    required this.emoji,
    required this.label,
    this.initiallyActive = false,
    this.inactiveEmoji,
    this.inactiveLabel,
  });

  final String? key;

  final String emoji;
  final String label;
  final bool initiallyActive;

  final String? inactiveEmoji;
  final String? inactiveLabel;

  String displayEmoji(bool active) {
    return active ? emoji : (inactiveEmoji ?? emoji);
  }

  String displayLabel(bool active) {
    return active ? label : (inactiveLabel ?? label);
  }
}