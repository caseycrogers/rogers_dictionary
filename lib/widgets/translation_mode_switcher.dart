import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/util/constants.dart';

class TranslationModeSwitcher extends StatelessWidget {
  final Widget child;
  final bool maintainState;

  TranslationModeSwitcher({@required this.child, this.maintainState = true});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: pages(context),
      elevation: kHighElevation,
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
      allowImplicitScrolling: maintainState,
      controller: controller,
      onPageChanged: (index) => DictionaryPageModel.readFrom(context)
          .onTranslationModeChanged(indexToTranslationMode(index)),
      children: [
        Provider<TranslationPageModel>.value(
          value: dictionaryModel.englishPageModel,
          builder: (context, _) => Theme(
            data: Theme.of(context)
                .copyWith(primaryColor: primaryColor(TranslationMode.English)),
            child: child,
          ),
        ),
        Provider<TranslationPageModel>.value(
          value: dictionaryModel.spanishPageModel,
          builder: (context, _) => Theme(
            data: Theme.of(context)
                .copyWith(primaryColor: primaryColor(TranslationMode.Spanish)),
            child: child,
          ),
        ),
      ],
    );
  }
}
