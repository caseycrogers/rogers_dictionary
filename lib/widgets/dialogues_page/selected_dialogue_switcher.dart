// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:implicit_navigator/implicit_navigator.dart';

// Project imports:
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';
import 'package:rogers_dictionary/widgets/dialogues_page/chapter_view.dart';
import 'package:rogers_dictionary/widgets/dialogues_page/table_of_contents_view.dart';

class SelectedDialogueSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dialoguesModel = TranslationModel.of(context).dialoguesPageModel;
    return ImplicitNavigator.fromValueNotifier<DialogueChapter?>(
      key: const PageStorageKey('dialogue_listenable_navigator'),
      maintainHistory: true,
      maintainState: false,
      valueNotifier: dialoguesModel.selectedChapterNotifier,
      builder: (context, selectedChapter, _, __) => selectedChapter == null
          ? TableOfContentsView()
          : ChapterView(
              chapter: selectedChapter,
              initialSubChapter: dialoguesModel.selectedSubChapter,
            ),
      getDepth: (selectedChapter) => selectedChapter == null ? 0 : 1,
    );
  }
}
