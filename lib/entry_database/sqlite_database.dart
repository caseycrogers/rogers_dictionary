import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/entry_database/entry_database.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDatabase extends EntryDatabase {
  Future<Database> _dbFuture = _getDatabase();

  // We need an int that represents no string match and is larger than any
  // conceivable real string match
  static const NO_MATCH = 1000;

  String _sqlRelevancyScore(String searchString, String columnName) {
    final index =
        'CASE WHEN $columnName LIKE "$searchString%" THEN 1 ELSE INSTR(LOWER($columnName), LOWER(" $searchString")) END';
    return '''CASE 
    WHEN $index = 0
    THEN $NO_MATCH
    ELSE INSTR(SUBSTR($columnName || " ", $index + ${searchString.length}), " ")
    END''';
  }

  @override
  Stream<Entry> getEntries({String searchString, String startAfter}) async* {
    int offset = 0;
    var db = await _dbFuture;
    while (true) {
      var snapshot = await db.query(
        'English',
        where: '${_sqlRelevancyScore(searchString, 'headword')} != $NO_MATCH '
            'OR ${_sqlRelevancyScore(searchString, 'headword_abbreviation')} != $NO_MATCH '
            'OR ${_sqlRelevancyScore(searchString, 'alternate_headword')} != $NO_MATCH '
            'AND url_encoded_headword > "$startAfter"',
        orderBy: '${_sqlRelevancyScore(searchString, 'headword')}, '
            '${_sqlRelevancyScore(searchString, 'headword_abbreviation')}, '
            '${_sqlRelevancyScore(searchString, 'alternate_headword')}, '
            'headword',
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
  Future<Entry> getEntry(String urlEncodedHeadword) async {
    var db = await _dbFuture;
    return _rowToEntry(await db
        .query(
          'English',
          where: 'url_encoded_headword = "$urlEncodedHeadword"',
          limit: 1,
        )
        .then((value) => value.isEmpty ? null : value.single));
  }

  Entry _rowToEntry(Map<String, dynamic> snapshot) {
    return Entry.fromJson(jsonDecode(snapshot['entry_blob']));
  }
}

Future<Database> _getDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "entries.db");

  // Check if the database exists
  var exists = await databaseExists(path);

  if (!exists || true) {
    // Should happen only the first time you launch your application
    print("Creating new copy from asset");

    // Make sure the parent directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data = await rootBundle.load(join("assets", "entries.db"));
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
