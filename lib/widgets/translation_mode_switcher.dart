import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/on_first_launch.dart';
import 'package:rogers_dictionary/util/swipe_tutorial.dart';

class TranslationModeSwitcher extends StatelessWidget {
  const TranslationModeSwitcher({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: pages(context),
      elevation: kHighElevation,
    );
  }

  Widget pages(BuildContext context) {
    final DictionaryPageModel dictionaryModel = DictionaryPageModel.of(context);
    final PageController controller = dictionaryModel.pageController;
    onFirstLaunch(() => showSwipeTutorial(context, controller));
    dictionaryModel.translationPageModel.addListener(() {
      final int targetPage = translationModeToIndex(
          dictionaryModel.translationPageModel.value.translationMode);
      // If the controller isn't attached yet then the PageView will be properly
      // constructed via initialPage.
      if (!controller.hasClients || controller.page!.round() == targetPage)
        return;
      controller.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
    return PageView(
      controller: controller,
      onPageChanged: (int index) => DictionaryPageModel.readFrom(context)
          .onTranslationModeChanged(context, indexToTranslationMode(index)),
      children: [
        Provider<TranslationPageModel>.value(
          value: dictionaryModel.englishPageModel,
          builder: (BuildContext context, _) => Theme(
            data: Theme.of(context)
                .copyWith(primaryColor: primaryColor(TranslationMode.English)),
            child: child,
          ),
        ),
        Provider<TranslationPageModel>.value(
          value: dictionaryModel.spanishPageModel,
          builder: (BuildContext context, _) => Theme(
            data: Theme.of(context)
                .copyWith(primaryColor: primaryColor(TranslationMode.Spanish)),
            child: child,
          ),
        ),
      ],
    );
  }
}
