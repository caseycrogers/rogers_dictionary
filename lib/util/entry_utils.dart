import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';

import 'package:rogers_dictionary/clients/database_constants.dart';
import 'package:rogers_dictionary/i18n_base.dart' as i18n;
import 'package:rogers_dictionary/protobufs/database_version.pb.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';

typedef Headword = Entry_Headword;
typedef Translation = Entry_Translation;

extension VersionUtils on DatabaseVersion {
  static DatabaseVersion fromDisk(File file) {
    return fromString(file.readAsStringSync());
  }

  static DatabaseVersion fromString(String jsonString) {
    return DatabaseVersion()
      ..mergeFromProto3Json(jsonDecode(jsonString))
      ..freeze();
  }

  void write(File file) {
    file.writeAsStringSync(jsonEncode(toProto3Json()));
  }

  DatabaseVersion incremented() => DatabaseVersion(
        major: major,
        minor: minor,
        patch: patch + 1,
      )..freeze();

  String get versionString => '$major.$minor.$patch';
}

extension EntryUtils on Entry {
  List<Headword> get allHeadwords => [headword, ...alternateHeadwords];

  Map<String, List<Translation>> get translationMap {
    return translations.groupListsBy((t) => t.partOfSpeech);
  }

  bool get isNotFound => uid == '404';

  static Entry notFound(String headword) {
    return Entry(
      uid: '404',
      headword: Headword(
        isAlternate: false,
        text: headword,
      ),
      orderId: 0,
      translations: <Translation>[
        Translation(
          partOfSpeech: '',
          text: 'Please use the help button (upper right) to report this bug!',
        ),
      ],
    );
  }

  static final Map<String, i18n.Message> _partOfSpeechAbbreviationMap = {
    'adj': i18n.adjective,
    'adv': i18n.adverb,
    'conj': i18n.conjunction,
    'deg': i18n.degree,
    'f': i18n.feminineNoun,
    'fpl': i18n.femininePluralNoun,
    'f(pl)': i18n.femininePluralNounParen,
    'inf': i18n.infinitive,
    'interj': i18n.interjection,
    'm': i18n.masculineNoun,
    'mf': i18n.masculineFeminineNoun,
    'mpl': i18n.masculinePluralNoun,
    'mfpl': i18n.masculineFemininePluralNoun,
    'm(pl)': i18n.masculinePluralNounParen,
    'n': i18n.noun,
    'npl': i18n.pluralNoun,
    'n(pl)': i18n.pluralNounParen,
    'pref': i18n.prefix,
    'prep': i18n.preposition,
    'v': i18n.verb,
    'vi': i18n.intransitiveVerb,
    'vr': i18n.reflexiveVerb,
    'vt': i18n.transitiveVerb,
    '-': i18n.phrase,
    '': i18n.blank,
    'adjphrase': i18n.adjectivePhrase,
    'advphrase': i18n.adverbPhrase,
    'degphrase': i18n.degreePhrase,
    'nphrase': i18n.nounPhrase,
    'nplphrase': i18n.pluralNounPhrase,
    'prepphrase': i18n.prepositionPhrase,
    'vphrase': i18n.verbPhrase,
    'fphrase': i18n.feminineNounPhrase,
    'fplphrase': i18n.femininePluralNounPhrase,
    'mfphrase': i18n.masculineFeminineNounPhrase,
    'mfplphrase': i18n.masculineFeminineNounPhrase,
    'mphrase': i18n.masculineNounPhrase,
    'mplphrase': i18n.masculinePluralNounPhrase,
    'm(pl)phrase': i18n.masculinePluralNounPhraseParen,
  };

  static String longPartOfSpeech(
    String partOfSpeech,
    bool isSpanish,
  ) {
    return partOfSpeech.replaceAll(' ', '').splitMapJoin(
      RegExp('[&,]'),
      onNonMatch: (String partOfSpeechComponent) {
        return _partOfSpeechAbbreviationMap[partOfSpeechComponent]
                ?.getFor(isSpanish) ??
            '$partOfSpeechComponent*';
      },
      onMatch: (Match separator) {
        //  == '&' ? ' and ' : ', ',
        switch (separator.group(0)) {
          case '&':
            return ' and ';
          case ',':
            return ', ';
          default:
            return separator.group(0)!;
        }
      },
    );
  }
}

extension TranslationUtils on Translation {
  String getLocalizedPartOfSpeech(bool isSpanish) {
    return partOfSpeech.replaceAll('phrase', 'frase');
  }
}

class EntryBuilder {
  late String _uid;
  late Headword _headword;
  late int _orderId;
  List<Headword>? _alternateHeadwords;
  final List<EntryBuilder> _childRelateds = [];
  final List<EntryBuilder> _relateds = [];

