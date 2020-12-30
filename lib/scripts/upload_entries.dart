import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

import 'package:args/args.dart';
import 'package:firedart/firedart.dart';
import 'package:df/df.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> uploadEntries(bool debug, bool verbose, bool isSpanish) async {
  var filePath = join(Directory.current.path, 'lib', 'scripts',
      'dictionary_database-${isSpanish ? 'spanish' : 'english'}.csv');
  print('Uploading: $filePath.');
  var df = await DataFrame.fromCsv(filePath);

  var rows = df.rows.map((row) => row.map(_parseCell));
  EntryBuilder builder;
  String partOfSpeech;
  String headwordParentheticalQualifier;
  var i = 0;
  Map<String, EntryBuilder> entryBuilders = {};

  while (i < rows.length && i < 3000) {
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
        entryBuilders[row[RUN_ON_PARENT]]?.addRunOn(row[HEADWORD]) ??
            print(
                "Missing run on parent \'${row[RUN_ON_PARENT]}\' for entry \'${row[HEADWORD]}\'");
      }
      builder = EntryBuilder()
          .orderByField(Entry.generateOrderByField(row[HEADWORD], i))
          .entryId(i)
          .headword(row[HEADWORD])
          .runOnParent(row[RUN_ON_PARENT])
          .headwordAbbreviation(row[HEADWORD_ABBREVIATION])
          .alternateHeadwords(row[ALTERNATE_HEADWORDS].split('|'))
          .alternateHeadwordNamingStandards(
              row[ALTERNATE_HEADWORD_NAMING_STANDARDS].split('|'));
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
  return _uploadSqlFlite(
      entryBuilders.values.map((b) => b.build()).toList(), debug, verbose);
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

Future<void> _uploadFirestore(List<Entry> entries, bool debug, bool verbose) {
  Firestore.initialize('rogers-dicitionary');
  return Future.wait(
    entries.map((entry) {
      var entryMap = entry.toJson()
        ..addEntries([MapEntry(KEYWORD_LIST, _constructSearchList(entry))]);
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
    }),
  );
}

Future<void> _uploadSqlFlite(
    List<Entry> entries, bool debug, bool verbose) async {
  const path =
      'C:/Users/Waffl/Documents/code/rogers_dictionary/assets/entries.db';
  sqfliteFfiInit();
  var db = await databaseFactoryFfi.openDatabase(path);
  await db.execute('''DROP TABLE English''');
  await db.execute('''CREATE TABLE English (
    $URL_ENCODED_HEADWORD STRING NOT NULL PRIMARY KEY,
    $ENTRY_ID INTEGER NOT NULL,
    $HEADWORD STRING NOT NULL,
    $RUN_ON_PARENT STRING,
    $HEADWORD_ABBREVIATION STRING,
    $ALTERNATE_HEADWORDS String,
    $HEADWORD$WITHOUT_DIACRITICAL_MARKS STRING NOT NULL,
    $RUN_ON_PARENT$WITHOUT_DIACRITICAL_MARKS STRING,
    $HEADWORD_ABBREVIATION$WITHOUT_DIACRITICAL_MARKS STRING,
    $ALTERNATE_HEADWORDS$WITHOUT_DIACRITICAL_MARKS String,
    translations STRING NOT NULL,
    entry_blob STRING NOT NULL
  )''');
  var batch = db.batch();
  for (var entry in entries) {
    var entryRecord = {
      URL_ENCODED_HEADWORD: entry.urlEncodedHeadword,
      ENTRY_ID: entry.entryId,
      HEADWORD: entry.headword,
      RUN_ON_PARENT: entry.runOnParent,
      HEADWORD_ABBREVIATION: entry.headwordAbbreviation,
      ALTERNATE_HEADWORDS: entry.alternateHeadwords.join(' | '),
      HEADWORD + WITHOUT_DIACRITICAL_MARKS:
          entry.headword.withoutDiacriticalMarks,
      RUN_ON_PARENT + WITHOUT_DIACRITICAL_MARKS:
          entry.runOnParent.withoutDiacriticalMarks,
      HEADWORD_ABBREVIATION + WITHOUT_DIACRITICAL_MARKS:
          entry.headwordAbbreviation.withoutDiacriticalMarks,
      ALTERNATE_HEADWORDS + WITHOUT_DIACRITICAL_MARKS: entry.alternateHeadwords
          .map((alt) => alt.withoutDiacriticalMarks)
          .join('|'),
      'translations': entry.translations.join('|'),
      'entry_blob': jsonEncode(entry.toJson()),
    };
    if (verbose) print(entryRecord);
    batch.insert('English', entryRecord);
  }
}

MapEntry<String, String> _parseCell(String key, dynamic value) {
  if (!(value is String)) value = '';
  var str = value as String;
  return MapEntry(key.trim(), str.trim().replaceAll(' | ', '|'));
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('debug', abbr: 'd', defaultsTo: false)
    ..addFlag('verbose', abbr: 'v', defaultsTo: false)
    ..addFlag('spanish', abbr: 's', defaultsTo: false);
  var argResults = parser.parse(arguments);

  await uploadEntries(argResults['debug'] as bool,
      argResults['verbose'] as bool, argResults['spanish'] as bool);
}
