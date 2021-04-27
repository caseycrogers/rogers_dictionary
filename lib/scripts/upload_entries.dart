import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

import 'package:args/args.dart';
import 'package:df/df.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rogers_dictionary/util/list_utils.dart';

const WARNING = '(WARN):';
const ERROR = '(ERROR):';

Future<void> uploadEntries(bool debug, bool verbose, bool isSpanish) async {
  var filePath = join(
    'lib',
    'scripts',
    'entry_database-${isSpanish ? SPANISH.toLowerCase() : ENGLISH.toLowerCase()}.csv',
  );
  print('Uploading: $filePath.');
  var df = await DataFrame.fromCsv(filePath);

  var rows = df.rows.map((row) => row.map(_parseCell));
  EntryBuilder builder;
  String partOfSpeech;
  String dominantHeadwordParentheticalQualifier;
  var i = 0;
  Map<String, EntryBuilder> entryBuilders = {};

  while (rows.elementAt(i)[HEADWORD] != 'START') {
    if (i == 100) {
      print(
          "$ERROR Reached row ${i + 2} without finding the start of entries, cancelling.");
      return;
    }
    i++;
  }
  i++;
  while (i < 100) {
    if ((i + 2) % 500 == 0) print('${i + 2}/${rows.length + 2} complete!');
    Map<String, String> row = rows.elementAt(i);
    if (row.values.every((e) => e == null || e.isEmpty)) {
      print('$WARNING Skipping empty line at ${i + 2}');
      i += 1;
      continue;
    }
    if (row[HEADWORD].isNotEmpty) {
      if ((row[PART_OF_SPEECH].isEmpty && row[RUN_ON_PARENTS].isEmpty) ||
          row[TRANSLATION].isEmpty) {
        print(
            '$ERROR Invalid empty cells for \'${row[HEADWORD]}\' at row ${i + 2}, skipping.');
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
          if (parent == parents[0] && parent.isEmpty) return;
          entryBuilders[parent]?.addRelated([row[HEADWORD]]) ??
              print(
                  "$WARNING Missing run on parent \'$parent\' for entry \'${row[HEADWORD]}\' at line ${i + 2}");
        });
      }
      builder = EntryBuilder()
          .entryId(i + 2)
          .headword(
              row[HEADWORD],
              _split(row[HEADWORD_ABBREVIATIONS]).get(0, orElse: ''),
              _split(row[HEADWORD_PARENTHETICAL_QUALIFIERS]).get(0, orElse: ''))
          .addRelated(parents);
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
        print('$WARNING Duplicate headword ${row[HEADWORD]} at line ${i + 2}');
      entryBuilders[row[HEADWORD]] = builder;
      partOfSpeech = '';
      dominantHeadwordParentheticalQualifier = '';
    }
    if (row[PART_OF_SPEECH].isNotEmpty) {
      partOfSpeech = row[PART_OF_SPEECH];
      // Reset the qualifier
      dominantHeadwordParentheticalQualifier = '';
      if (Entry.longPartOfSpeech(partOfSpeech).contains('*'))
        print(
            '$WARNING Unrecognized part of speech $partOfSpeech for headword ${row[HEADWORD]} at line ${i + 2}');
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

Future<void> _uploadSqlFlite(
  String tableName,
  List<Entry> entries,
  bool debug,
  bool verbose,
) async {
  final path = join(Directory.current.path, 'assets', '$DICTIONARY_DB.db');
  print('Writing to: $path.');
  sqfliteFfiInit();
  var db = await databaseFactoryFfi.openDatabase(path);
  try {
    await db.execute('''DROP TABLE $tableName''');
  } on Exception catch (e) {
    print(e.toString());
  }
  await db.execute('''CREATE TABLE $tableName(
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
    $ENTRY_BLOB STRING NOT NULL
  )''');
  try {
    await db.execute('''DROP TABLE ${tableName}_favorites''');
  } on Exception catch (e) {
    print(e.toString());
  }
  await db.execute('''CREATE TABLE ${tableName}_favorites(
    $URL_ENCODED_HEADWORD STRING NOT NULL
  )''');
  var batch = db.batch();
  for (var entry in entries) {
    var entryRecord = {
      URL_ENCODED_HEADWORD: entry.urlEncodedHeadword,
      ENTRY_ID: entry.entryId,
      HEADWORD: entry.headwordText,
      RUN_ON_PARENTS: entry.related.join(' | '),
      HEADWORD_ABBREVIATIONS:
          entry.allHeadwords.map((h) => h.abbreviation).join(' | '),
      ALTERNATE_HEADWORDS:
          entry.alternateHeadwords.map((alt) => alt.headwordText).join(' | '),
      HEADWORD + WITHOUT_DIACRITICAL_MARKS:
          entry.headwordText.withoutDiacriticalMarks,
      RUN_ON_PARENTS + WITHOUT_DIACRITICAL_MARKS:
          entry.related.map((p) => p.withoutDiacriticalMarks).join(' | '),
      HEADWORD_ABBREVIATIONS + WITHOUT_DIACRITICAL_MARKS: entry.allHeadwords
          .map((h) => h.abbreviation.withoutDiacriticalMarks)
          .join(' | '),
      ALTERNATE_HEADWORDS + WITHOUT_DIACRITICAL_MARKS: entry.alternateHeadwords
          .map((alt) => alt.headwordText.withoutDiacriticalMarks)
          .join(' | '),
      ENTRY_BLOB: jsonEncode(entry.toJson()),
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
