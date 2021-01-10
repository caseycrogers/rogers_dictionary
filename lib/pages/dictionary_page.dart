import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/widgets/dictionary_bottom_navigation_bar.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_search.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/slide_entrance_exit.dart';

class DictionaryPage extends StatelessWidget {
  static bool matchesRoute(Uri uri) =>
      ListEquality().equals(uri.pathSegments, ['dictionary']);

  @override
  Widget build(BuildContext context) {
    final dictionaryPageModel = DictionaryPageModel.of(context);
    final primaryColor =
        dictionaryPageModel.isEnglish ? Colors.indigo : Colors.amber;
    final secondaryColor = dictionaryPageModel.isEnglish
        ? Colors.indigo.shade100
        : Colors.amber.shade100;

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(color: primaryColor, elevation: 0.0),
        primaryColor: primaryColor,
        accentColor: secondaryColor,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Dictionary'),
        ),
        body: _buildOrientedPage(context, EntrySearch()),
        bottomNavigationBar: DictionaryBottomNavigationBar(),
      ),
    );
  }

  Animation<double> _getAnimation(BuildContext context, bool isSecondary) {
    var dictionaryPageModel = DictionaryPageModel.of(context);
    // Don't display transitions when going between translation modes.
    if (dictionaryPageModel.isTransitionFromTranslationMode)
      return isSecondary ? kAlwaysDismissedAnimation : kAlwaysCompleteAnimation;
    return isSecondary
        ? ModalRoute.of(context).secondaryAnimation
        : ModalRoute.of(context).animation;
  }

  Widget _buildOrientedPage(BuildContext context, EntrySearch entrySearch) {
    final animation = _getAnimation(context, false);
    final exitAnimation = _getAnimation(context, true);
    final dictionaryPageModel = DictionaryPageModel.of(context);

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
                if (dictionaryPageModel.hasSelection)
                  Positioned(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: AnimatedBuilder(
                      animation: exitAnimation,
                      builder: (context, _) => SlideEntranceExit(
                        offset: Offset(
                            dictionaryPageModel.isTransitionToSelectedHeadword
                                ? -1.0
                                : 1.0,
                            0.0),
                        entranceAnimation: animation,
                        exitAnimation: exitAnimation,
                        child: EntryView.asPage(),
                      ),
                    ),
                  ),
                if (!dictionaryPageModel.hasSelection)
                  Positioned(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: SlideEntranceExit(
                      offset: Offset(-1.0, 0.0),
                      entranceAnimation: animation,
                      exitAnimation: exitAnimation,
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
                  animation: exitAnimation,
                  builder: (context, _) => Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      color:
                          exitAnimation.isCompleted || exitAnimation.isDismissed
                              ? Colors.transparent
                              : Theme.of(context).scaffoldBackgroundColor),
                ),
                Positioned(
                  left: constraints.maxWidth / 3.0,
                  height: constraints.maxHeight,
                  width: 2.0 * constraints.maxWidth / 3.0,
                  child: SlideEntranceExit(
                    offset: dictionaryPageModel.hasSelection
                        ? Offset(-1.0, 0.0)
                        : Offset.zero,
                    entranceAnimation: CurvedAnimation(
                        parent: animation, curve: Interval(0.5, 1.0)),
                    exitAnimation: CurvedAnimation(
                      parent: exitAnimation,
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
