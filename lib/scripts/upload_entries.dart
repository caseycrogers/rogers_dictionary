import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:df/df.dart';
import 'package:path/path.dart';

import 'package:rogers_dictionary/clients/database_constants.dart';
import 'package:rogers_dictionary/models/translation_mode.dart';
import 'package:rogers_dictionary/protobufs/database_version.pb.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/collection_utils.dart';
import 'package:rogers_dictionary/util/entry_utils.dart';
import 'package:rogers_dictionary/util/overflow_markdown_base.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _GetBuildersArgs {
  const _GetBuildersArgs({
    required this.sendPort,
    required this.debug,
    required this.verbose,
    required this.isSpanish,
  });

  final SendPort sendPort;
  final bool debug;
  final bool verbose;
  final bool isSpanish;
}

Future<void> _runIsolated(_GetBuildersArgs args) async {
  final Map<String, EntryBuilder> builders =
      await _getBuilders(args.debug, args.verbose, args.isSpanish);
  Isolate.exit(args.sendPort, builders);
}

Future<Map<String, EntryBuilder>> _isolatedGetBuilders(
    bool debug, bool verbose, bool isSpanish) async {
  final ReceivePort port = ReceivePort();
  await Isolate.spawn(
    _runIsolated,
    _GetBuildersArgs(
      sendPort: port.sendPort,
      debug: debug,
      verbose: verbose,
      isSpanish: isSpanish,
    ),
  );
  return await port.first as Map<String, EntryBuilder>;
}

