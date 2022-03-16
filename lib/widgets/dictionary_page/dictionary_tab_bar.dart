import 'package:flutter/material.dart';

import 'package:rogers_dictionary/util/collection_utils.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab.dart';

class DictionaryTabBar extends StatelessWidget {
  const DictionaryTabBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      alignment: Alignment.topCenter,
      child: TabBar(
        labelColor: AdaptiveMaterial.onColorOf(context),
        labelPadding: const EdgeInsets.symmetric(horizontal: 2 * kPad),
        tabs: DictionaryTab.values.asMap().mapDown((index, tab) {
          return DictionaryTabEntry(
            index: index,
            icon: Icon(tabToIcon(tab)),
            text: tabToText(context, tab),
          );
        }).toList(),
        isScrollable: true,
        indicator: const BoxDecoration(),
      ),
    );
  }
}
