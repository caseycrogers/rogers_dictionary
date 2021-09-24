import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/pages/dialogues_page.dart';
import 'package:rogers_dictionary/util/focus_utils.dart';
import 'package:rogers_dictionary/util/layout_picker.dart';
import 'package:rogers_dictionary/widgets/adaptive_material/adaptive_material.dart';
import 'package:rogers_dictionary/widgets/dictionary_banner_ad.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_app_bar.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab_bar.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab_bar_view.dart';

import 'bookmarks_page.dart';
import 'search_page.dart';

class DictionaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unFocus();
      },
      child: ValueListenableBuilder<TranslationModel>(
        valueListenable: DictionaryModel.instance.translationModel,
        builder: (context, model, tabBarView) {
          return Theme(
            data: Theme.of(context).copyWith(colorScheme: themeOf(model)),
            child: Scaffold(
              body: Column(
                children: [
                  const DictionaryAppBar(),
                  // Intentionally don't wrap this in theme, it'll cause excess
                  // rebuilds.
                  Expanded(
                    child: AdaptiveMaterial(
                      adaptiveColor: AdaptiveColor.surface,
                      child: DictionaryTabBarView(
                        children: LinkedHashMap<DictionaryTab, Widget>.of({
                          DictionaryTab.search: SearchPage(),
                          DictionaryTab.bookmarks: BookmarksPage(),
                          DictionaryTab.dialogues: DialoguesPage(),
                        }),
                      ),
                    ),
                  ),
                  const DictionaryBannerAd(),
                ],
              ),
              bottomNavigationBar: !isBigEnoughForAdvanced(context)
                  ? const DictionaryTabBar()
                  : null,
            ),
          );
        },
      ),
    );
  }
}