Future<Map<String, EntryBuilder>> _getBuilders(
    bool debug, bool verbose, bool isSpanish) async {
  final String csvPath = join(
    'lib',
    'scripts',
    'entry_database-${isSpanish ? SPANISH : ENGLISH}.csv',
  );
  final DatabaseVersion version = VersionUtils.fromDisk(
    File(join('assets', 'database_version.json')),
  );
  if (!isSpanish) {
    print('Uploading version ${version.versionString} from $csvPath.');
  }
  final DataFrame df = await DataFrame.fromCsv(csvPath);

  final Iterable<Map<String, String>> rows =
      df.rows.map((row) => row.map(_parseCell));
  EntryBuilder? builder;
  String? partOfSpeech;
  String? dominantHeadwordParentheticalQualifier;
  var i = 0;
  final Map<String, EntryBuilder> entryBuilders = {};

  while (rows.elementAt(i)[HEADWORD] != 'START') {
    if (i == 100) {
      throw AssertionError(
          '$ERROR Reached row ${i + 2} without finding the start of entries, '
          'cancelling.');
    }
    i++;
  }
  i++;
  late String uid;
  late String headword;
  while (i < 2000) {
    if ((i + 2) % 500 == 0) {
      print('(${isSpanish ? 'es' : 'en'}): ${i + 2}/${rows.length + 2} '
          'complete!');
    }
    Map<String, String> row = rows.elementAt(i);
    if (row.entries
        .where((e) => e.key.isNotEmpty)
        .every((e) => e.value.isEmpty)) {
      print('$WARNING Skipping empty line at ${i + 2}');
      i += 1;
      continue;
    }
    row.forEach((key, str) {
      if (key != EDITORIAL_NOTE && (str.contains('\n') || str.contains('\r')))
        print('$WARNING field $key at row ${i + 2} contains a line break.'
            ' Field:\n$str');
    });
    if (row[UID]!.isNotEmpty) {
      if (row[HEADWORD]!.isEmpty ||
          row[PART_OF_SPEECH]!.isEmpty ||
          row[TRANSLATION]!.isEmpty) {
        print('$ERROR Invalid empty cells for \'${row[HEADWORD]}\' at row '
            '${i + 2}, skipping.');
        i += 1;
        row = rows.elementAt(i);
        while (row[UID]!.isEmpty) {
          i += 1;
          row = rows.elementAt(i);
        }
        continue;
      }
      void printParentError(String parent, String entry) {
        print('$WARNING Missing related entry \'$parent\' for entry \'$entry\' '
            'at line ${i + 2}');
      }

      uid = row[UID]!;
      headword = row[HEADWORD]!;
      builder = EntryBuilder().uid(uid).orderId(i + 2).headword(
            headword,
            _split(row[HEADWORD_ABBREVIATIONS]!).get(0, orElse: ''),
            _split(row[HEADWORD_PARENTHETICAL_QUALIFIERS]!).get(0, orElse: ''),
          );
      if (row[RELATED_TERMS_TRANSITIVE]!.isNotEmpty) {
        for (final String parent in row[RELATED_TERMS_TRANSITIVE]!
            .split('|')
            .where((p) => p.isNotEmpty)) {
          if (!entryBuilders.containsKey(parent)) {
            printParentError(parent, headword);
          }
          builder.addParent(entryBuilders[parent]!);
        }
      }
      if (row[RELATED_TERMS_INTRANSITIVE]!.isNotEmpty) {
        for (final String related in row[RELATED_TERMS_INTRANSITIVE]!
            .split('|')
            .where((p) => p.isNotEmpty)) {
          if (!entryBuilders.containsKey(related)) {
            printParentError(related, headword);
          }
          builder.addRelated(entryBuilders[related]!);
        }
      }
      _split(row[ALTERNATE_HEADWORDS]!)
          .where((alt) => alt.isNotEmpty)
          .toList()
          .asMap()
          .forEach((j, alternateHeadwordText) {
        // Start from j + 1 because the first was taken by the headword.
        final int index = j + 1;
        builder!.addAlternateHeadword(
          text: alternateHeadwordText,
          gender: _split(row[ALTERNATE_HEADWORD_GENDERS]!).get(j, orElse: ''),
          abbreviation:
              _split(row[HEADWORD_ABBREVIATIONS]!).get(index, orElse: ''),
          namingStandard: _split(row[ALTERNATE_HEADWORD_NAMING_STANDARDS]!)
              .get(j, orElse: ''),
          parentheticalQualifier:
              _split(row[HEADWORD_PARENTHETICAL_QUALIFIERS]!)
                  .get(index, orElse: ''),
        );
      });
      if (entryBuilders.keys.contains(headword))
        print('$WARNING Duplicate headword $headword at line ${i + 2}');
      if (entryBuilders.values.map((e) => e.getUid).contains(uid))
        print('$WARNING Duplicate uid $uid at line ${i + 2}');
      entryBuilders[row[HEADWORD]!] = builder;
      partOfSpeech = '';
      dominantHeadwordParentheticalQualifier = '';
    }
    if (row[PART_OF_SPEECH]!.isNotEmpty) {
      partOfSpeech = row[PART_OF_SPEECH]!;
      // Reset the qualifier
      dominantHeadwordParentheticalQualifier = '';
      if (EntryUtils.longPartOfSpeech(partOfSpeech, false).contains('*'))
        print('$WARNING Unrecognized part of speech $partOfSpeech for headword '
            '${row[HEADWORD]} at line ${i + 2}');
    }
    if (row[DOMINANT_HEADWORD_PARENTHETICAL_QUALIFIER]!.isNotEmpty) {
      dominantHeadwordParentheticalQualifier =
          row[DOMINANT_HEADWORD_PARENTHETICAL_QUALIFIER]!;
    }
    builder!.addTranslation(
      partOfSpeech: partOfSpeech!,
      irregularInflections: _split(row[IRREGULAR_INFLECTIONS]!, pattern: ';'),
      dominantHeadwordParentheticalQualifier:
          dominantHeadwordParentheticalQualifier!,
      translation: row[TRANSLATION]!,
      pronunciationOverride: row[PRONUNCIATION_OVERRIDE]!,
      genderAndPlural: row[GENDER_AND_PLURAL]!,
      namingStandard: row[TRANSLATION_NAMING_STANDARD]!,
      abbreviation: row[TRANSLATION_ABBREVIATION]!,
      parentheticalQualifier: row[TRANSLATION_PARENTHETICAL_QUALIFIER]!,
      disambiguation: row[DISAMBIGUATION]!,
      examplePhrases: _split(row[EXAMPLE_PHRASES]!),
      editorialNote: row[EDITORIAL_NOTE]!,
      rawOppositeHeadword: row[OPPOSITE_HEADWORD]!,
    );
    i++;
  }
  return entryBuilders;
}

