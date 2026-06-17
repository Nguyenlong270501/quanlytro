import 'package:equatable/equatable.dart';
import '../../../../../core/constants/property_constants.dart';

class Step2State extends Equatable {
  static const int minImages = 1;
  static const int maxImages = 5;

  const Step2State({
    this.activeAmenities = const <String>{},
    this.activeRules = const {RuleKeys.freeTime},
    this.curfew = '',
    this.ruleNotes = '',
    this.imageUrls = const <String>[],
    this.showErrors = false,
  });

  final Set<String> activeAmenities;
  final Set<String> activeRules;
  final String curfew;
  final String ruleNotes;
  final List<String> imageUrls;

  final bool showErrors;

  bool get isFreeTime => activeRules.contains(RuleKeys.freeTime);
  bool get isCurfewValid => isFreeTime || curfew.trim().isNotEmpty;
  // bool get isImagesValid => imageUrls.length >= minImages;

  bool get isValid => isCurfewValid;

  Step2State copyWith({
    Set<String>? activeAmenities,
    Set<String>? activeRules,
    String? curfew,
    String? ruleNotes,
    List<String>? imageUrls,
    bool? showErrors,
  }) {
    return Step2State(
      activeAmenities: activeAmenities ?? this.activeAmenities,
      activeRules: activeRules ?? this.activeRules,
      curfew: curfew ?? this.curfew,
      ruleNotes: ruleNotes ?? this.ruleNotes,
      imageUrls: imageUrls ?? this.imageUrls,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [
    activeAmenities,
    activeRules,
    curfew,
    ruleNotes,
    imageUrls,
    showErrors,
  ];
}
