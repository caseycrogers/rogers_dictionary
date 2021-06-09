import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:rogers_dictionary/entry_database/database_constants.dart';
import 'package:rogers_dictionary/protobufs/database_version.pb.dart';
import 'package:rogers_dictionary/entry_database/entry_builders.dart';

Future<void> mapTranslations() async {
  final String versionPath = join('assets', 'database_version.json');
  final DatabaseVersion version = VersionUtils.fromDisk(File(versionPath));
  final path = join(
    Directory.current.path,
    'assets',
    '${DICTIONARY_DB}V${version.versionString}.db',
  );
  print('Writing to: $path.');
  sqfliteFfiInit();
  final Database db = await databaseFactoryFfi.openDatabase(path);
  final Batch batch = db.batch();
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('debug', abbr: 'd', defaultsTo: false)
    ..addFlag('verbose', abbr: 'v', defaultsTo: false)
    ..addFlag('spanish', abbr: 's', defaultsTo: false);
  final argResults = parser.parse(arguments);

  await mapTranslations();
  print('done?');
}
