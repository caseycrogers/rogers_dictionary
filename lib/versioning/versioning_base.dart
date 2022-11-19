// Dart imports:
import 'dart:convert';
import 'dart:io';

// Project imports:
import 'package:rogers_dictionary/protobufs/database_version.pb.dart';

extension DatabaseVersionUtilsBase on DatabaseVersion {
  static DatabaseVersion fromDisk(File file) {
    return fromString(file.readAsStringSync());
  }

  static DatabaseVersion fromString(String jsonString) {
    return DatabaseVersion()
      ..mergeFromProto3Json(jsonDecode(jsonString))
      ..freeze();
  }

  void write(File file) {
    file.writeAsStringSync(jsonEncode(toProto3Json()));
  }

  DatabaseVersion incremented() => DatabaseVersion(
        major: major,
        minor: minor,
        patch: patch + 1,
      )..freeze();

  String get versionString => '$major.$minor.$patch';
}
