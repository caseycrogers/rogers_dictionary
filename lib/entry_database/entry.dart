import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'package:rogers_dictionary/util/string_utils.dart';

part 'entry.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Entry {
  // Run the following to rebuild generated files:
  // flutter pub run build_runner build --delete-conflicting-outputs
  final int entryId;
  final Headword headword;
  final List<String> related;
  final List<Headword> alternateHeadwords;

  final List<Translation> translations;

  Entry({
    required this.entryId,
    required this.headword,
    required this.related,
    required this.alternateHeadwords,
    required this.translations,
  });

  factory Entry.notFound(String headword) {
    print('WARN: Entry $headword not found');
    return Entry(
      entryId: -1,
      headword: Headword(
        isDominant: true,
        headwordText: 'Invalid headword ${urlDecode(headword)}',
        abbreviation: null,
        parentheticalQualifier: null,
        namingStandard: null,
      ),
      related: [],
      alternateHeadwords: [],
      translations: [
        Translation(
          partOfSpeech: '',
          irregularInflections: null,
          dominantHeadwordParentheticalQualifier: null,
          translationText:
              'Please use the feedback button (upper right) to report this bug.',
          genderAndPlural: null,
          translationNamingStandard: null,
          translationAbbreviation: null,
          translationParentheticalQualifier: null,
          examplePhrases: [],
          editorialNote: null,
        ),
      ],
    );
  }

  @JsonKey(ignore: true)
  static final Map<String, String> _partOfSpeechAbbreviationMap = {
    'adj': 'adjective',
    'adv': 'adverb',
    'conj': 'conjunction',
    'deg': 'degree',
    'f': 'feminine noun',
    'fpl': 'feminine plural noun',
    'f(pl)': 'feminine plural noun',
    'inf': 'infinitive',
    'interj': 'interjection',
    'm': 'masculine noun',
    'mf': 'masculine/feminine noun',
    'mpl': 'masculine plural noun',
    'm(pl)': 'masculine plural noun',
    'n': 'noun',
    'npl': 'plural noun',
    'n(pl)': 'plural noun',
    'pref': 'prefix',
    'prep': 'preposition',
    'v': 'verb',
    'vi': 'intransitive verb',
    'vr': 'reflexive verb',
    'vt': 'transitive verb',
    '-': 'phrase',
    '': '',
  };

  static String longPartOfSpeech(String partOfSpeech) {
    return partOfSpeech.replaceAll(' ', '').splitMapJoin(RegExp('[&,]|phrase'),
        onNonMatch: (partOfSpeechComponent) =>
            _partOfSpeechAbbreviationMap[partOfSpeechComponent] ??
            partOfSpeechComponent + '*',
        onMatch: (separator) {
          //  == '&' ? ' and ' : ', ',
          switch (separator.group(0)) {
            case '&':
              return ' and ';
            case ',':
              return ', ';
            case 'phrase':
              return ' phrase';
            default:
              return separator.group(0)!;
          }
        });
  }

  static String urlDecode(String urlEncodedHeadword) {
    return Uri.decodeComponent(
        (urlEncodedHeadword.split('_')..removeAt(0)).join(''));
  }

  static String urlEncode(String headword) {
    return Uri.encodeComponent(headword);
  }

  static String generateOrderByField(String headword, int entryId) {
    return entryId.toString().padLeft(4, '0') + '_' + urlEncode(headword);
  }

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  bool keyWordMatches(String searchTerm) {
    return _keywords().any((keyword) => keyword.contains(searchTerm));
  }

  Map<String, dynamic> toJson() => _$EntryToJson(this);

  Set<String> _keywords() => Set.from(allHeadwords.map((h) => h.headwordText))
    ..addAll(translations.map((e) => e.translationText));

  @override
  String toString() {
    return toJson().toString();
  }

  String get headwordText => headword.headwordText;

  String get urlEncodedHeadword => headword.urlEncodedHeadword;

  List<Headword> get allHeadwords => [headword]..addAll(alternateHeadwords);

  @override
  bool operator ==(o) => o is Entry && o.hashCode == hashCode;

  @override
  int get hashCode => urlEncodedHeadword.hashCode;
}

@immutable
@JsonSerializable(fieldRename: FieldRename.snake)
class Headword {
  final bool isDominant;
  final String headwordText;
  final String? abbreviation;
  final String? namingStandard;
  final String? parentheticalQualifier;

