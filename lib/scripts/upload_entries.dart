import 'dart:async';

import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';

import 'package:args/args.dart';
import 'package:firedart/firedart.dart';
import 'package:df/df.dart';

const HEADWORD = 'headword';
const RUN_ON_PARENT = 'run_on_parent';
const RUN_ON_TEXT = 'run_on_text';
const ABBREVIATION = 'abbreviation';
const NAMING_STANDARD = 'naming_standard';
const ALTERNATE_HEADWORD = 'alternate_headword';
const ALTERNATE_HEADWORD_ABBREVIATION = 'alternate_headword_abbreviation';
const ALTERNATE_HEADWORD_NAMING_STANDARD = 'alternate_headword_naming_standard';
const REDIRECT_HEADWORD = 'redirect_headword';
const IRREGULAR_INFLECTION = 'irregular_inflection';
const PART_OF_SPEECH = 'part_of_speech';
const HEADWORD_RESTRICTIVE_LABEL = 'headword_restrictive_label';
const MEANING_ID = 'meaning_id';
const TRANSLATION = 'translation';
const SHOULD_BE_KEY_PHRASE = 'should_be_key_phrase';
const TRANSLATION_FEMININE_INDICATOR = 'translation_feminine_indicator';
const GENDER_AND_PLURAL = 'gender_and_plural';
const EXAMPLE_PHRASE = 'example_phrase';
const EDITORIAL_NOTE = 'editorial_note';

const KEYWORD_LIST = 'keyword_list';
const URL_ENCODED_HEADWORD = 'url_encoded_headword';

Future<List<void>> uploadEntries(bool debug, bool verbose) async {
  Firestore.initialize('rogers-dicitionary');
  var df = await DataFrame.fromCsv('lib/scripts/dictionary_database.csv');

  var rows = df.rows.map((row) => row.map(_parseCell));
  EntryBuilder builder;
  String partOfSpeech;
  String meaningId;
  var i = 0;
  Map<String, EntryBuilder> entryBuilders = {};

  while (i < rows.length) {
    if (i % 500 == 0) print('$i/${rows.length} complete!');
    Map<String, String> row = rows.elementAt(i);
    if (row[HEADWORD].isNotEmpty) {
      if ((row[PART_OF_SPEECH].isEmpty && row[RUN_ON_PARENT].isEmpty) || row[TRANSLATION].isEmpty) {
        print('Invalid empty cells for \'${row[HEADWORD]}\' at row $i, skipping.');
        i += 1;
        row = rows.elementAt(i);
        while (row[HEADWORD].isEmpty) {
          i += 1;
          row = rows.elementAt(i);
        }
        continue;
      }
      var urlEncoded = Entry.urlEncode(row[HEADWORD], i);
      var urlEncodedParent = '';
      if (row[RUN_ON_PARENT].isNotEmpty) {
        var parent = entryBuilders[row[RUN_ON_PARENT]];
        if (parent == null) {
          print("Missing run on parent \'${row[RUN_ON_PARENT]}\' for entry \'${row[HEADWORD]}\'");
        } else {
          parent.addRunOn(urlEncoded);
          urlEncodedParent = parent.getUrlEncodedHeadword();
        }
      }
      builder = EntryBuilder()
          .urlEncodedHeadword(urlEncoded)
          .entryId(i)
          .headword(row[HEADWORD])
          .runOnParent(urlEncodedParent)
          .runOnText(row[RUN_ON_TEXT])
          .abbreviation(row[ABBREVIATION])
          .namingStandard(row[NAMING_STANDARD])
          .alternateHeadword(row[ALTERNATE_HEADWORD])
          .alternateHeadwordAbbreviation(row[ALTERNATE_HEADWORD_ABBREVIATION])
          .alternateHeadwordNamingStandard(
              row[ALTERNATE_HEADWORD_NAMING_STANDARD]);
      entryBuilders[row[HEADWORD]] = builder;
    }
    if (row[PART_OF_SPEECH] != '') partOfSpeech = row[PART_OF_SPEECH];
    if (row[MEANING_ID] != '') meaningId = row[MEANING_ID];
    builder.addTranslation(
        meaningId,
        partOfSpeech,
        row[TRANSLATION],
        row[SHOULD_BE_KEY_PHRASE] != 'F',
        row[TRANSLATION_FEMININE_INDICATOR],
        row[GENDER_AND_PLURAL],
        row[EXAMPLE_PHRASE],
        row[EDITORIAL_NOTE]);
    i++;
  }
  assert(builder != null, "Did not generate any entries!");
  var uploadFutures = entryBuilders.values.map((b) => _upload(b.build(), debug, verbose));
  print('done?');
  return Future.wait(uploadFutures);
}

Future<void> _upload(Entry entry, bool debug, bool verbose) {
  var entryMap = entry.toJson();
  entryMap[KEYWORD_LIST] = _constructSearchList(entry);
  entryMap[URL_ENCODED_HEADWORD] = entry.urlEncodedHeadword;
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
      if (!(i == 0 || [' ', '-', '.'].contains(k.substring(i - 1, i)))) continue;
      for (int j = i; j <= k.length; j++) {
        ret.add(k.substring(i, j));
      }
    }
    ret.add("");
    return ret.toList();
  }).toList();
}

void _assertValid(Map<String, String> row, String header, int index) {
  assert(
      row[header] != '', 'Invalid empty $header at index $index.\nRow:\n$row');
}

MapEntry<String, String> _parseCell(String key, dynamic value) {
  if (!(value is String)) value = '';
  if (key == MEANING_ID && value == '') value = '0';
  return MapEntry(key.trim(), value.trim());
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('debug', abbr: 'd', defaultsTo: false)
    ..addFlag('verbose', abbr: 'v', defaultsTo: false);
  var argResults = parser.parse(arguments);

  await uploadEntries(argResults['debug'] as bool, argResults['verbose'] as bool);
}
