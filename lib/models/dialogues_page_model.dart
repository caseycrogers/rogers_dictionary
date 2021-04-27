import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/dialogue.dart';
import 'package:rogers_dictionary/main.dart';

class DialoguesPageModel {
  final LinkedHashSet<Dialogue> _dialogues;
  ScrollController _scrollController = ScrollController();
  Stream<Dialogue> dialogueStream;

  ScrollController get scrollController => _scrollController;

  List<Dialogue> get dialogues => _dialogues.toList();

  DialoguesPageModel._() : this._dialogues = LinkedHashSet() {
    _initializeStream();
  }

  static DialoguesPageModel empty() => DialoguesPageModel._();

  void _initializeStream() {
    Stream<Dialogue> stream;
    stream = MyApp.db.getDialogues(startAfter: 0);
    _dialogues.clear();
    dialogueStream = stream.map((dialogue) {
      if (!_dialogues.add(dialogue))
        print('WARNING: added duplicate dialogue ${dialogue.englishContent}. '
            'Set:\n${_dialogues.toList()}');
      return dialogue;
    }).asBroadcastStream();
    _scrollController = ScrollController(
        initialScrollOffset:
            _scrollController.hasClients ? _scrollController.offset : 0.0);
  }
}
