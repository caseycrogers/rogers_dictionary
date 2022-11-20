// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/translation_mode.dart';
import 'package:rogers_dictionary/models/translation_model.dart';

class TranslationModeSwitcher extends StatefulWidget {
  const TranslationModeSwitcher({
    required this.child,
    this.header,
  });

  final Widget child;

  final Widget? header;

  @override
  _TranslationModeSwitcherState createState() =>
      _TranslationModeSwitcherState();
}

class _TranslationModeSwitcherState extends State<TranslationModeSwitcher> {
  PageController? _controller;

  @override
  void didChangeDependencies() {
    if (_controller == null) {
      final DictionaryModel dictionaryModel = DictionaryModel.instance;
      _controller = PageController(
        keepPage: false,
        initialPage:
            translationModeToIndex(dictionaryModel.currTranslationMode),
        viewportFraction: (MediaQuery.of(context).size.width + .25) /
            MediaQuery.of(context).size.width,
      );
      _controller!.addListener(() {
        dictionaryModel.pageOffset.value = _controller!.page!;
      });
      dictionaryModel.translationModel.addListener(() {
        final int targetPage = translationModeToIndex(
            dictionaryModel.translationModel.value.translationMode);
        // If the controller isn't attached yet then the PageView will be
        // properly constructed via initialPage.
        if (!_controller!.hasClients ||
            _controller!.page!.round() == targetPage) {
          return;
        }
        _controller!.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.header != null) widget.header!,
        Expanded(child: pages(context)),
      ],
    );
  }

  Widget pages(BuildContext context) {
    final DictionaryModel dictionaryModel = DictionaryModel.instance;
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<bool>(
          valueListenable: DictionaryModel.instance.isDark,
          builder: (context, isDark, _) {
            return PageView(
              controller: _controller,
              onPageChanged: (int index) => DictionaryModel.instance
                  .onTranslationModeChanged(indexToTranslationMode(index)),
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: DictionaryApp.schemeFor(
                      TranslationMode.English,
                      isDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        key: const PageStorageKey<TranslationMode>(
                          TranslationMode.English,
                        ),
                        child: TranslationModelProvider(
                          translationModel: dictionaryModel.englishPageModel,
                          child: widget.child,
                        ),
                      ),
                      const SizedBox(width: .25),
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: DictionaryApp.schemeFor(
                      TranslationMode.Spanish,
                      isDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: .25),
                      Expanded(
                        key: const PageStorageKey<TranslationMode>(
                          TranslationMode.Spanish,
                        ),
                        child: TranslationModelProvider(
                          translationModel: dictionaryModel.spanishPageModel,
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class TranslationModelProvider extends StatelessWidget {
  const TranslationModelProvider({
    Key? key,
    required this.translationModel,
    required this.child,
  }) : super(key: key);

  final TranslationModel translationModel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

bool isCurrentTranslationPage(BuildContext context) {
  return TranslationModel.of(context) ==
      DictionaryModel.instance.currTranslationModel;
}
