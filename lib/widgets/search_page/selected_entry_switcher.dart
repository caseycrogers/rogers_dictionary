// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:implicit_navigator/implicit_navigator.dart';

// Project imports:
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/util/layout_picker.dart';
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
    DictionaryModel.instance.pageOffset
        .addListener(_maybeToggleNavigatorIsEnabled);
  }

  @override
  void dispose() {
    DictionaryModel.instance.pageOffset
        .removeListener(_maybeToggleNavigatorIsEnabled);
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
            return const NoEntryBackground();
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
    );
  }

  // This uses the page offset to determine which navigator should currently be
  // enabled.
  // Using `currTranslationModel` instead causes the back button to jitter
  // because the old active navigator will become inactive before the
  // navigator becomes active when tapping on the `oppositeHeadword` button or
  // tapping (instead of swiping) on the translation mode selector.
  // Using the page offset ensures that the navigator is only toggled at the
  // middle of the page transition when both navigators are visible and thus can
  // both be toggled at once.
  void _maybeToggleNavigatorIsEnabled() {
    // Enable the navigator if it's english and we're viewing the english page
    // (both sub-clauses true) or it's spanish and we're on the spanish page
    // (both sub-clauses are spanish).
    // This will constantly set `isEnabled`, but `isEnabled` is idempotent so
    // this will only change anything when the value changes.
    _navigator!.isEnabled = TranslationModel.of(context).isEnglish ==
        DictionaryModel.instance.pageOffset.value < .5;
  }
}

@visibleForTesting
class NoEntryBackground extends StatelessWidget {
  const NoEntryBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
    );
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
