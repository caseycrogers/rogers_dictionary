import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/dialogue.dart';

import 'package:args/args.dart';
import 'package:df/df.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const WARNING = '(WARN):';
const ERROR = '(ERROR):';

Future<void> uploadDialogues(bool debug, bool verbose) async {
  var filePath = join(
    'lib',
    'scripts',
    'dialogue_database.csv',
  );
  print('Uploading: $filePath.');
  var df = await DataFrame.fromCsv(filePath);

  var rows = df.rows.map((row) => row.map(_parseCell));
  String englishChapter;
  String spanishChapter;
  String englishSubchapter;
  String spanishSubchapter;

  List<Dialogue> dialogues = [];
  var i = 0;

  while (rows.elementAt(i)[ENGLISH_CHAPTER] != 'START') {
    if (i == 100) {
      print(
          "$ERROR Reached row ${i + 2} without finding the start of dialogues, cancelling.");
      return;
    }
    i++;
  }
  i++;
  while (i < rows.length) {
    if ((i + 2) % 500 == 0) print('${i + 2}/${rows.length + 2} complete!');
    Map<String, String> row = rows.elementAt(i);
    if (row.values.every((e) => e == null || e.isEmpty)) {
      print('$WARNING Skipping empty line at ${i + 2}');
      i += 1;
      continue;
    }
    if (row[ENGLISH_CHAPTER].isNotEmpty) {
      if (row[SPANISH_CHAPTER].isEmpty ||
          row[ENGLISH_SUBCHAPTER].isEmpty ||
          row[SPANISH_SUBCHAPTER].isEmpty) {
        print(
            '$ERROR Invalid empty cells for \'${row[ENGLISH_CHAPTER]}\' at row ${i + 2}, skipping.');
        i += 1;
        row = rows.elementAt(i);
        while (row[ENGLISH_CHAPTER].isEmpty) {
          i += 1;
          row = rows.elementAt(i);
        }
        continue;
      }
      englishChapter = row[ENGLISH_CHAPTER];
      spanishChapter = row[SPANISH_CHAPTER];
      englishSubchapter = row[ENGLISH_SUBCHAPTER];
      spanishSubchapter = row[SPANISH_SUBCHAPTER];
    }
    dialogues.add(Dialogue(
      dialogueId: i + 2,
      englishChapter: englishChapter,
      spanishChapter: spanishChapter,
      englishSubChapter: englishSubchapter,
      spanishSubChapter: spanishSubchapter,
      englishContent: row[ENGLISH_CONTENT],
      spanishContent: row[SPANISH_CONTENT],
    ));
    i++;
  }
  assert(dialogues.isNotEmpty, "Did not generate any dialogues!");
  return _uploadSqlFlite(
    dialogues,
    debug,
    verbose,
  );
}

Future<void> _uploadSqlFlite(
  List<Dialogue> dialogues,
  bool debug,
  bool verbose,
) async {
  final path = join(Directory.current.path, 'assets', '$DICTIONARY_DB.db');
  print('Writing to: $path.');
  sqfliteFfiInit();
  var db = await databaseFactoryFfi.openDatabase(path);
  try {
    await db.execute('''DROP TABLE $DIALOGUES_TABLE''');
  } on Exception catch (e) {
    print(e.toString());
  }
  await db.execute('''CREATE TABLE $DIALOGUES_TABLE(
    $DIALOGUE_ID INTEGER NOT NULL  PRIMARY KEY,
    $DIALOGUE_BLOB STRING NOT NULL
  )''');
  var batch = db.batch();
  for (final dialogue in dialogues) {
    var dialogueRecord = {
      DIALOGUE_ID: dialogue.dialogueId,
      DIALOGUE_BLOB: jsonEncode(dialogue.toJson()),
    };
    if (verbose) print(dialogueRecord);
    batch.insert(DIALOGUES_TABLE, dialogueRecord);
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
    ..addFlag('verbose', abbr: 'v', defaultsTo: false);
  var argResults = parser.parse(arguments);

  await uploadDialogues(
      argResults['debug'] as bool, argResults['verbose'] as bool);
  print('done?');
}
