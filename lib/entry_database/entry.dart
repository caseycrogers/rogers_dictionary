import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'entry.g.dart';

@immutable
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Entry {
  // Run the following to rebuild generated files:
  // flutter pub run build_runner build --delete-conflicting-outputs
  final int entryId;
  final String headword;
  final String runOnParent;
  final List<String> runOns;
  final String headwordAbbreviation;
  final List<String> alternateHeadwords;
  final List<String> alternateHeadwordNamingStandards;

  final List<Translation> translations;

  Entry({
    @required this.entryId,
    @required this.headword,
    @required this.runOnParent,
    @required this.runOns,
    @required this.headwordAbbreviation,
    @required this.alternateHeadwords,
    @required this.alternateHeadwordNamingStandards,
    @required this.translations,
  });

  @JsonKey(ignore: true)
  static final Map<String, String> _partOfSpeechAbbreviationMap = {
    'adj': 'adjective',
    'adv': 'adverb',
    'f': 'feminine noun',
    'fpl': 'feminine plural noun',
    'm': 'masculine noun',
    'mpl': 'masculine plural noun',
    'vi': 'intransitive verb',
    'vr': 'reflexive verb',
    'vt': 'transitive verb',
    'interj': 'interjection',
    'n': 'noun',
    'npl': 'plural noun',
    'prep': 'preposition',
    '-': 'phrase',
  };

  static String longPartOfSpeech(String partOfSpeech) {
    return partOfSpeech.replaceAll(' ', '').splitMapJoin(
          RegExp('[&,]'),
          onNonMatch: (partOfSpeechComponent) =>
              _partOfSpeechAbbreviationMap[partOfSpeechComponent] ??
              partOfSpeechComponent,
          onMatch: (separator) => separator.group(0) == '&' ? ' and ' : ', ',
        );
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

  get urlEncodedHeadword => Entry.urlEncode(headword);

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  bool keyWordMatches(String searchTerm) {
    return _keywords().any((keyword) => keyword.contains(searchTerm));
  }

  Map<String, dynamic> toJson() => _$EntryToJson(this);

  Set<String> _keywords() =>
      {headword}..addAll(translations.map((e) => e.translation));

  @override
  String toString() {
    return toJson().toString();
  }
}

@immutable
@JsonSerializable(fieldRename: FieldRename.snake)
class Translation {
  final String partOfSpeech;
  final String irregularInflections;
  final String headwordParentheticalQualifier;
  final String translation;
  final String genderAndPlural;
  final String translationNamingStandard;
  final String translationAbbreviation;
  final String translationParentheticalQualifier;
  final String examplePhrase;
  final String editorialNote;

  Translation({
    @required this.partOfSpeech,
    @required this.irregularInflections,
    @required this.headwordParentheticalQualifier,
    @required this.translation,
    @required this.genderAndPlural,
    @required this.translationNamingStandard,
    @required this.translationAbbreviation,
    @required this.translationParentheticalQualifier,
    @required this.examplePhrase,
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
  String _headword;
  int _entryId;
  String _runOnParent;
  List<String> _runOns = [];
  String _headwordAbbreviation;
  List<String> _alternateHeadwords = [];
  List<String> _alternateHeadwordNamingStandards = [];

  List<Translation> _translations = [];

  EntryBuilder headword(String headword) {
    _headword = headword;
    return this;
  }

  EntryBuilder entryId(int entryId) {
    _entryId = entryId;
    return this;
  }

  EntryBuilder runOnParent(String runOnParent) {
    _runOnParent = runOnParent;
    return this;
  }

  EntryBuilder addRunOn(String runOn) {
    assert(runOn != '',
        "You must specify a non-empty run on. Headword: $_headword");
    _runOns.add(runOn);
    return this;
  }

  EntryBuilder headwordAbbreviation(String headwordAbbreviation) {
    _headwordAbbreviation = headwordAbbreviation;
    return this;
  }

  EntryBuilder alternateHeadwords(List<String> alternateHeadwords) {
    _alternateHeadwords = alternateHeadwords;
    return this;
  }

  EntryBuilder alternateHeadwordNamingStandards(
      List<String> alternateHeadwordNamingStandards) {
    assert(
        _alternateHeadwords.length >= alternateHeadwordNamingStandards.length);
    _alternateHeadwordNamingStandards = alternateHeadwordNamingStandards;
    _alternateHeadwordNamingStandards.addAll(List.generate(
        _alternateHeadwords.length - _alternateHeadwordNamingStandards.length,
        (_) => ''));
    return this;
  }

  EntryBuilder addTranslation({
    @required String partOfSpeech,
    @required String irregularInflections,
    @required String headwordParentheticalQualifier,
    @required String translation,
    @required String genderAndPlural,
    @required String translationNamingStandard,
    @required String translationAbbreviation,
    @required String translationParentheticalQualifier,
    @required String examplePhrase,
    @required String editorialNote,
  }) {
    assert(translation != '',
        "You must specify a non-empty translation. Headword: $_headword");
    _translations.add(Translation(
        partOfSpeech: partOfSpeech,
        irregularInflections: irregularInflections,
        headwordParentheticalQualifier: headwordParentheticalQualifier,
        translation: translation,
        genderAndPlural: genderAndPlural,
        translationNamingStandard: translationNamingStandard,
        translationAbbreviation: translationAbbreviation,
        translationParentheticalQualifier: translationParentheticalQualifier,
        examplePhrase: examplePhrase,
        editorialNote: editorialNote));
    return this;
  }

  Entry build() {
    assert(_headword != null, "You must specify a non null headword.");
    assert(_entryId != null, "You must specify a non null entry id.");
    assert(_translations.length != 0,
        "You must specify one or more translations.");
    return Entry(
      entryId: _entryId,
      headword: _headword,
      runOnParent: _runOnParent,
      runOns: _runOns,
      headwordAbbreviation: _headwordAbbreviation,
      alternateHeadwords: _alternateHeadwords,
      alternateHeadwordNamingStandards: _alternateHeadwordNamingStandards,
      translations: _translations,
    );
  }
}
