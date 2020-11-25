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

const KEYWORD_LIST = 'keyword_list';

void uploadEntries(bool debug, bool verbose) async {
  Firestore.initialize('rogers-dicitionary');
  var df = await DataFrame.fromCsv('lib/scripts/dictionary_database.csv');

  var rows = df.rows.map((row) => row.map(_parseCell));
  EntryBuilder builder;
  String partOfSpeech;
  String meaningId;
  var i = 0;
  List<Future<void>> uploadFutures = [];

  while (i < df.length) {
    Map<String, String> row = rows.elementAt(i);
    if (row[HEADWORD] != '') {
      // Start a new entry for a new headword
      if (builder != null) uploadFutures.add(_upload(builder.build(), debug, verbose));
      if (row[PART_OF_SPEECH] == '' || row[TRANSLATION] == '') {
        print('Invalid empty cells for ${row[HEADWORD]} at row $i, skipping.');
        while (row[HEADWORD] == '') {
          i += 1;
          row = rows.elementAt(i);
        }
        i += 1;
        continue;
      }
      builder = EntryBuilder()
          .entryId(i)
          .headword(row[HEADWORD])
          .runOnParent(row[RUN_ON_PARENT])
          .runOnText(row[RUN_ON_TEXT])
          .abbreviation(row[ABBREVIATION])
          .namingStandard(row[NAMING_STANDARD])
          .alternateHeadword(row[ALTERNATE_HEADWORD])
          .alternateHeadwordAbbreviation(row[ALTERNATE_HEADWORD_ABBREVIATION])
          .alternateHeadwordNamingStandard(row[ALTERNATE_HEADWORD_NAMING_STANDARD]);
    }
    if (row[PART_OF_SPEECH] != '') partOfSpeech = row[PART_OF_SPEECH];
    if (row[MEANING_ID] != '') meaningId = row[MEANING_ID];
    builder.addTranslation(meaningId, partOfSpeech, row[TRANSLATION], row[SHOULD_BE_KEY_PHRASE] != 'F');
    i++;
  }
  assert(builder != null, "Did not generate any entries!");
  // Run one last time for the final entry
  uploadFutures.add(_upload(builder.build(), debug, verbose));
  await Future.wait(uploadFutures);
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
    ..add(entry.headword)
    ..addAll(entry.translations.map((t) => t.translation));
  return keywordSet.expand((k) {
    Set<String> ret = Set();
    for (int i = 0; i < k.length; i++) {
      for (int j = i; j <= k.length; j++) {
        ret.add(k.substring(i, j));
      }
    }
    ret.add("");
    return ret.toList();
  }).toList();
}

void _assertValid(Map<String, String> row, String header, int index) {
  assert(row[header] != '', 'Invalid empty $header at index $index.\nRow:\n$row');
}

MapEntry<String, String> _parseCell(String key, dynamic value) {
  if (!(value is String)) value = '';
  if (key == MEANING_ID && value == '') value = '0';
  return MapEntry(key.trim(), value.trim());
}

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag('debug', abbr: 'd', defaultsTo: false)
    ..addFlag('verbose', abbr: 'v', defaultsTo: false);
  var argResults = parser.parse(arguments);

  uploadEntries(argResults['debug'] as bool, argResults['verbose'] as bool);
}
