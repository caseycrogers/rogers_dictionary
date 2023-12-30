// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// Project imports:
import 'package:rogers_dictionary/clients/dialogue_builders.dart';
import 'package:rogers_dictionary/models/dialogues_page_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/dialogue_extensions.dart';
import 'package:rogers_dictionary/util/dictionary_progress_indicator.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';

class ChapterView extends StatefulWidget {
  ChapterView({
    required this.chapter,
    this.initialSubChapter,
  }) : super(key: PageStorageKey(chapter.englishTitle));

  final DialogueChapter chapter;
  final DialogueSubChapter? initialSubChapter;

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView> {
  static bool _isExpanded = false;
  bool _inProgrammaticScroll = false;

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _scrollListener = ItemPositionsListener.create();

  static late ValueNotifier<DialogueSubChapter> _currentSubChapter;
  final ValueNotifier<double> _subChapterProgress = ValueNotifier(0);

  late List<MapEntry<DialogueSubChapter, int>> _subChapterAndDialogueIndex;

  @override
  void initState() {
    _currentSubChapter = ValueNotifier(
        widget.initialSubChapter ?? widget.chapter.dialogueSubChapters[0]);
    _scrollListener.itemPositions.addListener(() {
      // Don't update during programmatic scrolling.
      if (_inProgrammaticScroll) {
        return;
      }
      final ItemPosition position = _scrollListener.itemPositions.value
          .reduce((a, b) => a.index < b.index ? a : b);
      final ItemPosition lastPosition = _scrollListener.itemPositions.value
          .reduce((a, b) => a.index > b.index ? a : b);
      final MapEntry<DialogueChapter_SubChapter, double> subChapterAndProgress =
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
    final DialoguesPageModel dialoguesModel =
        TranslationModel.of(context).dialoguesPageModel;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kPad),
          // Required to avoid a weird bug where the scroll view contents bleed
          // above into the list tile.
          color: Theme.of(context).colorScheme.surface,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: DefaultTextStyle(
              style: Theme.of(context).textTheme.displayLarge!,
              child: Text(
                widget.chapter.title(context),
              ),
            ),
            subtitle: Text(widget.chapter.oppositeTitle(context)),
          ),
        ),
        Expanded(
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Ghost tile to push down the scrolling view.
                    if (widget.chapter.hasSubChapters)
                      _SubChapterTile(
                        subChapter: _currentSubChapter.value,
                      ),
                    Expanded(
                      child: _dialoguesList(dialoguesModel),
                    ),
                  ],
                ),
                // Background tap-to-dismiss scrim.
                IgnorePointer(
                  ignoring: !_isExpanded,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isExpanded = false;
                    }),
                    child: AnimatedContainer(
                      color: _isExpanded ? Colors.black38 : Colors.transparent,
                      duration: const Duration(milliseconds: 50),
                    ),
                  ),
                ),
                if (widget.chapter.hasSubChapters) _subChapterSelector(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _subChapterSelector() => ValueListenableBuilder(
        valueListenable: _currentSubChapter,
        builder: (context, _, child) {
          return SingleChildScrollView(
            child: DictionaryProgressIndicator(
              progress: _subChapterProgress,
              style: IndicatorStyle.linear,
              child: ExpansionPanelList(
                expansionCallback: (index, _) {
                  assert(
                    index == 0,
                    'There should only ever be a single element in this list',
                  );
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                elevation: kGroundElevation,
                expandedHeaderPadding: EdgeInsets.zero,
                children: [
                  ExpansionPanel(
                    backgroundColor: Colors.transparent,
                    isExpanded: _isExpanded,
                    canTapOnHeader: true,
                    headerBuilder: (context, isOpen) {
                      return ListTile(
                        tileColor: Colors.transparent,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 2 * kPad),
                        title: Text(
                          _currentSubChapter.value.title(context),
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        subtitle: Text(
                          _currentSubChapter.value.oppositeTitle(context),
                        ),
                        iconColor: Theme.of(context).iconTheme.color,
                      );
                    },
                    body: AdaptiveMaterial(
                      adaptiveColor: AdaptiveColor.surface,
                      child: Column(
                        children: widget.chapter.dialogueSubChapters.map(
                          (subChapter) {
                            return _SubChapterTile(
                              subChapter: subChapter,
                              isSelected:
                                  subChapter == _currentSubChapter.value,
                              onTap: () {
                                _inProgrammaticScroll = true;
                                _scrollController
                                    .scrollTo(
                                      index: _subChapterToIndex(subChapter),
                                      duration:
                                          const Duration(milliseconds: 100),
                                    )
                                    .then(
                                        (_) => _inProgrammaticScroll = false);
                                Future<void>.delayed(
                                  const Duration(milliseconds: 50),
                                ).then((_) {
                                  _currentSubChapter.value = subChapter;
                                  setState(() {
                                    _isExpanded = false;
                                  });
                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _dialoguesList(DialoguesPageModel dialoguesModel) {
    return ScrollablePositionedList.builder(
      key: PageStorageKey(widget.chapter.englishTitle +
          (widget.initialSubChapter?.englishTitle ?? '')),
      initialScrollIndex: _subChapterToIndex(widget.initialSubChapter),
      itemPositionsListener: _scrollListener,
      itemScrollController: _scrollController,
      itemCount: widget.chapter.dialogueSubChapters.fold<int>(
          0, (sum, subChapter) => sum += subChapter.dialogues.length),
      padding: const EdgeInsets.symmetric(
        horizontal: 2 * kPad,
      ),
      itemBuilder: (context, index) => Builder(
        builder: (context) {
          final DialogueChapter_SubChapter subChapter =
              _subChapterAndDialogueIndex[index].key;
          final int dialogueIndex = _subChapterAndDialogueIndex[index].value;
          final DialogueChapter_Dialogue dialogue =
              _subChapterAndDialogueIndex[index].key.dialogues[dialogueIndex];
          final ListTile dialogueTile = ListTile(
            title: Text(
              dialogue.content(context),
              style: Theme.of(context).textTheme.bodyMedium!.asBold,
            ),
            subtitle: OverflowMarkdown(
              dialogue.oppositeContent(context),
            ),
            tileColor: dialogueIndex.isEven
                ? Theme.of(context).colorScheme.background
                : Colors.transparent,
          );
          if (dialogueIndex + 1 == subChapter.dialogues.length &&
              widget.chapter.hasSubChapters &&
              subChapter != widget.chapter.dialogueSubChapters.last)
            return Column(
              children: [
                dialogueTile,
                _SubChapterTile(
                  subChapter: _nextSubChapter(subChapter),
                  horizontalPadding: 0,
                ),
              ],
            );
          return dialogueTile;
        },
      ),
    );
  }

  MapEntry<DialogueSubChapter, double> _subChapterAndProgress(
      ItemPosition first, ItemPosition last) {
    var dialogueIndex = first.index;
    final DialogueChapter_SubChapter subChapter =
        widget.chapter.dialogueSubChapters.firstWhere((subChapter) {
      dialogueIndex -= subChapter.dialogues.length;
      return dialogueIndex < 0;
    });
    dialogueIndex += subChapter.dialogues.length;
    final int lastDialogueIndex = dialogueIndex + (last.index - first.index);
    final bool isLast = subChapter == widget.chapter.dialogueSubChapters.last;
    final double dialoguePercent = -first.itemLeadingEdge /
        (first.itemTrailingEdge - first.itemLeadingEdge);
    final double lastDialoguePercent = 1 -
        ((last.itemTrailingEdge - 1) /
            (last.itemTrailingEdge - last.itemLeadingEdge));
    final double progress =
        (dialogueIndex + dialoguePercent) / subChapter.dialogues.length;
    final double lastProgress =
        (lastDialogueIndex + lastDialoguePercent) / subChapter.dialogues.length;
    if (!isLast) {
      return MapEntry(subChapter, progress);
    }
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
    if (subChapter == null) {
      return 0;
    }
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

class _SubChapterTile extends StatelessWidget {
  const _SubChapterTile({
    Key? key,
    required this.subChapter,
    this.isSelected = false,
    this.onTap,
    this.horizontalPadding = 2 * kPad,
  }) : super(key: key);

  final DialogueSubChapter subChapter;
  final bool isSelected;
  final VoidCallback? onTap;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.displayMedium!,
      child: Container(
        color: isSelected ? Theme.of(context).colorScheme.secondary : null,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          title: Text(
            subChapter.title(context),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          subtitle: Text(
            subChapter.oppositeTitle(context),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
