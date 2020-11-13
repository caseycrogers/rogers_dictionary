import 'dart:async';

import 'package:df/df.dart';
import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';

import 'package:firedart/firedart.dart';

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

void main() async {
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
      if (builder != null) uploadFutures.add(_upload(builder.build()));
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
    builder.addTranslation(meaningId, partOfSpeech, row[TRANSLATION]);
    i++;
  }
  assert(builder != null, "Did not generate any entries!");
  // Run one last time for the final entry
 uploadFutures.add(_upload(builder.build()));
 await Future.wait(uploadFutures);
}

Future<void> _upload(Entry entry) {
  return Firestore.instance
      .collection(ENTRIES_DB)
      .document(ENGLISH)
      .collection(ENTRIES)
      .document(entry.entryId.toString())
      .set(entry.toJson());
}

void _assertValid(Map<String, String> row, String header, int index) {
  assert(row[header] != '', 'Invalid empty $header at index $index.\nRow:\n$row');
}

MapEntry<String, String> _parseCell(String key, dynamic value) {
  if (!(value is String)) value = '';
  if (key == MEANING_ID && value == '') value = '0';
  return MapEntry(key, value);
}

