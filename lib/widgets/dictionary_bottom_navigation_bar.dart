import 'dart:collection';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class DictionaryBottomNavigationBar extends StatefulWidget {
  @override
  _DictionaryBottomNavigationBarState createState() =>
      _DictionaryBottomNavigationBarState();
}

class _DictionaryBottomNavigationBarState
    extends State<DictionaryBottomNavigationBar> {
  Key _currentHeroTag = UniqueKey();

  Key _getAndIncrementTag(DictionaryPageModel dictionaryPageModel) {
    if (dictionaryPageModel.isTransitionFromTranslationMode) {
      print('should animate');
      return _currentHeroTag;
    }
    _currentHeroTag = ValueKey('foo');
    return _currentHeroTag;
  }

  @override
  Widget build(BuildContext context) {
    var dictionaryPageModel = DictionaryPageModel.of(context);
    return Theme(
      data: Theme.of(context).copyWith(primaryColor: Colors.black),
      child: GestureDetector(
        onTapUp: (tapUpDetails) {
          int indexFromTapPosition = (tapUpDetails.localPosition.dx /
                  MediaQuery.of(context).size.width)
              .round();
          _handleTap(context, indexFromTapPosition);
        },
        child: BottomNavyBar(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          selectedIndex: _translationModeToIndex(
              context, dictionaryPageModel.translationMode),
          backgroundColor: Theme.of(context).accentColor,
          items: _navigationItems(context).values.toList(),
          onItemSelected: (index) => _handleTap(context, index),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, int index) async {
    DictionaryPageModel.onTranslationModeChanged(
        context, _indexToTranslationMode(context, index));
  }

  TranslationMode _indexToTranslationMode(BuildContext context, int index) =>
      _navigationItems(context).keys.toList()[index];

  int _translationModeToIndex(
      BuildContext context, TranslationMode translationMode) {
    assert(translationMode != null);
    return _navigationItems(context).keys.toList().indexOf(translationMode);
  }

  LinkedHashMap<TranslationMode, BottomNavyBarItem> _navigationItems(
      BuildContext context) {
    var isEnglish = DictionaryPageModel.of(context).translationMode ==
        TranslationMode.English;
    return LinkedHashMap.fromEntries(
      [
        MapEntry(
          TranslationMode.English,
          BottomNavyBarItem(
            icon: Text(
              '🇺🇸',
              style: TextStyle(fontSize: isEnglish ? 24.0 : null),
            ),
            title: Text('English'),
            activeColor: Colors.black,
            inactiveColor: Colors.transparent,
          ),
        ),
        MapEntry(
          TranslationMode.Spanish,
          BottomNavyBarItem(
            icon: Text(
              '🇪🇸',
              style: TextStyle(fontSize: !isEnglish ? 24.0 : null),
            ),
            title: Text('Español'),
            activeColor: Colors.black,
            inactiveColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
