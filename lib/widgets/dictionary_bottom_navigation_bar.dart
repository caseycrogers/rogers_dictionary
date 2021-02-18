import 'dart:collection';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';

class DictionaryBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SearchPageModel>(
      valueListenable: BilingualSearchPageModel.of(context).currSearchPageModel,
      builder: (context, currSearchPageModel, _) => Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.black),
        child: GestureDetector(
          onTapUp: (tapUpDetails) {
            int indexFromTapPosition = (tapUpDetails.localPosition.dx /
                    MediaQuery.of(context).size.width)
                .round();
            _handleTap(context, currSearchPageModel, indexFromTapPosition);
          },
          child: BottomNavyBar(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            selectedIndex:
                translationModeToIndex(currSearchPageModel.translationMode),
            backgroundColor: Colors.grey.shade300,
            items:
                _navigationItems(context, currSearchPageModel.translationMode)
                    .values
                    .toList(),
            onItemSelected: (index) =>
                _handleTap(context, currSearchPageModel, index),
          ),
        ),
      ),
    );
  }

  LinkedHashMap<TranslationMode, BottomNavyBarItem> _navigationItems(
      BuildContext context, TranslationMode selectedTranslationMode) {
    return LinkedHashMap.fromEntries(TranslationMode.values.map(
      (mode) => MapEntry(
        mode,
        BottomNavyBarItem(
          icon: AnimatedContainer(
            duration: Duration(milliseconds: 50),
            width: mode == selectedTranslationMode ? 30.0 : 26.0,
            child: Image.asset(
              'assets/images/${mode == TranslationMode.English ? 'us' : 'es'}.png',
            ),
          ),
          title: Text(
            mode == TranslationMode.English ? 'English' : 'Español',
          ),
          activeColor: Colors.black,
          inactiveColor: Colors.transparent,
        ),
      ),
    ));
  }

  void _handleTap(
      BuildContext context, SearchPageModel currSearchPageModel, int index) {
    if (index == translationModeToIndex(currSearchPageModel.translationMode))
      return;
    BilingualSearchPageModel.of(context)
        .onTranslationModeChanged(indexToTranslationMode(index));
  }
}
