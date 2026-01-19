import 'package:diacritic/diacritic.dart';

String normalizeText(String text) {
  String normalized = removeDiacritics(text);

  normalized = normalized.toLowerCase();

  normalized = normalized.replaceAll(RegExp(r'[_-]+'), ' ');

  normalized = normalized.trim().replaceAll(RegExp(r'\s+'), ' ');


  return normalized;
}
