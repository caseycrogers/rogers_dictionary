import 'dart:math';

import 'package:async_list_view/async_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/entry_database/dialogue_chapter.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/util/dialogue_extensions.dart';
import 'package:rogers_dictionary/widgets/buttons/open_page.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';

class ChapterList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dialoguesModel = TranslationPageModel.of(context);
    return Material(
      elevation: 0.0,
      color: Theme.of(context).backgroundColor,
      child: AsyncListView<DialogueChapter>(
        key: PageStorageKey('dialogues'),
        initialData: dialoguesModel.dialoguesPageModel.dialogues,
        stream: dialoguesModel.dialoguesPageModel.dialogueStream,
        itemBuilder: _buildTopic,
      ),
    );
  }

  Widget _buildTopic(BuildContext context,
          AsyncSnapshot<List<DialogueChapter>> snapshot, int index) =>
      Builder(
        builder: (BuildContext context) {
          if (snapshot.hasError) print(snapshot.error);
          if (!snapshot.hasData) return LoadingText();
          var chapter = snapshot.data[index];
          if (index != 0 &&
              chapter.title(context) ==
                  snapshot.data[index - 1].title(context)) {
            return Container();
          }
          if (chapter.hasSubChapters)
            return ExpansionTile(
              title: bold1Text(context, chapter.title(context)),
              subtitle: Text(chapter.oppositeTitle(context),
                  style: TextStyle(color: Colors.grey.shade700)),
              key: _getKey(context, chapter),
              children: chapter.subChapters
                  .map((subChapter) => _clickableHeader(
                        context,
                        true,
                        chapter: chapter,
                        subChapter: subChapter,
                      ))
                  .toList(),
            );
          return _clickableHeader(context, false, chapter: chapter);
        },
      );

  PageStorageKey _getKey(BuildContext context, DialogueChapter dialogue) =>
      PageStorageKey(dialogue.title(context));

  Widget _clickableHeader(
    BuildContext context,
    bool isSubHeader, {
    @required DialogueChapter chapter,
    DialogueSubChapter subChapter,
  }) {
    var dialoguesModel = TranslationPageModel.of(context).dialoguesPageModel;
    return ListTile(
      minLeadingWidth: 0.0,
      leading: isSubHeader
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: Icon(Icons.keyboard_return),
            )
          : null,
      title: Row(
        children: [
          Expanded(
            child: bold1Text(
              context,
              subChapter?.title(context) ?? chapter.title(context),
            ),
          ),
          OpenPage(),
        ],
      ),
      subtitle: Text(
          subChapter?.oppositeTitle(context) ?? chapter.oppositeTitle(context)),
      onTap: () => dialoguesModel.onChapterSelected(chapter, subChapter),
    );
  }
}
