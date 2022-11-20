// Flutter imports:
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';

// Project imports:
import 'package:rogers_dictionary/util/collection_utils.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab.dart';

class DictionaryTabBar extends StatelessWidget {
  const DictionaryTabBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: kToolbarHeight,
        backgroundColor: AdaptiveMaterial.colorOf(context),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(color: AdaptiveMaterial.onColorOf(context)),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: MaterialStateProperty.resolveWith((properties) {
          if (properties.contains(MaterialState.selected)) {
            return IconThemeData(
              color: AdaptiveMaterial.onColorOf(context),
            );
          }
          return IconThemeData(
            color: AdaptiveMaterial.onColorOf(context)!.withOpacity(.8),
          );
        }),
        indicatorColor: Colors.black38,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: ValueListenableBuilder<DictionaryTab>(
          valueListenable: DictionaryModel.instance.currentTab,
          builder: (context, tab, _) {
            // NavigationBar is messed up in landscape mode because it
            // internally uses `SafeArea`. Strip the media query info here so
            // that the `SafeArea` won't do anything.
            return MediaQuery(
              data: const MediaQueryData(),
              child: NavigationBar(
                selectedIndex: tabToIndex(tab),
                onDestinationSelected: (index) {
                  DictionaryModel.instance.onTabSelected(indexToTab(index));
                },
                destinations: DictionaryTab.values.asMap().mapDown(
                  (index, tab) {
                    return DictionaryTabEntry(
                      index: index,
                      icon: Icon(tabToIcon(tab)),
                      text: tabToText(context, tab),
                    );
                  },
                ).toList(),
              ),
            );
          }),
    );
  }
}
