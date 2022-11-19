// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:rogers_dictionary/util/entry_utils.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

void main() {
  test('Can replace diacritic characters with non-diacritic characters', () {
    expect('áÁéÉíÍóÓúÚýÝñÑöÖüÜ'.withoutDiacriticalMarks, 'aAeEiIoOuUyYnNoOuU');
  });

  test('Can remove combining-accent characters', () {
    expect('áÁéÉíÍóÓúÚýÝñÑöÖüÜ'.withoutDiacriticalMarks,
        'aAeEiIoOuUyYnNoOuU');
  });

  test('Can replace shit diacritics with not-shit diacritics', () {
    expect('áÁéÉíÍóÓúÚýÝñÑöÖüÜ'.standardizeSpanishDiacritics,
        'áÁéÉíÍóÓúÚýÝñÑöÖüÜ');
  });

  test('Can add transitive relateds', () {
    final EntryBuilder a = _mockEntryBuilder(uid: 'a');
    final EntryBuilder b = _mockEntryBuilder(uid: 'b');
    final EntryBuilder c = _mockEntryBuilder(uid: 'c');
    // The child adds its transitive parent.
    b.addParent(a);
    c.addParent(a);
    expect(a.related, unorderedEquals(<EntryBuilder>[b, c]));
    expect(b.related, unorderedEquals(<EntryBuilder>[a, c]));
    expect(c.related, unorderedEquals(<EntryBuilder>[a, b]));

    final EntryBuilder c_0 = _mockEntryBuilder(uid: 'c_0');
    final EntryBuilder c_1 = _mockEntryBuilder(uid: 'c_1');
    c_0.addParent(c);
    c_1.addParent(c);
    expect(a.related, unorderedEquals(<EntryBuilder>[b, c]));
    expect(b.related, unorderedEquals(<EntryBuilder>[a, c]));
    expect(c.related, unorderedEquals(<EntryBuilder>[a, b, c_0, c_1]));
    expect(c_0.related, unorderedEquals(<EntryBuilder>[c, c_1]));
    expect(c_1.related, unorderedEquals(<EntryBuilder>[c, c_0]));
  });

  test('Produces proper relateds with real-world entries', () {
    final EntryBuilder abdomen = _mockEntryBuilder(
      uid: '0',
      headword: 'abdomen',
      mockTranslation: true,
    );
    final EntryBuilder abdominal = _mockEntryBuilder(
      uid: '1',
      headword: 'abdominal',
      mockTranslation: true,
    );
    final EntryBuilder abdominoplasty = _mockEntryBuilder(
      uid: '2',
      headword: 'abdomimoplasty',
      mockTranslation: true,
    );
    final EntryBuilder bellyache = _mockEntryBuilder(
      uid: '3',
      headword: 'bellyache',
      mockTranslation: true,
    );
    abdominal.addParent(abdomen);
    abdominoplasty.addParent(abdomen);
    bellyache.addParent(abdomen);
    expect(
      abdomen.related,
      unorderedEquals(<EntryBuilder>[abdominal, abdominoplasty, bellyache]),
    );
    expect(
      abdomen.build().related,
      unorderedEquals(<String>['abdominal', 'abdomimoplasty', 'bellyache']),
    );
  });
}

EntryBuilder _mockEntryBuilder({
  String? uid,
  String? headword,
  bool mockTranslation = false,
}) {
  final EntryBuilder builder = EntryBuilder()
      .uid(uid ?? '0FAKEUID')
      .orderId(0)
      .headword(headword ?? uid ?? '0FAKEUID', '', '');
  if (mockTranslation) {
    builder.addTranslation(
      partOfSpeech: 'n',
      irregularInflections: [],
      dominantHeadwordParentheticalQualifier: '',
      translation: 'fakeTranslation',
      pronunciationOverride: '',
      genderAndPlural: '',
      namingStandard: '',
      abbreviation: '',
      parentheticalQualifier: '',
      disambiguation: '',
      examplePhrases: [],
      editorialNote: '',
      oppositeHeadword: '',
    );
  }
  return builder;
}