  Headword({
    required this.headwordText,
    required this.isDominant,
    required this.abbreviation,
    required this.namingStandard,
    required this.parentheticalQualifier,
  });

  factory Headword.fromJson(Map<String, dynamic> json) =>
      _$HeadwordFromJson(json);

  Map<String, dynamic> toJson() => _$HeadwordToJson(this);

  String get urlEncodedHeadword => Entry.urlEncode(headwordText);

  String urlDecodeHeadword(String urlEncodedHeadword) =>
      Entry.urlDecode(urlEncodedHeadword);
}

@immutable
@JsonSerializable(fieldRename: FieldRename.snake)
class Translation {
  final String partOfSpeech;
  final String translationText;
  final String? irregularInflections;
  final String? dominantHeadwordParentheticalQualifier;
  final String? genderAndPlural;
  final String? translationNamingStandard;
  final String? translationAbbreviation;
  final String? translationParentheticalQualifier;
  final List<String> examplePhrases;
  final String? editorialNote;

  Translation({
    required this.partOfSpeech,
    required this.translationText,
    required this.irregularInflections,
    required this.dominantHeadwordParentheticalQualifier,
    required this.genderAndPlural,
    required this.translationNamingStandard,
    required this.translationAbbreviation,
    required this.translationParentheticalQualifier,
    required this.examplePhrases,
    required this.editorialNote,
  });

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

class EntryBuilder {
  late Headword _headword;
  late int _entryId;
  List<Headword> _alternateHeadwords = [];
  List<String> _related = [];

  List<Translation> _translations = [];

  EntryBuilder headword(
    String headwordText,
    String abbreviation,
    String parentheticalQualifier,
  ) {
    _headword = Headword(
      headwordText: headwordText,
      abbreviation: abbreviation.emptyToNull,
      namingStandard: null,
      parentheticalQualifier: parentheticalQualifier.emptyToNull,
      isDominant: true,
    );
    return this;
  }

  EntryBuilder entryId(int entryId) {
    _entryId = entryId;
    return this;
  }

  EntryBuilder addRelated(List<String> related) {
    _related.addAll(related);
    return this;
  }

  EntryBuilder addAlternateHeadword({
    required String headwordText,
    required String abbreviation,
    required String namingStandard,
    required String parentheticalQualifier,
  }) {
    assert(headwordText != '',
        "You must specify a non-empty alternate headword. Headword: ${_headword.headwordText}. Line: ${_entryId + 2}");
    _alternateHeadwords.add(
      Headword(
        headwordText: headwordText,
        abbreviation: abbreviation.emptyToNull,
        namingStandard: namingStandard.emptyToNull,
        parentheticalQualifier: parentheticalQualifier.emptyToNull,
        isDominant: false,
      ),
    );
    return this;
  }

  EntryBuilder addTranslation({
    required String partOfSpeech,
    required String irregularInflections,
    required String dominantHeadwordParentheticalQualifier,
    required String translation,
    required String genderAndPlural,
    required String translationNamingStandard,
    required String translationAbbreviation,
    required String translationParentheticalQualifier,
    required List<String> examplePhrases,
    required String editorialNote,
  }) {
    assert(translation != '',
        "You must specify a non-empty translation. Headword: ${_headword.headwordText} at line $_entryId");
    _translations.add(
      Translation(
        partOfSpeech: partOfSpeech,
        irregularInflections: irregularInflections.emptyToNull,
        dominantHeadwordParentheticalQualifier:
            dominantHeadwordParentheticalQualifier.emptyToNull,
        translationText: translation,
        genderAndPlural: genderAndPlural.emptyToNull,
        translationNamingStandard: translationNamingStandard.emptyToNull,
        translationAbbreviation: translationAbbreviation.emptyToNull,
        translationParentheticalQualifier:
            translationParentheticalQualifier.emptyToNull,
        examplePhrases: examplePhrases,
        editorialNote: editorialNote.emptyToNull,
      ),
    );
    return this;
  }

  Entry build() {
    assert(_translations.length != 0,
        "You must specify one or more translations. Line ${_entryId + 2}.");
    return Entry(
      entryId: _entryId,
      headword: _headword,
      related: _related,
      alternateHeadwords: _alternateHeadwords,
      translations: _translations,
    );
  }
}
