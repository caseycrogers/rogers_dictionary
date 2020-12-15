import 'dart:async';

import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';

import 'package:args/args.dart';
import 'package:firedart/firedart.dart';
import 'package:df/df.dart';

const HEADWORD = 'headword';
const RUN_ON_PARENT = 'run_on_parent';
const RUN_ON_TEXT = 'run_on_text';
const HEADWORD_ABBREVIATION = 'headword_abbreviation';
const ALTERNATE_HEADWORD = 'alternate_headword';
const ALTERNATE_HEADWORD_NAMING_STANDARD = 'alternate_headword_naming_standard';
const IRREGULAR_INFLECTIONS = 'irregular_inflections';
const PART_OF_SPEECH = 'part_of_speech';
const HEADWORD_RESTRICTIVE_LABEL = 'headword_restrictive_label';

const HEADWORD_PARENTHETICAL_QUALIFIER = 'headword_parenthetical_qualifier';
const TRANSLATION = 'translation';
const SHOULD_BE_KEY_PHRASE = 'should_be_key_phrase';
const GENDER_AND_PLURAL = 'gender_and_plural';
const TRANSLATION_NAMING_STANDARD = 'translation_naming_standard';
const TRANSLATION_ABBREVIATION = 'translation_abbreviation';
const TRANSLATION_PARENTHETICAL_QUALIFIER =
    'translation_parenthetical_qualifier';
const EXAMPLE_PHRASE = 'example_phrase';
const EDITORIAL_NOTE = 'editorial_note';

const KEYWORD_LIST = 'keyword_list';
const ORDER_BY_FIELD = 'order_by_field';

Future<List<void>> uploadEntries(bool debug, bool verbose) async {
  Firestore.initialize('rogers-dicitionary');
  var df = await DataFrame.fromCsv('lib/scripts/dictionary_database.csv');

  var rows = df.rows.map((row) => row.map(_parseCell));
  EntryBuilder builder;
  String partOfSpeech;
  String headwordParentheticalQualifier;
  var i = 0;
  Map<String, EntryBuilder> entryBuilders = {};

  while (i < rows.length) {
    if (i % 500 == 0) print('$i/${rows.length} complete!');
    Map<String, String> row = rows.elementAt(i);
    if (row[HEADWORD].isNotEmpty) {
      if ((row[PART_OF_SPEECH].isEmpty && row[RUN_ON_PARENT].isEmpty) ||
          row[TRANSLATION].isEmpty) {
        print(
            'Invalid empty cells for \'${row[HEADWORD]}\' at row $i, skipping.');
        i += 1;
        row = rows.elementAt(i);
        while (row[HEADWORD].isEmpty) {
          i += 1;
          row = rows.elementAt(i);
        }
        continue;
      }
      if (row[RUN_ON_PARENT].isNotEmpty) {
        var parent = entryBuilders[row[RUN_ON_PARENT]];
        if (parent == null) {
          print(
              "Missing run on parent \'${row[RUN_ON_PARENT]}\' for entry \'${row[HEADWORD]}\'");
        } else {
          parent.addRunOn(row[HEADWORD]);
        }
      }
      builder = EntryBuilder()
          .orderByField(Entry.generateOrderByField(row[HEADWORD], i))
          .entryId(i)
          .headword(row[HEADWORD])
          .runOnParent(row[RUN_ON_PARENT])
          .headwordAbbreviation(row[HEADWORD_ABBREVIATION])
          .alternateHeadword(row[ALTERNATE_HEADWORD])
          .alternateHeadwordNamingStandard(
              row[ALTERNATE_HEADWORD_NAMING_STANDARD]);
      if (entryBuilders.keys.contains(row[HEADWORD]))
        print('Duplicate headword ${row[HEADWORD]} at line $i');
      entryBuilders[row[HEADWORD]] = builder;
      partOfSpeech = '';
      headwordParentheticalQualifier = '';
    }
    if (row[PART_OF_SPEECH].isNotEmpty) {
      partOfSpeech = row[PART_OF_SPEECH];
      // Reset the qualifier
      headwordParentheticalQualifier = '';
    }
    if (row[HEADWORD_PARENTHETICAL_QUALIFIER].isNotEmpty)
      headwordParentheticalQualifier = row[HEADWORD_PARENTHETICAL_QUALIFIER];
    builder.addTranslation(
        partOfSpeech: partOfSpeech,
        irregularInflections: row[IRREGULAR_INFLECTIONS],
        headwordParentheticalQualifier: headwordParentheticalQualifier,
        translation: row[TRANSLATION],
        genderAndPlural: row[GENDER_AND_PLURAL],
        translationNamingStandard: row[TRANSLATION_NAMING_STANDARD],
        translationAbbreviation: row[TRANSLATION_ABBREVIATION],
        translationParentheticalQualifier:
            row[TRANSLATION_PARENTHETICAL_QUALIFIER],
        examplePhrase: row[EXAMPLE_PHRASE],
        editorialNote: row[EDITORIAL_NOTE]);
    i++;
  }
  assert(builder != null, "Did not generate any entries!");
  var uploadFutures =
      entryBuilders.values.map((b) => _upload(b.build(), debug, verbose));
  print('done?');
  return Future.wait(uploadFutures);
}

Future<void> _upload(Entry entry, bool debug, bool verbose) {
  var entryMap = entry.toJson();
  entryMap[KEYWORD_LIST] = _constructSearchList(entry);
  if (verbose) {
    print('Entry:\n${entry.toJson()}');
    print('Keywords:\n${entryMap[KEYWORD_LIST]}');
  }
  if (debug) {
    return (Completer()..complete()).future;
  }
  return Firestore.instance
      .collection(ENTRIES_DB)
      .document(ENGLISH)
      .collection(ENTRIES)
      .document(entry.urlEncodedHeadword)
      .set(entryMap);
}

List<String> _constructSearchList(Entry entry) {
  Set<String> keywordSet = Set()
    ..add(entry.headword.toLowerCase())
    ..addAll(entry.translations.map((t) => t.translation.toLowerCase()));
  return keywordSet.expand((k) {
    Set<String> ret = Set();
    for (int i = 0; i < k.length; i++) {
      // Only start substrings at the start of words.
      if (!(i == 0 || [' ', '-', '.'].contains(k.substring(i - 1, i))))
        continue;
      for (int j = i; j <= k.length; j++) {
        ret.add(k.substring(i, j));
      }
    }
    ret.add("");
    return ret.toList();
  }).toList();
}

MapEntry<String, String> _parseCell(String key, dynamic value) {
  if (!(value is String)) value = '';
  return MapEntry(key.trim(), value.trim());
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('debug', abbr: 'd', defaultsTo: false)
    ..addFlag('verbose', abbr: 'v', defaultsTo: false);
  var argResults = parser.parse(arguments);

  await uploadEntries(
      argResults['debug'] as bool, argResults['verbose'] as bool);
}
