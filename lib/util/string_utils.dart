import 'package:characters/characters.dart';

import 'package:rogers_dictionary/util/collection_utils.dart';
import 'package:rogers_dictionary/util/overflow_markdown_base.dart';

extension NotShittyString on String {
  static const diacritics =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÝÿýŽž';
  static const nonDiacritics =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYYyyZz';

  static const badSpanishDiacritics = [
    'á',
    'Á',
    'é',
    'É',
    'í',
    'Í',
    'ó',
    'Ó',
    'ú',
    'Ú',
    'ý',
    'Ý',
    'ñ',
    'Ñ',
    'ü',
    'Ü',
    'ö',
    'Ö',
  ];

  static const goodSpanishDiacritics = [
    'á',
    'Á',
    'é',
    'É',
    'í',
    'Í',
    'ó',
    'Ó',
    'ú',
    'Ú',
    'ý',
    'Ý',
    'ñ',
    'Ñ',
    'ü',
    'Ü',
    'ö',
    'Ö',
  ];

  static const List<String> symbols = [
    '(',
    ')',
    '*',
    '`',
  ];

  static const COMBINING_ACCENT_CODE = 769;
  static const COMBINING_TILDE_CODE = 771;
  static const COMBINING_UMLAUT_CODE = 776;
  static const COMBINING_CODES = [
    COMBINING_ACCENT_CODE,
    COMBINING_TILDE_CODE,
    COMBINING_UMLAUT_CODE,
  ];

  /// Replace combining-character diacritics with single character diacritics.
  ///
  /// Limited in scope to just the spanish characters.
  String get standardizeSpanishDiacritics {
    return characters.map((c) {
      if (badSpanishDiacritics.contains(c)) {
        return goodSpanishDiacritics[badSpanishDiacritics.indexOf(c)];
      }
      return c;
    }).join();
  }

  String get withoutDiacriticalMarks {
    return splitMapJoin('', onNonMatch: (char) {
      if (char.isEmpty) {
        // We need to short circuit so the following checks don't break.
        return char;
      }
      if (diacritics.contains(char)) {
        return nonDiacritics[diacritics.indexOf(char)];
      }
      if (COMBINING_CODES.contains(char.codeUnits.single)) {
        // Remove the combining code.
        return '';
      }
      return char;
    });
  }

  String get searchable => toLowerCase().withoutDiacriticalMarks.splitMapJoin(
        '',
        onNonMatch: (char) => symbols.contains(char) ? '' : char,
      );

  String get withoutOptionals => replaceAll(RegExp(r'\(.*?\) ?'), '').trim();

  String get withoutHyphenateds => replaceAll(RegExp(r' -.[^ ]+'), '').trim();

  String get withoutAsterisks => replaceAll(RegExp(r'\\\*'), '').trim();

  String get withoutGenderIndicators =>
      replaceAll(RegExp(r' \*([mf]{1,2}|mpl|fpl|m&f|mpl&fpl)\* '), ' ').trim();

  String get pronounceable =>
      withoutHyphenateds.withoutGenderIndicators.withoutAsterisks;

  String? get emptyToNull => isNotEmpty ? this : null;

  List<String> get splitItalicized => MarkdownBase(this).strip(italics: true);

  String get capitalizeFirst => split('')
      .asMap()
      .mapDown((i, c) => i == 0 ? c.toUpperCase() : c)
      .join('');

  String get enumString => split('.').last;

  String get feminized => splitMapJoin(
        ' ',
        onNonMatch: (word) => word.replaceAll(RegExp('o\$'), 'a'),
      );

  String spanishAdjectiveReorder(String nounToReorder) => replaceAllMapped(
        RegExp('(.*) $nounToReorder'),
        (match) => '$nounToReorder ${match.group(1)}',
      );

  String truncated(int maxLength) =>
      length > maxLength - 3 ? '${split('').take(maxLength).join()}...' : this;
}
