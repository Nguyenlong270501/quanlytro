import 'package:diacritic/diacritic.dart';


String normalizeVietnameseForSearch(String input) =>
    removeDiacritics(input.toLowerCase()).trim();


bool vietnameseContainsNormalized(String haystack, String needle) {
  final n = normalizeVietnameseForSearch(needle);
  if (n.isEmpty) return true;
  final h = normalizeVietnameseForSearch(haystack);
  return h.contains(n);
}
