import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/entry_database/dialogue_chapter.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/dictionary_navigator/local_history_value_notifier.dart';

class DialoguesPageModel {
  // All static because these can be shared across both translation modes.
  static final LinkedHashSet<DialogueChapter> _dialogues = LinkedHashSet();
  static Stream<DialogueChapter>? _dialogueStream;

  final LocalHistoryValueNotifier<DialogueChapter?> selectedChapter;

  DialogueSubChapter? selectedSubChapter;

  List<DialogueChapter> get dialogues => _dialogues.toList();

  Stream<DialogueChapter> get dialogueStream => _dialogueStream!;

  DialoguesPageModel._(this.selectedChapter) {
    _initializeStream();
  }

  static DialoguesPageModel empty(BuildContext context) =>
      DialoguesPageModel._(LocalHistoryValueNotifier(
        modalRoute: ModalRoute.of(context)!,
        initialValue: null,
      ));

  static void _initializeStream() {
    if (_dialogueStream != null) return;
    Stream<DialogueChapter> stream;
    stream = MyApp.db.getDialogues(startAfter: _dialogues.length);
    _dialogueStream = stream.handleError((error, StackTrace stackTrace) {
      print('ERROR (dialogue stream): $error\n$stackTrace');
    }).map((dialogue) {
      if (!_dialogues.add(dialogue))
        print('WARNING: added duplicate dialogue ${dialogue.englishTitle}. '
            'Set:\n${_dialogues.toList()}');
      return dialogue;
    }).asBroadcastStream();
  }

  void onChapterSelected(
      DialogueChapter? newChapter, DialogueSubChapter? newSubChapter) {
    selectedChapter.value = newChapter;
    selectedSubChapter = newSubChapter;
  }
}
