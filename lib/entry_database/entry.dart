import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'entry.g.dart';

@immutable
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
    @required this.entryId,
    @required this.headword,
    @required this.related,
    @required this.alternateHeadwords,
    @required this.translations,
  });

  @JsonKey(ignore: true)
  static final Map<String, String> _partOfSpeechAbbreviationMap = {
    'adj': 'adjective',
    'adv': 'adverb',
    'conj': 'conjunction',
    'deg': 'degree',
    'f': 'feminine noun',
    'fpl': 'feminine plural noun',
    'inf': 'infinitive',
    'interj': 'interjection',
    'm': 'masculine noun',
    'mf': 'masculine/feminine noun',
    'mpl': 'masculine plural noun',
    'n': 'noun',
    'npl': 'plural noun',
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
              return separator.group(0);
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
}

@immutable
@JsonSerializable(fieldRename: FieldRename.snake)
class Headword {
  final bool isDominant;
  final String headwordText;
  final String abbreviation;
  final String namingStandard;
  final String parentheticalQualifier;

  Headword({
    @required this.headwordText,
    @required this.abbreviation,
    @required this.namingStandard,
    @required this.parentheticalQualifier,
    @required this.isDominant,
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
  final String irregularInflections;
  final String dominantHeadwordParentheticalQualifier;
  final String translationText;
  final String genderAndPlural;
  final String translationNamingStandard;
  final String translationAbbreviation;
  final String translationParentheticalQualifier;
  final List<String> examplePhrases;
  final String editorialNote;

  Translation({
    @required this.partOfSpeech,
    @required this.irregularInflections,
    @required this.dominantHeadwordParentheticalQualifier,
    @required this.translationText,
    @required this.genderAndPlural,
    @required this.translationNamingStandard,
    @required this.translationAbbreviation,
    @required this.translationParentheticalQualifier,
    @required this.examplePhrases,
    @required this.editorialNote,
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
  Headword _headword;
  int _entryId;
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
      abbreviation: abbreviation,
      namingStandard: null,
      parentheticalQualifier: parentheticalQualifier,
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
    @required String headwordText,
    @required String abbreviation,
    @required String namingStandard,
    @required String parentheticalQualifier,
  }) {
    assert(headwordText != '',
        "You must specify a non-empty alternate headword. Headword: ${_headword.headwordText}. Line: ${_entryId + 2}");
    _alternateHeadwords.add(Headword(
      headwordText: headwordText,
      abbreviation: abbreviation,
      namingStandard: namingStandard,
      parentheticalQualifier: parentheticalQualifier,
      isDominant: false,
    ));
    return this;
  }

  EntryBuilder addTranslation({
    @required String partOfSpeech,
    @required String irregularInflections,
    @required String dominantHeadwordParentheticalQualifier,
    @required String translation,
    @required String genderAndPlural,
    @required String translationNamingStandard,
    @required String translationAbbreviation,
    @required String translationParentheticalQualifier,
    @required List<String> examplePhrases,
    @required String editorialNote,
  }) {
    assert(translation != '',
        "You must specify a non-empty translation. Headword: ${_headword.headwordText} at line $_entryId");
    _translations.add(Translation(
        partOfSpeech: partOfSpeech,
        irregularInflections: irregularInflections,
        dominantHeadwordParentheticalQualifier:
            dominantHeadwordParentheticalQualifier,
        translationText: translation,
        genderAndPlural: genderAndPlural,
        translationNamingStandard: translationNamingStandard,
        translationAbbreviation: translationAbbreviation,
        translationParentheticalQualifier: translationParentheticalQualifier,
        examplePhrases: examplePhrases,
        editorialNote: editorialNote));
    return this;
  }

  Entry build() {
    assert(_headword != null,
        "You must specify a non null headword. Line ${_entryId + 2}.");
    assert(_entryId != null,
        "You must specify a non null entry id. Line ${_entryId + 2}.");
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
