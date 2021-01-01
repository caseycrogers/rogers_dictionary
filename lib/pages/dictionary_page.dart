import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_search.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_view.dart';
import 'dart:collection';

class DictionaryPage extends StatelessWidget {
  static bool matchesRoute(Uri uri) =>
      ListEquality().equals(uri.pathSegments, ['dictionary']);

  TranslationMode _indexToTranslationMode(BuildContext context, int index) =>
      _navigationItems(context).keys.toList()[index];

  int _translationModeToIndex(
      BuildContext context, TranslationMode translationMode) {
    assert(translationMode != null);
    return _navigationItems(context).keys.toList().indexOf(translationMode);
  }

  @override
  Widget build(BuildContext context) {
    final dictionaryPage = DictionaryPageModel.of(context);
    final primaryColor =
        dictionaryPage.isEnglish ? Colors.indigo : Colors.amber;
    final secondaryColor = dictionaryPage.isEnglish
        ? Colors.indigo.shade100
        : Colors.amber.shade100;

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(color: primaryColor),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Dictionary'),
        ),
        body: _buildOrientedPage(context, EntrySearch()),
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: TextStyle(color: Colors.black),
          unselectedLabelStyle: TextStyle(color: Colors.white),
          currentIndex:
              _translationModeToIndex(context, dictionaryPage.translationMode),
          backgroundColor: secondaryColor,
          items: _navigationItems(context).values.toList(),
          onTap: (index) => DictionaryPageModel.onTranslationModeChanged(
              context, _indexToTranslationMode(context, index)),
        ),
      ),
    );
  }

  Widget _buildOrientedPage(BuildContext context, EntrySearch entrySearch) {
    final animation = ModalRoute.of(context).animation;
    final exitAnimation = ModalRoute.of(context).secondaryAnimation;
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
                Positioned(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(1.0, 0.0),
                            end: dictionaryPageModel.hasSelection
                                ? Offset(0.0, 0.0)
                                : Offset(1.0, 0.0))
                        .animate(animation),
                    child: EntryView.asPage(),
                  ),
                ),
                if (!dictionaryPageModel.hasSelection)
                  Positioned(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0.0, 0.0), end: Offset(-1.0, 0.0))
                          .animate(exitAnimation),
                      // Need to keep entry search in the same position in the widget tree
                      // to maintain state across screen rotation
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
                Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: Colors.transparent),
                Positioned(
                  left: constraints.maxWidth / 3.0,
                  height: constraints.maxHeight,
                  width: 2.0 * constraints.maxWidth / 3.0,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(-1.0, 0.0), end: Offset(-0.0, 0.0))
                        .animate(animation),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        child: EntryView.asPage()),
                  ),
                ),
                Positioned(
                  width: constraints.maxWidth / 3.0,
                  height: constraints.maxHeight,
                  child: SlideTransition(
                    position: AlwaysStoppedAnimation(Offset.zero),
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: entrySearch),
                            VerticalDivider(width: 0.0),
                          ],
                        )),
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

  LinkedHashMap<TranslationMode, BottomNavigationBarItem> _navigationItems(
          BuildContext context) =>
      LinkedHashMap.fromEntries(
        [
          MapEntry(
            TranslationMode.English,
            BottomNavigationBarItem(
              icon: Text('EN', style: _inactiveTextStyle(context)),
              activeIcon: Text('EN', style: _activeTextStyle(context)),
              label: TranslationMode.English.toString().split('.').last,
            ),
          ),
          MapEntry(
            TranslationMode.Spanish,
            BottomNavigationBarItem(
              icon: Text('ES', style: _inactiveTextStyle(context)),
              activeIcon: Text('ES', style: _activeTextStyle(context)),
              label: TranslationMode.Spanish.toString().split('.').last,
            ),
          ),
        ],
      );

  TextStyle _activeTextStyle(BuildContext context) => bold1(context).copyWith(
        color: Colors.black,
        fontSize: normal1(context).fontSize + 2,
      );

  TextStyle _inactiveTextStyle(BuildContext context) =>
      bold1(context).copyWith(color: Colors.black54);
}