void _setOppositeUids(
  Iterable<EntryBuilder> builders,
  Map<String, EntryBuilder> oppositeBuilders,
) {
  return;
  for (final MapEntry<String, Translation> oppEntry
      in builders.expand((b) => b.rawOppositeHeadwords.entries)) {
    final String oppositeHeadword = oppEntry.key;
    final Translation translation = oppEntry.value;
    assert(oppositeHeadword.isNotEmpty);
    EntryBuilder? oppositeEntry;
    if (oppositeHeadword == OPPOSITE_HEADWORD_SENTINEL) {
      oppositeEntry = oppositeBuilders[translation.text];
      if (oppositeEntry == null) {
        print('$WARNING Could not find a headword matching translation '
            '\'${translation.text}\'.');
        continue;
      }
    } else {
      oppositeEntry = oppositeBuilders[oppositeHeadword];
    }
    if (oppositeEntry == null) {
      print('$WARNING Invalid opposite headword \'$oppositeHeadword\' for '
          'translation ${translation.text}.');
      continue;
    }
    translation.oppositeUid = oppositeEntry.getUid;
  }
}

Future<void> uploadEntries(bool debug, bool verbose) async {
  final DatabaseVersion version = VersionUtils.fromDisk(
    File(join('assets', 'database_version.json')),
  );
  print('\n\nReading csv\'s!');
  late final Map<String, EntryBuilder> englishBuilders;
  late final Map<String, EntryBuilder> spanishBuilders;
  await Future.wait([
    _isolatedGetBuilders(debug, verbose, false)
        .then((v) => englishBuilders = v),
    _isolatedGetBuilders(debug, verbose, true).then((v) => spanishBuilders = v),
  ]);
  _setOppositeUids(englishBuilders.values, spanishBuilders);
  _setOppositeUids(spanishBuilders.values, englishBuilders);
  await _uploadSqlFlite(
    version,
    TranslationMode.English,
    englishBuilders.values,
    debug,
    verbose,
  );
  await _uploadSqlFlite(
    version,
    TranslationMode.Spanish,
    spanishBuilders.values,
    debug,
    verbose,
  );
  print('Finished writing ${version.versionString} with '
      '${englishBuilders.length} english entries and ${spanishBuilders.length} '
      'spanish entries.');
}

Future<void> _uploadSqlFlite(
  DatabaseVersion version,
  TranslationMode mode,
  Iterable<EntryBuilder> entries,
  bool debug,
  bool verbose,
) async {
  final path = join(
    Directory.current.path,
    'assets',
    '${DICTIONARY_DB}V${version.versionString}.db',
  );
  final bookmarksPath = join(
    Directory.current.path,
    'assets',
    '$BOOKMARKS_DB.db',
  );
  print('Writing to: $path.');
  sqfliteFfiInit();
  final Database db = await databaseFactoryFfi.openDatabase(path);
  final Database bookmarksDb =
      await databaseFactoryFfi.openDatabase(bookmarksPath);
  final Batch batch = db.batch();
  if (!debug) {
    await wipeTable(db, entryTable(mode));
    await wipeTable(bookmarksDb, bookmarksTable(mode));
    await createEntryTable(db, entryTable(mode));
    await createBookmarksTable(bookmarksDb, bookmarksTable(mode));
  }

  final Set<String> seenUids = {};
  for (final EntryBuilder builder in entries) {
    final Entry entry = builder.build();
    final Map<String, Object> entryRecord = {
      UID: entry.uid.toString(),
      ORDER_ID: entry.orderId,
      HEADWORD: entry.headword.text.searchable,
      HEADWORD_ABBREVIATIONS:
          entry.allHeadwords.map((h) => h.abbreviation).join(' | ').searchable,
      ALTERNATE_HEADWORDS: entry.alternateHeadwords
          .map((alt) => alt.text)
          .join(' | ')
          .searchable,
      IRREGULAR_INFLECTIONS: entry.translations.first.irregularInflections
          // Non-content phrases are italicized in irregular inflections
          .expand((s) => MarkdownBase(s).strip(italics: true))
          .where((s) => s.isNotEmpty)
          .join(' | ')
          .searchable,
      HEADWORD + WITHOUT_OPTIONALS:
          entry.headword.text.withoutOptionals.searchable,
      HEADWORD_ABBREVIATIONS + WITHOUT_OPTIONALS: entry.allHeadwords
          .map((h) => h.abbreviation.withoutOptionals)
          .join(' | ')
          .searchable,
      ALTERNATE_HEADWORDS + WITHOUT_OPTIONALS: entry.alternateHeadwords
          .map((alt) => alt.text.withoutOptionals)
          .join(' | ')
          .searchable,
      IRREGULAR_INFLECTIONS + WITHOUT_OPTIONALS: entry
          .translations.first.irregularInflections
          .expand((s) => MarkdownBase(s).strip(italics: true))
          .map((s) => s.withoutOptionals)
          .where((s) => s.isNotEmpty)
          .join(' | ')
          .searchable,
      ENTRY_BLOB: entry.writeToBuffer(),
    };
    if (entry.headword.text.startsWith('abdo')) {
      //print(entryRecord[ENTRY_BLOB]);
    }
    if (verbose) {
      print(entryRecord.map((key, value) =>
          MapEntry(key, key == ENTRY_BLOB ? entry.toProto3Json() : value)));
      print('');
    }
    final String uid = entryRecord[UID]!.toString();
    if (uid.isEmpty) {
      print('$ERROR Entry \'${entry.headword.text}\' at line ${entry.orderId} '
          'has an empty uid.');
    }
    if (seenUids.contains(uid)) {
      print('$ERROR Entry \'${entry.headword.text}\' at line ${entry.orderId} '
          'has non-unique uid \'$uid\'');
      continue;
    }
    seenUids.add(uid);
    if (!debug) {
      await db.insert(entryTable(mode), entryRecord);
      //batch.insert(entryTable(mode), entryRecord);
    }
    await batch.commit();
  }
}

