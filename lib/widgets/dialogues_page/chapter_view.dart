import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/util/constants.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:rogers_dictionary/entry_database/dialogue_chapter.dart';
import 'package:rogers_dictionary/models/dialogues_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/util/dialogue_extensions.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/page_header.dart';

class ChapterView extends StatefulWidget {
  final DialogueChapter chapter;
  final DialogueSubChapter initialSubChapter;

  ChapterView({@required this.chapter, this.initialSubChapter});

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView> {
  ValueNotifier<DialogueSubChapter> currentSubChapter;

  bool _isExpanded = false;

  ItemScrollController _itemScrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    currentSubChapter = ValueNotifier(widget.initialSubChapter);
    _itemPositionsListener.itemPositions.addListener(() {
      // We cannot scroll while the menu is expanded so this means the scrolling
      // is driven by menu selection.
      if (_isExpanded) return;
      currentSubChapter.value = _indexToSubChapter(
          _itemPositionsListener.itemPositions.value.first.index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dialoguesModel = TranslationPageModel.of(context).dialoguesPageModel;
    return Material(
      color: Theme.of(context).backgroundColor,
      child: PageHeader(
        scrollable: false,
        padding: 0.0,
        header: ListTile(
          contentPadding: EdgeInsets.zero,
          title: headline1Text(context, widget.chapter.title(context)),
          subtitle: Text(widget.chapter.oppositeTitle(context)),
        ),
        child: Stack(
          children: [
            Padding(
                child: _dialoguesList(dialoguesModel),
                padding: EdgeInsets.symmetric(horizontal: PAD)),
            GestureDetector(
              onTap: () => setState(() {
                _isExpanded = false;
              }),
              child: AnimatedContainer(
                color: _isExpanded ? Colors.black38 : Colors.transparent,
                duration: Duration(milliseconds: 50),
              ),
            ),
            if (widget.chapter.hasSubChapters) _subChapterSelector(),
            if (widget.chapter.hasSubChapters)
              Container(
                width: double.infinity,
                height: PAD / 2,
                color: Theme.of(context).backgroundColor,
              ),
          ],
        ),
        onClose: () => dialoguesModel.onChapterSelected(null, null),
      ),
    );
  }

  Widget _dialoguesList(DialoguesPageModel dialoguesModel) {
    var subChapterAndDialogue = widget.chapter.subChapters
        .expand((subChapter) => subChapter.dialogues
            .asMap()
            .keys
            .map((i) => MapEntry(subChapter, i)))
        .toList();
    print(
        '${widget.chapter.title(context)}_${widget.initialSubChapter?.title(context) ?? ''}');
    return ScrollablePositionedList.builder(
      key: PageStorageKey(widget.chapter.title(context) +
          (widget.initialSubChapter?.title(context) ?? '')),
      initialScrollIndex: _subChapterToIndex(widget.initialSubChapter),
      itemPositionsListener: _itemPositionsListener,
      itemScrollController: _itemScrollController,
      itemCount: widget.chapter.subChapters.fold<int>(
          0, (sum, subChapter) => sum += subChapter.dialogues.length),
      itemBuilder: (context, index) => Builder(
        builder: (BuildContext context) {
          var subChapter = subChapterAndDialogue[index].key;
          var dialogueIndex = subChapterAndDialogue[index].value;
          var dialogue =
              subChapterAndDialogue[index].key.dialogues[dialogueIndex];
          var dialogueTile = ListTile(
            title: bold1Text(context, dialogue.content(context)),
            subtitle: Text(dialogue.oppositeContent(context)),
            tileColor: dialogueIndex % 2 == 0
                ? Colors.grey.shade200
                : Colors.transparent,
          );
          if (dialogueIndex == 0 && widget.chapter.hasSubChapters)
            return Column(
              children: [
                _subchapterTile(context, subChapter, padding: 0.0),
                dialogueTile,
              ],
            );
          return dialogueTile;
        },
      ),
    );
  }

  Widget _subChapterSelector() => SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: ValueListenableBuilder(
          valueListenable: currentSubChapter,
          builder: (context, _, child) => ExpansionPanelList(
            expansionCallback: (index, _) {
              assert(index == 0,
                  'There should only ever be a single element in this list');
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            children: [
              ExpansionPanel(
                isExpanded: _isExpanded,
                canTapOnHeader: true,
                headerBuilder: (context, isOpen) => ListTile(
                  title: _isExpanded
                      ? Container()
                      : headline2Text(
                          context, currentSubChapter.value.title(context)),
                  subtitle: _isExpanded
                      ? Container()
                      : Text(currentSubChapter.value.oppositeTitle(context)),
                ),
                body: Column(
                  children: widget.chapter.subChapters
                      .map(
                        (subChapter) => _subchapterTile(
                          context,
                          subChapter,
                          isSelected: subChapter == currentSubChapter.value,
                          onTap: () =>
                              Future.delayed(Duration(milliseconds: 50))
                                  .then((_) {
                            currentSubChapter.value = subChapter;
                            setState(() {
                              _isExpanded = false;
                            });
                            return _itemScrollController.jumpTo(
                              index: _subChapterToIndex(subChapter),
                            );
                          }),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _subchapterTile(BuildContext context, DialogueSubChapter subChapter,
          {bool isSelected = false,
          double padding = PAD,
          VoidCallback onTap}) =>
      ListTile(
        tileColor: isSelected ? Theme.of(context).selectedRowColor : null,
        contentPadding: EdgeInsets.symmetric(horizontal: padding),
        title: headline2Text(context, subChapter.title(context)),
        subtitle: Text(
          subChapter.oppositeTitle(context),
          style: isSelected
              ? TextStyle(color: Theme.of(context).accentColor)
              : null,
        ),
        onTap: onTap,
      );

  DialogueSubChapter _indexToSubChapter(int index) {
    int leftOver = index;
    return widget.chapter.subChapters.firstWhere((subChapter) {
      leftOver -= subChapter.dialogues.length;
      return leftOver < 0;
    });
  }

  int _subChapterToIndex(DialogueSubChapter subChapter) {
    return widget.chapter.subChapters
        .takeWhile((s) => s != subChapter)
        .fold(0, (sum, subChapter) => sum += subChapter.dialogues.length);
  }
}
