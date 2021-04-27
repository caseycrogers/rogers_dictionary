import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

import 'dictionary_bottom_navigation_bar.dart';

class TranslationModeSwitcher extends StatelessWidget {
  final Widget englishChild;
  final Widget spanishChild;

  TranslationModeSwitcher(
      {@required this.englishChild, @required this.spanishChild});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: Material(child: pages(context), elevation: 4.0)),
        DictionaryBottomNavigationBar(),
      ],
    );
  }

  Widget pages(BuildContext context) {
    final dictionaryModel = DictionaryPageModel.of(context);
    final PageController controller = PageController(
      initialPage: translationModeToIndex(
          dictionaryModel.currTranslationPageModel.value.translationMode),
    );
    dictionaryModel.currTranslationPageModel.addListener(() {
      var targetPage = translationModeToIndex(
          dictionaryModel.currTranslationPageModel.value.translationMode);
      // If the controller isn't attached yet then the PageView will be properly
      // constructed via initialPage.
      if (!controller.hasClients || controller.page.round() == targetPage)
        return;
      controller.animateToPage(
        targetPage,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
    return PageView(
      allowImplicitScrolling: true,
      controller: controller,
      onPageChanged: (index) => DictionaryPageModel.readFrom(context)
          .onTranslationModeChanged(indexToTranslationMode(index)),
      children: [
        Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: primaryColor(TranslationMode.English)),
          child: englishChild,
        ),
        Theme(
          data: Theme.of(context)
              .copyWith(primaryColor: primaryColor(TranslationMode.Spanish)),
          child: spanishChild,
        ),
      ],
    );
  }
}
