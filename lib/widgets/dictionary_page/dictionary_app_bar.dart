import 'package:flutter/material.dart';

import 'package:implicit_navigator/implicit_navigator.dart';

import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/layout_picker.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';
import 'package:rogers_dictionary/widgets/buttons/help_menu.dart';
import 'package:rogers_dictionary/widgets/buttons/translation_mode_selector.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab.dart';
import 'package:rogers_dictionary/widgets/search_page/search_bar.dart';

import 'dictionary_tab_bar.dart';

class DictionaryAppBar extends StatelessWidget {
  const DictionaryAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveMaterial(
      adaptiveColor: AdaptiveColor.primary,
      child: AppBar(
        leadingWidth: 0,
        elevation: kGroundElevation,
        titleSpacing: 0,
        title: const _DictionaryTopBar(),
      ),
    );
  }
}

class _DictionaryTopBar extends StatelessWidget {
  const _DictionaryTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isBigEnoughForAdvanced(context)) {
      return Row(
        children: const [
          _DictionaryBackButton(),
          TranslationModeSelector(),
          Spacer(),
          HelpMenu(),
        ],
      );
    }
    return Container(
        height: kToolbarHeight,
        child: Row(
          children: [
            const _LandscapeBackAndSearch(),
            const SizedBox(width: kPad),
            const TranslationModeSelector(),
            const Spacer(),
            const DictionaryTabBar(),
            const SizedBox(width: 2),
            Container(
              margin: const EdgeInsets.symmetric(vertical: kPad),
              width: 1,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(.5),
              ),
            ),
            const HelpMenu(),
            const SizedBox(width: kPad),
          ],
        ));
  }
}

class _LandscapeBackAndSearch extends StatelessWidget {
  const _LandscapeBackAndSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _width(context)),
      child: ValueListenableBuilder<DictionaryTab>(
          valueListenable: DictionaryModel.instance.currentTab,
          child: const SearchBar(),
          builder: (context, _, searchBar) {
            if (_shouldDisplaySearchBar(context)) {
              return Row(
                children: [
                  const _DictionaryBackButton(),
                  Expanded(child: searchBar!),
                  const SizedBox(width: kPad),
                ],
              );
            }
            return const _DictionaryBackButton();
          }),
    );
  }

  // Width of the left elements of the screen in landscape mode.
  double _width(BuildContext context) {
    return MediaQuery.of(context).size.width *
        kLandscapeLeftFlex /
        (kLandscapeLeftFlex + kLandscapeRightFlex);
  }

  bool _shouldDisplaySearchBar(BuildContext context) {
    return DictionaryModel.instance.currentTab.value == DictionaryTab.search &&
        isBigEnoughForAdvanced(context);
  }
}

class _DictionaryBackButton extends StatelessWidget {
  const _DictionaryBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: kPad),
      child: const ImplicitNavigatorBackButton(),
    );
  }
}
