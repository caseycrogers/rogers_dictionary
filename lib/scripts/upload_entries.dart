import 'dart:async';
import 'dart:convert';

import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

import 'package:args/args.dart';
import 'package:firedart/firedart.dart';
import 'package:df/df.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rogers_dictionary/util/list_utils.dart';

const ROGERS_DICTIONARY =
    'C:\\Users\\Waffl\\Documents\\code\\rogers_dictionary';

Future<void> uploadEntries(bool debug, bool verbose, bool isSpanish) async {
  var filePath = join(ROGERS_DICTIONARY, 'lib', 'scripts',
      'dictionary_database-${isSpanish ? SPANISH.toLowerCase() : ENGLISH.toLowerCase()}.csv');
  print('Uploading: $filePath.');
  var df = await DataFrame.fromCsv(filePath);

  var rows = df.rows.map((row) => row.map(_parseCell));
  EntryBuilder builder;
  String partOfSpeech;
  String dominantHeadwordParentheticalQualifier;
  var i = 0;
  Map<String, EntryBuilder> entryBuilders = {};

  while (i < rows.length) {
    if (i % 500 == 0) print('$i/${rows.length} complete!');
    Map<String, String> row = rows.elementAt(i);
    if (row[HEADWORD].isNotEmpty) {
      // Only process the test area
      if (row[HEADWORD][0] != '~') break;
      if ((row[PART_OF_SPEECH].isEmpty && row[RUN_ON_PARENTS].isEmpty) ||
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
      var parents = <String>[];
      if (row[RUN_ON_PARENTS].isNotEmpty) {
        parents = row[RUN_ON_PARENTS].split('|');
        parents.forEach((parent) {
          entryBuilders[parent]?.addRunOn(row[HEADWORD]) ??
              print(
                  "Missing run on parent \'$parent\' for entry \'${row[HEADWORD]}\'");
        });
      }
      builder = EntryBuilder()
          .entryId(i)
          .headword(
              row[HEADWORD],
              _split(row[HEADWORD_ABBREVIATIONS]).get(0, orElse: ''),
              _split(row[HEADWORD_PARENTHETICAL_QUALIFIERS]).get(0, orElse: ''))
          .runOnParents(parents);
      _split(row[ALTERNATE_HEADWORDS])
          .asMap()
          .forEach((i, alternateHeadwordText) {
        var index = i + 1;
        builder.addAlternateHeadword(
          headwordText: alternateHeadwordText,
          abbreviation:
              _split(row[HEADWORD_ABBREVIATIONS]).get(index, orElse: ''),
          namingStandard: _split(row[ALTERNATE_HEADWORD_NAMING_STANDARDS])
              .get(index, orElse: ''),
          parentheticalQualifier: _split(row[HEADWORD_PARENTHETICAL_QUALIFIERS])
              .get(index, orElse: ''),
        );
      });
      if (entryBuilders.keys.contains(row[HEADWORD]))
        print('Duplicate headword ${row[HEADWORD]} at line $i');
      entryBuilders[row[HEADWORD]] = builder;
      partOfSpeech = '';
      dominantHeadwordParentheticalQualifier = '';
    }
    if (row[PART_OF_SPEECH].isNotEmpty) {
      partOfSpeech = row[PART_OF_SPEECH];
      // Reset the qualifier
      dominantHeadwordParentheticalQualifier = '';
    }
    if (row[DOMINANT_HEADWORD_PARENTHETICAL_QUALIFIER].isNotEmpty)
      dominantHeadwordParentheticalQualifier =
          row[DOMINANT_HEADWORD_PARENTHETICAL_QUALIFIER];
    builder.addTranslation(
        partOfSpeech: partOfSpeech,
        irregularInflections: row[IRREGULAR_INFLECTIONS],
        dominantHeadwordParentheticalQualifier:
            dominantHeadwordParentheticalQualifier,
        translation: row[TRANSLATION],
        genderAndPlural: row[GENDER_AND_PLURAL],
        translationNamingStandard: row[TRANSLATION_NAMING_STANDARD],
        translationAbbreviation: row[TRANSLATION_ABBREVIATION],
        translationParentheticalQualifier:
            row[TRANSLATION_PARENTHETICAL_QUALIFIER],
        examplePhrases: _split(row[EXAMPLE_PHRASES]),
        editorialNote: row[EDITORIAL_NOTE]);
    i++;
  }
  assert(builder != null, "Did not generate any entries!");
  return _uploadSqlFlite(
    isSpanish ? SPANISH : ENGLISH,
    entryBuilders.values.map((b) => b.build()).toList(),
    debug,
    verbose,
  );
}

List<String> _constructSearchList(Entry entry) {
  Set<String> keywordSet = Set()
    ..add(entry.headwordText.toLowerCase())
    ..addAll(entry.translations.map((t) => t.translationText.toLowerCase()));
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
  String tableName,
  List<Entry> entries,
  bool debug,
  bool verbose,
) async {
  final path = join(ROGERS_DICTIONARY, 'assets', 'entries.db');
  print('Writing to: $path.');
  sqfliteFfiInit();
  var db = await databaseFactoryFfi.openDatabase(path);
  await db.execute('''DROP TABLE $tableName''');
  await db.execute('''CREATE TABLE $tableName (
    $URL_ENCODED_HEADWORD STRING NOT NULL PRIMARY KEY,
    $ENTRY_ID INTEGER NOT NULL,
    $HEADWORD STRING NOT NULL,
    $RUN_ON_PARENTS STRING,
    $HEADWORD_ABBREVIATIONS STRING,
    $ALTERNATE_HEADWORDS String,
    $HEADWORD$WITHOUT_DIACRITICAL_MARKS STRING NOT NULL,
    $RUN_ON_PARENTS$WITHOUT_DIACRITICAL_MARKS STRING,
    $HEADWORD_ABBREVIATIONS$WITHOUT_DIACRITICAL_MARKS STRING,
    $ALTERNATE_HEADWORDS$WITHOUT_DIACRITICAL_MARKS String,
    entry_blob STRING NOT NULL
  )''');
  var batch = db.batch();
  for (var entry in entries) {
    var entryRecord = {
      URL_ENCODED_HEADWORD: entry.urlEncodedHeadword,
      ENTRY_ID: entry.entryId,
      HEADWORD: entry.headwordText,
      RUN_ON_PARENTS: entry.runOnParents.join(' | '),
      HEADWORD_ABBREVIATIONS:
          entry.allHeadwords.map((h) => h.abbreviation).join(' | '),
      ALTERNATE_HEADWORDS:
          entry.alternateHeadwords.map((alt) => alt.headwordText).join(' | '),
      HEADWORD + WITHOUT_DIACRITICAL_MARKS:
          entry.headwordText.withoutDiacriticalMarks,
      RUN_ON_PARENTS + WITHOUT_DIACRITICAL_MARKS:
          entry.runOnParents.map((p) => p.withoutDiacriticalMarks).join(' | '),
      HEADWORD_ABBREVIATIONS + WITHOUT_DIACRITICAL_MARKS: entry.allHeadwords
          .map((h) => h.abbreviation.withoutDiacriticalMarks)
          .join(' | '),
      ALTERNATE_HEADWORDS + WITHOUT_DIACRITICAL_MARKS: entry.alternateHeadwords
          .map((alt) => alt.headwordText.withoutDiacriticalMarks)
          .join(' | '),
      'entry_blob': jsonEncode(entry.toJson()),
    };
    if (verbose) print(entryRecord);
    batch.insert(tableName, entryRecord);
  }
  return batch.commit().then((_) => null);
}

MapEntry<String, String> _parseCell(String key, dynamic value) {
  if (!(value is String)) value = '';
  var str = value as String;
  return MapEntry(
      key.trim(),
      str
          .trim()
          .replaceAll(' | ', '|')
          .replaceAll('| ', '|')
          .replaceAll(' |', '|'));
}

List<String> _split(String pluralValue) {
  return pluralValue.isEmpty ? [] : pluralValue.split('|');
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('debug', abbr: 'd', defaultsTo: false)
    ..addFlag('verbose', abbr: 'v', defaultsTo: false)
    ..addFlag('spanish', abbr: 's', defaultsTo: false);
  var argResults = parser.parse(arguments);

  await uploadEntries(argResults['debug'] as bool,
      argResults['verbose'] as bool, argResults['spanish'] as bool);
  print('done?');
}
