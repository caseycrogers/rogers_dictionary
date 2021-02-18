import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/util/dictionary_page.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/widgets/dictionary_bottom_navigation_bar.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_search.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/slide_entrance_exit.dart';
import 'package:rogers_dictionary/main.dart';

class SearchPage extends StatelessWidget {
  static bool matchesRoute(Uri uri) =>
      ListEquality().equals(uri.pathSegments, ['search']);

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SearchPageModel>(
      valueListenable: BilingualSearchPageModel.of(context).currSearchPageModel,
      child: Material(child: _searchPages(context), elevation: 4.0),
      builder: (context, currSearchPage, searchPages) {
        Future.delayed(Duration.zero).then((_) {
          var targetPage =
              translationModeToIndex(currSearchPage.translationMode);
          if (_controller.page.round() == targetPage) return;
          _controller.animateToPage(
            translationModeToIndex(currSearchPage.translationMode),
            curve: Curves.easeIn,
            duration: Duration(milliseconds: 200),
          );
        });
        return DictionaryPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: searchPages),
              DictionaryBottomNavigationBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _searchPages(BuildContext context) {
    final bilingualModel = BilingualSearchPageModel.of(context);
    return PageView(
      controller: _controller,
      onPageChanged: (index) => BilingualSearchPageModel.of(context)
          .onTranslationModeChanged(indexToTranslationMode(index)),
      children: [
        Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: primaryColor(TranslationMode.English)),
          child: Provider<SearchPageModel>.value(
            value: bilingualModel.englishPageModel,
            builder: (context, _) => _buildOrientedPage(context, EntrySearch()),
          ),
        ),
        Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: primaryColor(TranslationMode.Spanish)),
          child: Provider<SearchPageModel>.value(
            value: bilingualModel.spanishPageModel,
            builder: (context, _) => _buildOrientedPage(context, EntrySearch()),
          ),
        ),
      ],
    );
  }

  Widget _buildOrientedPage(BuildContext context, EntrySearch entrySearch) {
    final searchPageModel = SearchPageModel.of(context);
    final animation = ModalRoute.of(context).animation;
    final secondaryAnimation = ModalRoute.of(context).secondaryAnimation;

    return LayoutBuilder(
      builder: (context, constraints) {
        switch (MediaQuery.of(context).orientation) {
          case Orientation.portrait:
            return Stack(
              children: [
                Container(
                  color: Colors.transparent,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
                if (searchPageModel.hasSelection)
                  Positioned(
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) => SlideEntranceExit(
                        offset: Offset(
                            searchPageModel.isTransitionToSelectedHeadword
                                ? -1.0
                                : 1.0,
                            0.0),
                        entranceAnimation:
                            searchPageModel.isTransitionFromTranslationMode
                                ? kAlwaysCompleteAnimation
                                : animation,
                        exitAnimation:
                            searchPageModel.isTransitionFromTranslationMode
                                ? kAlwaysDismissedAnimation
                                : secondaryAnimation,
                        child: EntryView.asPage(),
                      ),
                    ),
                  ),
                if (!searchPageModel.hasSelection)
                  Positioned(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: SlideEntranceExit(
                      offset: Offset(-1.0, 0.0),
                      entranceAnimation:
                          searchPageModel.isTransitionFromTranslationMode
                              ? kAlwaysCompleteAnimation
                              : animation,
                      exitAnimation:
                          searchPageModel.isTransitionFromTranslationMode
                              ? kAlwaysDismissedAnimation
                              : secondaryAnimation,
                      child: DecoratedBox(
                        child: Row(
                          children: [
                            Expanded(child: entrySearch),
                          ],
                        ),
                        decoration: BoxDecoration(),
                      ),
                    ),
                  ),
              ],
            );
          case Orientation.landscape:
            return Stack(
              children: [
                AnimatedBuilder(
                  animation: secondaryAnimation,
                  builder: (context, _) => Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      color: secondaryAnimation.isCompleted ||
                              secondaryAnimation.isDismissed
                          ? Colors.transparent
                          : Theme.of(context).scaffoldBackgroundColor),
                ),
                Positioned(
                  left: constraints.maxWidth / 3.0,
                  height: constraints.maxHeight,
                  width: 2.0 * constraints.maxWidth / 3.0,
                  child: SlideEntranceExit(
                    offset: searchPageModel.hasSelection
                        ? Offset(-1.0, 0.0)
                        : Offset.zero,
                    entranceAnimation:
                        searchPageModel.isTransitionFromTranslationMode
                            ? kAlwaysCompleteAnimation
                            : CurvedAnimation(
                                parent: animation, curve: Interval(0.5, 1.0)),
                    exitAnimation:
                        searchPageModel.isTransitionFromTranslationMode
                            ? kAlwaysDismissedAnimation
                            : CurvedAnimation(
                                parent: secondaryAnimation,
                                curve: Interval(0.0, 0.5),
                              ),
                    child: EntryView.asPage(),
                  ),
                ),
                Positioned(
                  width: constraints.maxWidth / 3.0,
                  height: constraints.maxHeight,
                  child: SlideEntranceExit(
                    offset: Offset.zero,
                    entranceAnimation: kAlwaysCompleteAnimation,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: entrySearch),
                          VerticalDivider(width: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          default:
            return Container();
        }
      },
    );
  }
}