  // Mapping from raw opposite headwords to the translations they came from.
  // Used to convert the opposite headwords into UIDs.
  final Map<String, Translation> rawOppositeHeadwords = {};

  List<EntryBuilder> get related => _relateds + _childRelateds;

  final List<Translation> _translations = <Translation>[];

  EntryBuilder uid(String uid) {
    _uid = uid;
    return this;
  }

  String get getUid {
    return _uid;
  }

  String get getHeadword {
    return _headword.text;
  }

  EntryBuilder headword(
      String text, String abbreviation, String parentheticalQualifier) {
    _headword = Headword(
      isAlternate: false,
      text: text,
      abbreviation: abbreviation,
      namingStandard: null,
      parentheticalQualifier: parentheticalQualifier,
    );
    return this;
  }

  EntryBuilder orderId(int orderId) {
    _orderId = orderId;
    return this;
  }

  EntryBuilder addParent(EntryBuilder parent) {
    // Add `this` to all the existing siblings first.
    for (final EntryBuilder sibling in parent._childRelateds) {
      assert(
          sibling._uid != _uid,
          '$ERROR Duplicative transitive related entry '
          '\'${sibling._headword.text}\' for entry '
          '\'${parent._headword.text}\' originating from line '
          '$_orderId');
      // Siblings are considered regular relateds, not transitive relateds.
      sibling._addRelated(this);
      _addRelated(sibling);
    }
    _addRelated(parent);
    // Only the parent gets a special-case transitive related via `_addChild`.
    parent._addChild(this);
    return this;
  }

  EntryBuilder addRelated(EntryBuilder related) {
    _addRelated(related);
    related._addRelated(this);
    return this;
  }

  // One directional.
  void _addRelated(EntryBuilder related) {
    assert(
        !_relateds.contains(related),
        '$ERROR Attempted to add duplicative related '
        '\'${related._headword.text}\' to entry \'${_headword.text}\'');
    _relateds.add(related);
  }

  // One directional.
  void _addChild(EntryBuilder child) {
    assert(
        !_childRelateds.contains(child),
        '$ERROR Attempted to add duplicative transitive related '
        '\'${child._headword.text}\' to entry \'${_headword.text}\'');
    _childRelateds..add(child);
  }

  EntryBuilder addAlternateHeadword({
    required String text,
    required String gender,
    required String abbreviation,
    required String namingStandard,
    required String parentheticalQualifier,
  }) {
    assert(
        text != '',
        'You must specify a non-empty alternate headword. '
        'Headword: ${_headword.text}. Line: ${_orderId + 2}');
    _alternateHeadwords = (_alternateHeadwords ?? <Headword>[])
      ..add(
        Headword(
          isAlternate: true,
          text: text,
          gender: gender,
          abbreviation: abbreviation,
          namingStandard: namingStandard,
          parentheticalQualifier: parentheticalQualifier,
        ),
      );
    return this;
  }

  EntryBuilder addTranslation({
    required String partOfSpeech,
    required List<String> irregularInflections,
    required String dominantHeadwordParentheticalQualifier,
    required String translation,
    required String pronunciationOverride,
    required String genderAndPlural,
    required String namingStandard,
    required String abbreviation,
    required String parentheticalQualifier,
    required String disambiguation,
    required List<String> examplePhrases,
    required String editorialNote,
    required String rawOppositeHeadword,
  }) {
    assert(
        translation != '',
        'You must specify a non-empty translation. '
        'Headword: ${_headword.text} at line $_orderId');
    _translations.add(
      Translation(
        partOfSpeech: partOfSpeech,
        irregularInflections: irregularInflections,
        dominantHeadwordParentheticalQualifier:
            dominantHeadwordParentheticalQualifier,
        text: translation,
        pronunciationOverride: pronunciationOverride,
        genderAndPlural: genderAndPlural,
        namingStandard: namingStandard,
        abbreviation: abbreviation,
        parentheticalQualifier: parentheticalQualifier,
        disambiguation: disambiguation,
        examplePhrases: examplePhrases,
        editorialNote: editorialNote,
      ),
    );
    if (rawOppositeHeadword.isNotEmpty) {
      rawOppositeHeadwords[rawOppositeHeadword] = _translations.last;
    }
    return this;
  }

  Entry build() {
    assert(_translations.isNotEmpty,
        'You must specify one or more translations. Line ${_orderId + 2}.');
    return Entry(
      uid: _uid,
      orderId: _orderId,
      headword: _headword,
      // We use the headword instead of UID because it makes it so we don't have
      // to do a join to read the data back in.
      related: (_relateds + _childRelateds).map((e) => e._headword.text),
      alternateHeadwords: _alternateHeadwords,
      translations: _translations,
    );
  }

  @override
  String toString() {
    return 'EntryBuilder(uid: $_uid, headword: ${_headword.text})';
  }
}
