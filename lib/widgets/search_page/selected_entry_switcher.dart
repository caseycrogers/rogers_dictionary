import 'package:flutter/material.dart';

import 'package:implicit_navigator/implicit_navigator.dart';

import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/util/layout_picker.dart';
import 'package:rogers_dictionary/widgets/translation_mode_switcher.dart';

import 'entry_list.dart';
import 'entry_view.dart';

class SelectedEntrySwitcher extends StatefulWidget {
  const SelectedEntrySwitcher({
    Key? key,
  }) : super(key: key);

  @override
  _SelectedEntrySwitcherState createState() => _SelectedEntrySwitcherState();
}

class _SelectedEntrySwitcherState extends State<SelectedEntrySwitcher> {
  ImplicitNavigatorState<SelectedEntry?>? _navigator;

  @override
  void initState() {
    super.initState();
    DictionaryModel.instance.translationModel
        .addListener(_onTranslationModeChanged);
  }

  @override
  void dispose() {
    DictionaryModel.instance.translationModel
        .removeListener(_onTranslationModeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ImplicitNavigator.fromValueNotifier<SelectedEntry?>(
      // Used to ensure the navigator knows when to display an animation.
      key: _getKey(context),
      maintainHistory: true,
      maintainState: false,
      takeFocus: false,
      valueNotifier: SearchModel.of(context).currSelectedEntry,
      // Ensure that a base page is in the history on opposite headword.
      initialHistory: const [
        ValueHistoryEntry(0, null),
      ],
      builder: (context, selectedEntry, _, __) {
        _navigator = ImplicitNavigator.of<SelectedEntry?>(context);
        if (selectedEntry == null) {
          if (isBigEnoughForAdvanced(context)) {
            return Container(
              color: Theme.of(context).colorScheme.background,
            );
          }
          return EntryList(
            key: PageStorageKey('${SearchModel.of(context).mode}'
                '_${SearchModel.of(context).isBookmarkedOnly}'
                '_entry_list'),
          );
        }
        return EntryViewPage(selectedEntry: selectedEntry);
      },
      getDepth: (selectedEntry) {
        if (selectedEntry == null) {
          return 0;
        }
        switch (selectedEntry.referrer) {
          case null:
          case SelectedEntryReferrer.oppositeHeadword:
            return 1;
          // Related headwords are a special case where the back button goes to
          // the last selected entry.
          case SelectedEntryReferrer.relatedHeadword:
            return null;
        }
      },
      onPop: (selectedEntry, prevEntry) {
        if (selectedEntry != null &&
            selectedEntry.referrer == SelectedEntryReferrer.oppositeHeadword) {
          DictionaryModel.instance.onTranslationModeChanged(context);
        }
      },
    );
  }

  void _onTranslationModeChanged() {
    _navigator!.canPop = isCurrentTranslationPage(context);
  }
}

PageStorageKey _getKey(BuildContext context) {
  final String tabString =
      SearchModel.of(context).isBookmarkedOnly ? 'bookmarks' : 'search';
  return PageStorageKey<String>(
    '$tabString'
    '_selected_entry_listenable_navigator_'
    '${SearchModel.of(context).mode}',
  );
}
