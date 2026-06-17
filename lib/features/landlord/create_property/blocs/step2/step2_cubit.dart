import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/property_constants.dart';
import 'step2_state.dart';

class Step2Cubit extends Cubit<Step2State> {
  Step2Cubit({
    Set<String> initialAmenities = const <String>{},
    Set<String> initialRules = const {RuleKeys.freeTime},
    List<String> initialImages = const <String>[],
    String initialCurfew = '',
    String initialRuleNotes = '',
  }) : super(
         Step2State(
           activeAmenities: Set<String>.from(initialAmenities),
           activeRules: Set<String>.from(initialRules),
           imageUrls: List<String>.from(initialImages),
           curfew: initialCurfew,
           ruleNotes: initialRuleNotes,
         ),
       );

  void toggleAmenity(String label) {
    final next = Set<String>.from(state.activeAmenities);
    if (next.contains(label)) {
      next.remove(label);
    } else {
      next.add(label);
    }
    emit(state.copyWith(activeAmenities: next));
  }

  void toggleRule(String key) {
    final next = Set<String>.from(state.activeRules);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    emit(state.copyWith(activeRules: next));
  }

  void updateCurfew(String value) => emit(state.copyWith(curfew: value));

  void updateRuleNotes(String value) => emit(state.copyWith(ruleNotes: value));

  void addImage(String url) {
    if (state.imageUrls.length >= Step2State.maxImages) return;
    emit(state.copyWith(imageUrls: [...state.imageUrls, url]));
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= state.imageUrls.length) return;
    final next = [...state.imageUrls]..removeAt(index);
    emit(state.copyWith(imageUrls: next));
  }

  void markShowErrors() => emit(state.copyWith(showErrors: true));

  void reset() => emit(Step2State(
        activeAmenities: const <String>{},
        activeRules: const {RuleKeys.freeTime},
        imageUrls: const <String>[],
      ));
}
