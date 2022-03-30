import 'package:flutter/services.dart';

Future<String> getDatabaseHash() {
  return rootBundle.loadString('assets/database_hash.txt');
}

Future<String> getGitCommit() {
  return rootBundle.loadString('assets/git_commit.txt');
}
