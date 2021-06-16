import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

OverlayEntry? _entry;

Future<void> showSwipeTutorial(
  BuildContext context,
  PageController controller,
) async {
  return;
  if (_entry == null) {
    _entry = _getOverlayEntry(context, controller);
    await Future<void>.delayed(const Duration(milliseconds: 0));
    Overlay.of(context, rootOverlay: true)!.insert(_entry!);
  }
}

OverlayEntry _getOverlayEntry(
  BuildContext outerContext,
  PageController controller,
) {
  final DictionaryPageModel pageModel =
      DictionaryPageModel.readFrom(outerContext);
  return OverlayEntry(
    builder: (context) {
      return PageView(
        children: [pageModel.englishPageModel, pageModel.spanishPageModel]
            .map((translationPage) {
          final String direction = translationPage.isEnglish ? 'left' : 'right';
          final String curr = translationPage.isEnglish ? 'english' : 'spanish';
          final String opp = translationPage.isEnglish ? 'spanish' : 'english';
          return Container(
            color: Colors.black38,
            width: MediaQuery.of(outerContext).size.width / 4,
            height: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swipe),
                Text(
                  '''Swipe $direction for
$opp mode''',
                  style: Theme.of(outerContext).textTheme.bodyText1!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
}
