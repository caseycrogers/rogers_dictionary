import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:implicit_navigator/implicit_navigator.dart';

import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';
import 'package:rogers_dictionary/widgets/dialogues_page/chapter_list.dart';
import 'package:rogers_dictionary/widgets/dialogues_page/chapter_view.dart';

class SelectedDialogueSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dialoguesModel = TranslationModel.of(context).dialoguesPageModel;
    return ImplicitNavigator.fromValueNotifier<DialogueChapter?>(
      key: const PageStorageKey('dialogue_listenable_navigator'),
      maintainHistory: true,
      valueNotifier: dialoguesModel.selectedChapterNotifier,
      builder: (context, selectedChapter, _, __) => selectedChapter == null
          ? ChapterList()
          : ChapterView(
              chapter: selectedChapter,
              initialSubChapter: dialoguesModel.selectedSubChapter,
            ),
      getDepth: (selectedChapter) => selectedChapter == null ? 0 : 1,
    );
  }
}
