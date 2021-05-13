import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';
import 'package:rogers_dictionary/util/constants.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:rogers_dictionary/entry_database/dialogue_builders.dart';
import 'package:rogers_dictionary/models/dialogues_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/util/dialogue_extensions.dart';
import 'package:rogers_dictionary/pages/page_header.dart';

class ChapterView extends StatefulWidget {
  final DialogueChapter chapter;
  final DialogueSubChapter? initialSubChapter;

  ChapterView({required this.chapter, this.initialSubChapter})
      : super(key: PageStorageKey(chapter.englishTitle));

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView> {
  static const String _kExpandedStateString = 'is_expanded';
  late bool _internalIsExpanded;
  bool _inProgrammaticScroll = false;

  bool get _isExpanded => _internalIsExpanded;

  set _isExpanded(bool value) {
    _internalIsExpanded = value;
    PageStorage.of(context)?.writeState(context, _internalIsExpanded,
        identifier: _kExpandedStateString);
  }

  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _scrollListener = ItemPositionsListener.create();

  late ValueNotifier<DialogueSubChapter> _currentSubChapter;
  final ValueNotifier<double> _subChapterProgress = ValueNotifier(0.0);

  late List<MapEntry<DialogueSubChapter, int>> _subChapterAndDialogueIndex;

  @override
  void initState() {
    _internalIsExpanded = (PageStorage.of(context)?.readState(
          context,
          identifier: _kExpandedStateString,
        ) as bool?) ??
        false;
    _currentSubChapter = ValueNotifier(
        widget.initialSubChapter ?? widget.chapter.dialogueSubChapters[0]);
    _scrollListener.itemPositions.addListener(() {
      // Don't update during programmatic scrolling.
      if (_inProgrammaticScroll) return;
      var position = _scrollListener.itemPositions.value
          .reduce((a, b) => a.index < b.index ? a : b);
      var lastPosition = _scrollListener.itemPositions.value
          .reduce((a, b) => a.index > b.index ? a : b);
      var subChapterAndProgress =
          _subChapterAndProgress(position, lastPosition);
      _currentSubChapter.value = subChapterAndProgress.key;
      _subChapterProgress.value = subChapterAndProgress.value;
    });
    _subChapterAndDialogueIndex = widget.chapter.dialogueSubChapters
        .expand((subChapter) => subChapter.dialogues
            .asMap()
            .keys
            .map((i) => MapEntry(subChapter, i)))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dialoguesModel = TranslationPageModel.of(context).dialoguesPageModel;
    return PageHeader(
      scrollable: false,
      padding: 0.0,
      header: ListTile(
        contentPadding: EdgeInsets.zero,
        title: headline1Text(context, widget.chapter.title(context)),
        subtitle: Text(widget.chapter.oppositeTitle(context)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Ghost tile to push down the scrolling view.
              if (widget.chapter.hasSubChapters)
                _subchapterTile(context, _currentSubChapter.value),
              if (widget.chapter.hasSubChapters) _progressIndicator(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2 * kPad),
                  child: _dialoguesList(dialoguesModel),
                ),
              ),
            ],
          ),
          IgnorePointer(
            ignoring: _isExpanded ? false : true,
            child: GestureDetector(
              onTap: () => setState(() {
                _isExpanded = false;
              }),
              child: AnimatedContainer(
                color: _isExpanded ? Colors.black38 : Colors.transparent,
                duration: Duration(milliseconds: 50),
              ),
            ),
          ),
          if (widget.chapter.hasSubChapters) _subChapterSelector(),
          if (!widget.chapter.hasSubChapters) _progressIndicator(),
        ],
      ),
      onClose: () => dialoguesModel.onChapterSelected(null, null),
    );
  }

  Widget _subChapterSelector() => Container(
        color: Theme.of(context).cardColor,
        child: ValueListenableBuilder(
          valueListenable: _currentSubChapter,
          builder: (context, _, child) => SingleChildScrollView(
            child: ExpansionPanelList(
              expansionCallback: (index, _) {
                assert(index == 0,
                    'There should only ever be a single element in this list');
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              elevation: kGroundElevation.toInt(),
              expandedHeaderPadding: EdgeInsets.zero,
              children: [
                ExpansionPanel(
                  backgroundColor: Colors.transparent,
                  isExpanded: _isExpanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isOpen) => ListTile(
                    title: _isExpanded
                        ? Container()
                        : headline2Text(
                            context, _currentSubChapter.value.title(context)),
                    subtitle: _isExpanded
                        ? Container()
                        : Text(_currentSubChapter.value.oppositeTitle(context)),
                  ),
                  body: Column(
                    children: widget.chapter.dialogueSubChapters
                        .map(
                          (subChapter) => _subchapterTile(
                            context,
                            subChapter,
                            isSelected: subChapter == _currentSubChapter.value,
                            onTap: () {
                              _inProgrammaticScroll = true;
                              _scrollController
                                  .scrollTo(
                                    index: _subChapterToIndex(subChapter),
                                    duration: Duration(milliseconds: 100),
                                  )
                                  .then((_) => _inProgrammaticScroll = false);
                              Future.delayed(Duration(milliseconds: 50))
                                  .then((_) {
                                _currentSubChapter.value = subChapter;
                                setState(() {
                                  _isExpanded = false;
                                });
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _dialoguesList(DialoguesPageModel dialoguesModel) {
    return Builder(
      builder: (BuildContext context) {
        return ScrollablePositionedList.builder(
          key: PageStorageKey(widget.chapter.englishTitle +
              (widget.initialSubChapter?.englishTitle ?? '')),
          initialScrollIndex: _subChapterToIndex(widget.initialSubChapter),
          itemPositionsListener: _scrollListener,
          itemScrollController: _scrollController,
          itemCount: widget.chapter.dialogueSubChapters.fold<int>(
              0, (sum, subChapter) => sum += subChapter.dialogues.length),
          itemBuilder: (context, index) => Builder(
            builder: (context) {
              var subChapter = _subChapterAndDialogueIndex[index].key;
              var dialogueIndex = _subChapterAndDialogueIndex[index].value;
              var dialogue = _subChapterAndDialogueIndex[index]
                  .key
                  .dialogues[dialogueIndex];
              var dialogueTile = ListTile(
                title: bold1Text(context, dialogue.content(context)),
                subtitle: Text(dialogue.oppositeContent(context)),
                tileColor: dialogueIndex % 2 == 0
                    ? Colors.grey.shade200
                    : Colors.transparent,
              );
              if (dialogueIndex + 1 == subChapter.dialogues.length &&
                  widget.chapter.hasSubChapters &&
                  subChapter != widget.chapter.dialogueSubChapters.last)
                return Column(
                  children: [
                    dialogueTile,
                    _subchapterTile(context, _nextSubChapter(subChapter),
                        padding: 0.0),
                  ],
                );
              return dialogueTile;
            },
          ),
        );
      },
    );
  }

  Widget _progressIndicator() => ValueListenableBuilder<double>(
        valueListenable: _subChapterProgress,
        builder: (context, progress, _) => LinearProgressIndicator(
          value: progress,
        ),
      );

  Widget _subchapterTile(
    BuildContext context,
    DialogueSubChapter subChapter, {
    bool isSelected = false,
    double padding = 2 * kPad,
    VoidCallback? onTap,
  }) =>
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

  MapEntry<DialogueSubChapter, double> _subChapterAndProgress(
      ItemPosition first, ItemPosition last) {
    var dialogueIndex = first.index;
    var subChapter =
        widget.chapter.dialogueSubChapters.firstWhere((subChapter) {
      dialogueIndex -= subChapter.dialogues.length;
      return dialogueIndex < 0;
    });
    dialogueIndex += subChapter.dialogues.length;
    var lastDialogueIndex = dialogueIndex + (last.index - first.index);
    var isLast = subChapter == widget.chapter.dialogueSubChapters.last;
    var dialoguePercent = -first.itemLeadingEdge /
        (first.itemTrailingEdge - first.itemLeadingEdge);
    var lastDialoguePercent = 1 -
        ((last.itemTrailingEdge - 1) /
            (last.itemTrailingEdge - last.itemLeadingEdge));
    var progress =
        (dialogueIndex + dialoguePercent) / subChapter.dialogues.length;
    var lastProgress =
        (lastDialogueIndex + lastDialoguePercent) / subChapter.dialogues.length;
    if (!isLast) return MapEntry(subChapter, progress);
    return MapEntry(
      subChapter,
      _weightedAvg(
        progress,
        lastProgress,
        lastProgress *
            (dialogueIndex < 3 ? (dialogueIndex + dialoguePercent) / 3 : 1),
      ),
    );
  }

  double _weightedAvg(double a, double b, double weight) =>
      (1 - weight) * a + weight * b;

  int _subChapterToIndex(DialogueSubChapter? subChapter) {
    if (subChapter == null) return 0;
    return widget.chapter.dialogueSubChapters
        .takeWhile((s) => s != subChapter)
        .fold(0, (sum, subChapter) => sum += subChapter.dialogues.length);
  }

  DialogueSubChapter _nextSubChapter(DialogueSubChapter subChapter) {
    assert(subChapter != widget.chapter.dialogueSubChapters.last);
    return widget.chapter.dialogueSubChapters[
        widget.chapter.dialogueSubChapters.indexOf(subChapter) + 1];
  }
}