Future<void> wipeTable(Database db, String tableName) async {
  print('Wiping table \'$tableName\' in db \'$db\'.');
  try {
    await db.execute('''DROP TABLE $tableName''');
  } on Exception catch (e) {
    print(e.toString());
  }
  return;
}

Future<void> createEntryTable(Database db, String tableName) async {
  print('Creating table \'$tableName\' in ${db.path}.');
  await db.execute('''CREATE TABLE $tableName(
    $UID TEXT NOT NULL PRIMARY KEY,
    $ORDER_ID INTEGER NOT NULL,
    $HEADWORD TEXT NOT NULL,
    $HEADWORD_ABBREVIATIONS STRING,
    $ALTERNATE_HEADWORDS TEXT,
    $IRREGULAR_INFLECTIONS TEXT,
    $HEADWORD$WITHOUT_OPTIONALS TEXT NOT NULL,
    $HEADWORD_ABBREVIATIONS$WITHOUT_OPTIONALS TEXT,
    $ALTERNATE_HEADWORDS$WITHOUT_OPTIONALS TEXT,
    $IRREGULAR_INFLECTIONS$WITHOUT_OPTIONALS TEXT,
    $ENTRY_BLOB BLOB NOT NULL
  );''');
  return;
}

Future<void> createBookmarksTable(Database db, String tableName) async {
  print('Creating table $tableName in ${db.path}.');
  await db.execute('''CREATE TABLE $tableName(
    $BOOKMARK_TAG TEXT NOT NULL,
    $UID TEXT NOT NULL
  );''');
  return;
}

MapEntry<String, String> _parseCell(String key, dynamic value) {
  if (!(value is String)) {
    value = '';
  }
  final str = value;
  return MapEntry(
      key.trim(),
      str
          .trim()
          .replaceAll(' | ', '|')
          .replaceAll('| ', '|')
          .replaceAll(' |', '|'));
}

List<String> _split(String pluralValue, {String? pattern}) {
  return pluralValue.isEmpty ? [] : pluralValue.split(pattern ?? '|');
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('debug', abbr: 'd', defaultsTo: false)
    ..addFlag('verbose', abbr: 'v', defaultsTo: false);
  final argResults = parser.parse(arguments);

  await uploadEntries(
    argResults['debug'] as bool,
    argResults['verbose'] as bool,
  );
  print('done?');
}
