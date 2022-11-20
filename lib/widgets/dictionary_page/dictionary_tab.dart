// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/i18n.dart' as i18n;

enum DictionaryTab {
  search,
  bookmarks,
  dialogues,
}

DictionaryTab indexToTab(int index) {
  return DictionaryTab.values[index];
}

int tabToIndex(DictionaryTab tab) {
  return DictionaryTab.values.indexOf(tab);
}

IconData tabToIcon(DictionaryTab tab) {
  switch (tab) {
    case DictionaryTab.search:
      return Icons.search;
    case DictionaryTab.bookmarks:
      return Icons.bookmarks_outlined;
    case DictionaryTab.dialogues:
      return Icons.speaker_notes_outlined;
  }
}

String tabToText(BuildContext context, DictionaryTab tab) {
  switch (tab) {
    case DictionaryTab.search:
      return i18n.search.cap.get(context);
    case DictionaryTab.bookmarks:
      return i18n.bookmarks.cap.get(context);
    case DictionaryTab.dialogues:
      return i18n.dialogues.cap.get(context);
  }
}

class DictionaryTabEntry extends StatelessWidget {
  const DictionaryTabEntry({
    required this.icon,
    required this.text,
    required this.index,
  });

  final Widget icon;
  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: icon,
      label: text,
    );
  }
}
