import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/pages/dialogues_page.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab_bar_view.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab_entry.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_top_bar.dart';
import 'favorites_page.dart';
import 'search_page.dart';

enum DictionaryTab {
  search,
  favorites,
  dialogues,
  about,
  settings,
}

String dictionaryTabName(DictionaryTab dictionaryTab) =>
    dictionaryTab.toString().split('.').last;

class DictionaryPage extends StatefulWidget {
  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final ScrollController _controller = ScrollController();

  bool _isDriving = false;
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final DictionaryPageModel dictionaryModel = DictionaryPageModel.of(context);
    return Scaffold(
      body: ValueListenableBuilder<TranslationPageModel>(
        valueListenable: dictionaryModel.translationPageModel,
        child: DictionaryTabBarView(
          children: LinkedHashMap.from(<DictionaryTab, Widget>{
            DictionaryTab.search: SearchPage(),
            DictionaryTab.favorites: FavoritesPage(),
            DictionaryTab.dialogues: DialoguesPage(),
          }),
        ),
        builder: (context, translationPageModel, tabBarView) => Material(
          color: primaryColor(translationPageModel.translationMode),
          child: SafeArea(
            child: NotificationListener<ScrollEndNotification>(
              onNotification: _onScrollEnd,
              child: NestedScrollView(
                controller: _controller,
                headerSliverBuilder: (context, _) => [
                  const SliverAppBar(
                    backgroundColor: Colors.transparent,
                    title: DictionaryTopBar(),
                    automaticallyImplyLeading: false,
                    elevation: kHighElevation,
                  ),
                ],
                body: Column(
                  children: [
                    Expanded(
                      child: tabBarView!,
                    ),
                    Material(
                      color: primaryColor(translationPageModel.translationMode),
                      child: Center(
                        child: TabBar(
                          labelPadding: const EdgeInsets.all(kPad)
                              .add(const EdgeInsets.only(bottom: kPad)),
                          indicatorPadding:
                              const EdgeInsets.only(bottom: 2 * kPad - 4),
                          tabs: [
                            DictionaryTabEntry(
                                selected: Text(i18n.dictionary.cap.get(context),
                                    style: const TextStyle(fontSize: 24)),
                                index: 0),
                            DictionaryTabEntry(
                                selected: Text(i18n.favorites.cap.get(context),
                                    style: const TextStyle(fontSize: 24)),
                                index: 1),
                            DictionaryTabEntry(
                                selected: Text(i18n.dialogues.cap.get(context),
                                    style: const TextStyle(fontSize: 24)),
                                index: 2),
                          ],
                          isScrollable: true,
                          indicator: const UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 3,
                            ),
                            insets: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _onScrollEnd(ScrollEndNotification notification) {
    if (notification.depth != 0 || notification.metrics.atEdge || _isDriving) {
      return false;
    }
    _isDriving = true;
    final ScrollMetrics metrics = notification.metrics;
    Future<void>.delayed(Duration.zero).then(
      (_) => _controller
          .animateTo(
        _expanded ? metrics.minScrollExtent : metrics.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      )
          .then((_) {
        return _isDriving = false;
      }),
    );
    _expanded = !_expanded;
    return true;
  }
}
