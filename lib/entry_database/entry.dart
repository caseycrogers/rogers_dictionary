import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'entry.g.dart';

@immutable
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Entry {
  // Run the following to rebuild generated files:
  // flutter pub run build_runner build --delete-conflicting-outputs
  final String orderByField;
  final String headword;
  final int entryId;
  final String runOnParent;
  final String runOnText;
  final List<String> runOns;
  final String abbreviation;
  final String namingStandard;
  final String alternateHeadword;
  final String alternateHeadwordAbbreviation;
  final String alternateHeadwordNamingStandard;

  final List<Translation> translations;

  Entry(
    this.orderByField,
    this.headword,
    this.entryId,
    this.runOnParent,
    this.runOnText,
    this.runOns,
    this.abbreviation,
    this.namingStandard,
    this.alternateHeadword,
    this.alternateHeadwordAbbreviation,
    this.alternateHeadwordNamingStandard,
    this.translations,
  );

  static String urlDecode(String urlEncodedHeadword) {
    return Uri.decodeComponent(
        (urlEncodedHeadword.split('_')..removeAt(0)).join(''));
  }

  static String urlEncode(String headword) {
    return Uri.encodeComponent(headword);
  }

  static String generateOrderByField(String headword, int entryId) {
    return entryId.toString().padLeft(4, '0') +
        '_' + urlEncode(headword);
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
  final String meaningId;
  final String partOfSpeech;
  final String translation;
  final bool shouldBeKeyPhrase;
  final String translationFeminineIndicator;
  final String genderAndPlural;
  final String examplePhrase;
  final String editorialNote;

  Translation(
    this.meaningId,
    this.partOfSpeech,
    this.translation,
    this.shouldBeKeyPhrase,
    this.translationFeminineIndicator,
    this.genderAndPlural,
    this.examplePhrase,
    this.editorialNote,
  );

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

class EntryBuilder {
  String _urlEncodedHeadword;
  String _headword;
  int _entryId;
  String _runOnParent;
  String _runOnText;
  List<String> _runOns = [];
  String _abbreviation;
  String _namingStandard;
  String _alternateHeadword;
  String _alternateHeadwordAbbreviation;
  String _alternateHeadwordNamingStandard;

  List<Translation> _translations = [];

  String getUrlEncodedHeadword() {
    return _urlEncodedHeadword;
  }

  EntryBuilder orderByField(String urlEncodedHeadword) {
    _urlEncodedHeadword = urlEncodedHeadword;
    return this;
  }

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

  EntryBuilder runOnText(String runOnText) {
    _runOnText = runOnText;
    return this;
  }

  EntryBuilder addRunOn(String runOn) {
    assert(runOn != '',
        "You must specify a non-empty run on. Headword: $_headword");
    _runOns.add(runOn);
    return this;
  }

  EntryBuilder abbreviation(String abbreviation) {
    _abbreviation = abbreviation;
    return this;
  }

  EntryBuilder namingStandard(String namingStandard) {
    _namingStandard = namingStandard;
    return this;
  }

  EntryBuilder alternateHeadword(String alternateHeadword) {
    _alternateHeadword = alternateHeadword;
    return this;
  }

  EntryBuilder alternateHeadwordAbbreviation(
      String alternateHeadwordAbbreviation) {
    _alternateHeadwordAbbreviation = alternateHeadwordAbbreviation;
    return this;
  }

  EntryBuilder alternateHeadwordNamingStandard(
      String alternateHeadwordNamingStandard) {
    _alternateHeadwordNamingStandard = alternateHeadwordNamingStandard;
    return this;
  }

  EntryBuilder addTranslation(
      String meaningId,
      String partOfSpeech,
      String translation,
      bool shouldBeKeyPhrase,
      String translationFeminineIndicator,
      String genderAndPlural,
      String examplePhrase,
      String editorialNote) {
    assert(translation != '',
        "You must specify a non-empty translation. Headword: $_headword");
    _translations.add(Translation(
        meaningId,
        partOfSpeech,
        translation,
        shouldBeKeyPhrase,
        translationFeminineIndicator,
        genderAndPlural,
        examplePhrase,
        editorialNote));
    return this;
  }

  Entry build() {
    assert(_urlEncodedHeadword != null,
        "You must specify a non null url encoded headword.");
    assert(_headword != null, "You must specify a non null headword.");
    assert(_entryId != null, "You must specify a non null entry id.");
    assert(_translations.length != 0,
        "You must specify one or more translations.");
    return Entry(
      _urlEncodedHeadword,
      _headword,
      _entryId,
      _runOnParent,
      _runOnText,
      _runOns,
      _abbreviation,
      _namingStandard,
      _alternateHeadword,
      _alternateHeadwordAbbreviation,
      _alternateHeadwordNamingStandard,
      _translations,
    );
  }
}
