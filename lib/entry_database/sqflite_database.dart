import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/entry_database/entry_database.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDatabase extends EntryDatabase {
  Future<Database> _dbFuture = _getDatabase();

  // We need an int that represents no string match and is larger than any
  // conceivable real string match
  static const NO_MATCH = 1000;

  String _sqlRelevancyScore(String searchString, String columnName) {
    final index = 'INSTR(LOWER(" " || $columnName), LOWER(" $searchString"))';
    return '''CASE 
    WHEN $index = 0
    THEN $NO_MATCH
    ELSE 1000*INSTR(SUBSTR(" " || $columnName || " ", $index + ${searchString.length + 1}), " ") + LENGTH($columnName)
    END''';
  }

  @override
  Stream<Entry> getEntries(
    TranslationMode translationMode, {
    @required String searchString,
    @required int startAfter,
    @required SearchOptions searchOptions,
  }) async* {
    int offset = startAfter;
    var db = await _dbFuture;
    String orderByClause;
    final suffix = searchOptions.ignoreAccents ? WITHOUT_DIACRITICAL_MARKS : '';
    if (searchOptions.ignoreAccents)
      searchString = searchString.withoutDiacriticalMarks;
    switch (searchOptions.sortBy) {
      case SortOrder.relevance:
        orderByClause = '${_sqlRelevancyScore(searchString, HEADWORD)}, '
            '${_sqlRelevancyScore(searchString, HEADWORD_ABBREVIATIONS)}, '
            '${_sqlRelevancyScore(searchString, ALTERNATE_HEADWORDS)}, '
            'headword';
        break;
      case SortOrder.alphabetical:
        orderByClause = 'headword';
        break;
    }
    while (true) {
      var snapshot = await db.query(
        translationMode == TranslationMode.English ? ENGLISH : SPANISH,
        where:
            '(${_sqlRelevancyScore(searchString, HEADWORD + suffix)} != $NO_MATCH '
            'OR ${_sqlRelevancyScore(searchString, HEADWORD_ABBREVIATIONS + suffix)} != $NO_MATCH '
            'OR ${_sqlRelevancyScore(searchString, ALTERNATE_HEADWORDS + suffix)} != $NO_MATCH) '
            'AND url_encoded_headword > "$startAfter"',
        orderBy: orderByClause,
        limit: 20,
        offset: offset,
      );
      if (snapshot.isEmpty) {
        return;
      }
      for (var entry in snapshot.map(_rowToEntry)) {
        yield entry;
        offset++;
      }
    }
  }

  @override
  Future<Entry> getEntry(
      TranslationMode translationMode, String urlEncodedHeadword) async {
    var db = await _dbFuture;
    var entry = _rowToEntry(await db
        .query(
          translationMode == TranslationMode.English ? ENGLISH : SPANISH,
          where: 'url_encoded_headword = "$urlEncodedHeadword"',
          limit: 1,
        )
        .then((value) => value.isEmpty ? null : value.single));
    if (entry == null) print('Could not find entry $urlEncodedHeadword!');
    return entry;
  }

  Entry _rowToEntry(Map<String, dynamic> snapshot) {
    return snapshot == null
        ? null
        : Entry.fromJson(jsonDecode(snapshot['entry_blob']));
  }
}

Future<Database> _getDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "$ENTRIES.db");

  // Check if the database exists
  var exists = await databaseExists(path);

  if (!exists || true) {
    // Should happen only the first time you launch your application
    print("Creating new copy from asset");

    // Make sure the parent directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (e) {
      print(e);
    }

    // Copy from asset
    ByteData data = await rootBundle.load(join("assets", "$ENTRIES.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    print("Opening existing database");
  }
  // open the database
  return await openDatabase(path, readOnly: true);
}
