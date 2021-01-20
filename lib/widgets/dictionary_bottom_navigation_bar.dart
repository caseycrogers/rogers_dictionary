import 'dart:collection';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class DictionaryBottomNavigationBar extends StatelessWidget {
  final TranslationMode translationMode;

  DictionaryBottomNavigationBar({@required this.translationMode});

  @override
  Widget build(BuildContext context) {
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
          selectedIndex: _translationModeToIndex(context, translationMode),
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
    return LinkedHashMap.fromEntries(TranslationMode.values.map(
      (mode) => MapEntry(
        mode,
        BottomNavyBarItem(
          icon: Image.asset(
            'assets/images/${mode == TranslationMode.English ? 'us' : 'es'}.png',
            height: mode == translationMode ? 30.0 : 26.0,
            width: mode == translationMode ? 30.0 : 26.0,
            fit: BoxFit.fitWidth,
          ),
          title: Text(mode == TranslationMode.English ? 'English' : 'Español'),
          activeColor: Colors.black,
          inactiveColor: Colors.transparent,
        ),
      ),
    ));
  }
}
