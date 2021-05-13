import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:rogers_dictionary/dictionary_navigator/animated_listenable_switcher.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';
import 'package:rogers_dictionary/widgets/dialogues_page/chapter_view.dart';
import 'package:rogers_dictionary/widgets/dialogues_page/chapter_list.dart';

class SelectedDialogueSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dialoguesModel = TranslationPageModel.of(context).dialoguesPageModel;
    return AnimatedListenableSwitcher<DialogueChapter?>(
      valueListenable: dialoguesModel.selectedChapter,
      builder: (context, selectedChapter, _) => selectedChapter == null
          ? ChapterList()
          : ChapterView(
              chapter: selectedChapter,
              initialSubChapter: dialoguesModel.selectedSubChapter,
            ),
    );
  }
}
