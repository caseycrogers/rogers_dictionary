import 'package:rogers_dictionary/protobufs/entry.pb.dart';

typedef Headword = Entry_Headword;
typedef Translation = Entry_Translation;

extension EntryUtils on Entry {
  List<Headword> get allHeadwords =>
      [headword, ...alternateHeadwords];

  static String urlDecode(String urlEncodedHeadword) {
    return Uri.decodeComponent(
        (urlEncodedHeadword.split('_')
          ..removeAt(0)).join(''));
  }

  static String urlEncode(String headword) {
    return Uri.encodeComponent(headword);
  }

  static Entry notFound(String headword) {
    print('WARN: Entry $headword not found');
    return Entry(
      entryId: -1,
      headword: Headword(
        isAlternate: false,
        headwordText: 'Invalid headword ${urlDecode(headword)}',
      ),
      translations: <Translation>[
        Translation(
          partOfSpeech: '',
          content:
          'Please use the help button (upper right) to report this bug!',
        ),
      ],
    );
  }

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
    return partOfSpeech.replaceAll(' ', '').splitMapJoin(
      RegExp('[&,]|phrase'),
      onNonMatch: (String partOfSpeechComponent) =>
      _partOfSpeechAbbreviationMap[partOfSpeechComponent] ??
          '$partOfSpeechComponent*',
      onMatch: (Match separator) {
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
      },
    );
  }
}

extension HeadwordUtils on Headword {
  String get urlEncodedHeadword => EntryUtils.urlEncode(headwordText);
}

class EntryBuilder {
  late Headword _headword;
  late int _entryId;
  List<Headword>? _alternateHeadwords;
  List<String>? _related;

  final List<Translation> _translations = <Translation>[];

  EntryBuilder headword(String headwordText,
      String abbreviation,
      String parentheticalQualifier) {
    _headword = Headword(
      isAlternate: false,
      headwordText: headwordText,
      abbreviation: abbreviation,
      namingStandard: null,
      parentheticalQualifier: parentheticalQualifier,
    );
    return this;
  }

  EntryBuilder entryId(int entryId) {
    _entryId = entryId;
    return this;
  }

  EntryBuilder addRelated(List<String> related) {
    if (related.isNotEmpty) {
      _related = (_related ?? <String>[])
        ..addAll(related);
    }
    return this;
  }

  EntryBuilder addAlternateHeadword({
    required String headwordText,
    required String abbreviation,
    required String namingStandard,
    required String parentheticalQualifier,
  }) {
    assert(headwordText != '',
    'You must specify a non-empty alternate headword. Headword: ${_headword
        .headwordText}. Line: ${_entryId + 2}');
    _alternateHeadwords = (_alternateHeadwords ?? <Headword>[])
      ..add(
        Headword(
          isAlternate: true,
          headwordText: headwordText,
          abbreviation: abbreviation,
          namingStandard: namingStandard,
          parentheticalQualifier: parentheticalQualifier,
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
    required String namingStandard,
    required String abbreviation,
    required String parentheticalQualifier,
    required List<String> examplePhrases,
    required String editorialNote,
  }) {
    assert(translation != '',
    'You must specify a non-empty translation. Headword: ${_headword
        .headwordText} at line $_entryId');
    _translations.add(
      Translation(
        partOfSpeech: partOfSpeech,
        irregularInflections: irregularInflections,
        dominantHeadwordParentheticalQualifier:
        dominantHeadwordParentheticalQualifier,
        content: translation,
        genderAndPlural: genderAndPlural,
        namingStandard: namingStandard,
        abbreviation: abbreviation,
        parentheticalQualifier:
        parentheticalQualifier,
        examplePhrases: examplePhrases,
        editorialNote: editorialNote,
      ),
    );
    return this;
  }

  Entry build() {
    assert(_translations.isNotEmpty,
    'You must specify one or more translations. Line ${_entryId + 2}.');
    return Entry(
      entryId: _entryId,
      headword: _headword,
      related: _related,
      alternateHeadwords: _alternateHeadwords,
      translations: _translations,
    );
  }
}
