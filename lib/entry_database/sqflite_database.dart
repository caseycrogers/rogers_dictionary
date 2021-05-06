import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/entry_database/dialogue_chapter.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/entry_database/dictionary_database.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDatabase extends DictionaryDatabase {
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

  String _entryTable(TranslationMode translationMode) =>
      translationMode == TranslationMode.English ? ENGLISH : SPANISH;

  String _favoritesTable(TranslationMode translationMode) =>
      _entryTable(translationMode) + '_favorites';

  @override
  Stream<Entry> getEntries(
    TranslationMode translationMode, {
    required String searchString,
    required int startAfter,
    required SearchSettingsModel searchOptions,
  }) =>
      _getEntries(
        translationMode,
        searchString: searchString,
        startAfter: startAfter,
        searchOptions: searchOptions,
        favoritesOnly: false,
      );

  @override
  Future<Entry> getEntry(
      TranslationMode translationMode, String urlEncodedHeadword) async {
    final db = await _dbFuture;
    final entry = _rowToEntry(
      urlEncodedHeadword,
      translationMode,
      await db.rawQuery('''
 SELECT *,
        EXISTS(SELECT $URL_ENCODED_HEADWORD
               FROM ${_favoritesTable(translationMode)}
               WHERE $URL_ENCODED_HEADWORD = ${_entryTable(translationMode)}.$URL_ENCODED_HEADWORD) AS $IS_FAVORITE
 FROM ${_entryTable(translationMode)}
 WHERE $URL_ENCODED_HEADWORD = "$urlEncodedHeadword";''').then((value) => value
              .isEmpty
          ? null
          : value.single),
    );
    return entry;
  }

  @override
  Stream<Entry> getFavorites(TranslationMode translationMode,
          {required int startAfter}) =>
      _getEntries(
        translationMode,
        searchString: '',
        startAfter: startAfter,
        searchOptions: SearchSettingsModel(SortOrder.alphabetical, true),
        favoritesOnly: true,
      );

  @override
  Future<bool> setFavorite(TranslationMode translationMode,
      String urlEncodedHeadword, bool favorite) async {
    var db = await _dbFuture;
    if (favorite) {
      await db.insert(
        _favoritesTable(translationMode),
        {URL_ENCODED_HEADWORD: urlEncodedHeadword},
      );
    } else {
      await db.delete(
        _favoritesTable(translationMode),
        where: '$URL_ENCODED_HEADWORD = "$urlEncodedHeadword"',
      );
    }
    return super.setFavorite(translationMode, urlEncodedHeadword, favorite);
  }

  Entry _rowToEntry(String headword, TranslationMode translationMode,
      Map<String, Object?>? snapshot) {
    if (snapshot == null) return Entry.notFound(headword);
    assert(snapshot.containsKey(IS_FAVORITE));
    var entry = Entry.fromJson(jsonDecode(snapshot[ENTRY_BLOB]! as String));
    super.setFavorite(
        translationMode, entry.urlEncodedHeadword, snapshot[IS_FAVORITE] == 1);
    return entry;
  }

  DialogueChapter _rowToDialogue(Map<String, dynamic> snapshot) {
    return DialogueChapter.fromJson(jsonDecode(snapshot[DIALOGUE_BLOB]));
  }

  @override
  Stream<DialogueChapter> getDialogues({
    int? startAfter,
  }) async* {
    var db = await _dbFuture;
    int offset = startAfter ?? 0;
    while (true) {
      var query = '''
    SELECT *
    FROM $DIALOGUES_TABLE
    ORDER BY $DIALOGUE_ID ASC
    LIMIT 20
    OFFSET $offset;
      ''';
      var snapshot = await db.rawQuery(query);
      if (snapshot.isEmpty) {
        return;
      }
      for (final dialogue in snapshot.map((snap) => _rowToDialogue(snap))) {
        yield dialogue;
        offset++;
      }
    }
  }

  Stream<Entry> _getEntries(
    TranslationMode translationMode, {
    required String searchString,
    required int startAfter,
    required SearchSettingsModel searchOptions,
    required bool favoritesOnly,
  }) async* {
    var db = await _dbFuture;
    int offset = startAfter;
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
    var whereClause = '''$IS_FAVORITE''';
    if (!favoritesOnly)
      whereClause = '''
(${_sqlRelevancyScore(searchString, HEADWORD + suffix)} != $NO_MATCH
 OR ${_sqlRelevancyScore(searchString, HEADWORD_ABBREVIATIONS + suffix)} != $NO_MATCH
 OR ${_sqlRelevancyScore(searchString, ALTERNATE_HEADWORDS + suffix)} != $NO_MATCH)
AND url_encoded_headword > "$startAfter"''';
    while (true) {
      var query = '''
 SELECT *,
        EXISTS(SELECT $URL_ENCODED_HEADWORD
               FROM ${_favoritesTable(translationMode)}
               WHERE $URL_ENCODED_HEADWORD = ${_entryTable(translationMode)}.$URL_ENCODED_HEADWORD) AS $IS_FAVORITE
 FROM ${_entryTable(translationMode)}
 WHERE $whereClause
 ORDER BY $orderByClause
 LIMIT 20
 OFFSET $offset;
      ''';
      var snapshot = await db.rawQuery(query);
      if (snapshot.isEmpty) {
        return;
      }
      for (var entry
          in snapshot.map((snap) => _rowToEntry('', translationMode, snap))) {
        yield entry;
        offset++;
      }
    }
  }
}

Future<Database> _getDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "$DICTIONARY_DB.db");

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
    ByteData data = await rootBundle.load(join("assets", "$DICTIONARY_DB.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    print("Opening existing database");
  }
  // open the database
  return await openDatabase(path, readOnly: false);
}
