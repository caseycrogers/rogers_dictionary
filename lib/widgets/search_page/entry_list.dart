import 'dart:core';

import 'package:async_list_view/async_list_view.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:implicit_navigator/implicit_navigator.dart';

import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/util/layout_picker.dart';
import 'package:rogers_dictionary/widgets/buttons/open_page.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';
import 'package:rogers_dictionary/widgets/no_results_widget.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';

class EntryList extends StatelessWidget {
  const EntryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (DictionaryModel.instance.currentTab.value == DictionaryTab.search) {
      // Only wrap the list in a switcher if this is the search page.
      return const _SwitchOnSearchString();
    }
    return const _EntryList();
  }
}

class _SwitchOnSearchString extends StatefulWidget {
  const _SwitchOnSearchString({Key? key}) : super(key: key);

  @override
  _SwitchOnSearchStringState createState() => _SwitchOnSearchStringState();
}

class _SwitchOnSearchStringState extends State<_SwitchOnSearchString> {
  int _i = 0;
  String _lastSearchString = '';

  @override
  Widget build(BuildContext context) {
    // We need access to this here to ensure entries are cached to the right
    // page storage.
    final SearchModel searchModel = SearchModel.of(context);
    return ImplicitNavigator.fromValueNotifier<String>(
      maintainState: false,
      maintainHistory: true,
      key: const PageStorageKey('search_string_navigator'),
      valueNotifier: searchModel.entrySearchModel.currSearchString,
      getDepth: (searchString) {
        return searchString.isEmpty ? 0 : 1;
      },
      // This breaks if duration is zero.
      transitionDuration: const Duration(milliseconds: 1),
      initialHistory: const [
        // Ensure we have a base page on translation mode changed.
        ValueHistoryEntry(0, ''),
      ],
      builder: (context, searchString, _, __) {
        if (searchString != _lastSearchString) {
          _i += 1;
          _lastSearchString = searchString;
        }
        return _EntryList(
          // Maintains scroll state. Add `i` as a gross hack to ensure that
          // page storage is never reused across changes to search string as
          // this causes weird scroll offsets.
          key: PageStorageKey('entry_list$_i'),
        );
      },
      // We need to reset the cached entries.
      onPop: (poppedValue, currentValue) {
        searchModel.entrySearchModel.entries = [];
      },
    );
  }
}

class _EntryList extends StatefulWidget {
  const _EntryList({Key? key}) : super(key: key);

  @override
  State<_EntryList> createState() => _EntryListState();
}

class _EntryListState extends State<_EntryList> {
  late Stream<Entry> entryStream =
      SearchModel.of(context).entrySearchModel.getEntries();
  late int lastPseudoHash = SearchModel.of(context).entrySearchModel.pseudoHash;

  @override
  Widget build(BuildContext context) {
    final SearchModel searchModel = SearchModel.of(context);
    if (searchModel.isBookmarkedOnly) {
      // We know the bookmarks have changed since the last build, reset the
      // entries.
      searchModel.entrySearchModel.resetEntries();
      entryStream = searchModel.entrySearchModel.getEntries();
    }
    return AsyncListView<Entry>(
      padding: EdgeInsets.zero,
      noResultsWidgetBuilder: (context) {
        return const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2 * kPad),
            child: NoResultsWidget(),
          ),
        );
      },
      stream: entryStream,
      initialData: searchModel.entrySearchModel.entries,
      loadingWidget: Delayed(
        key: const ValueKey('loading'),
        delay: const Duration(milliseconds: 100),
        initialChild: Container(),
        child: const Padding(
          padding: EdgeInsets.all(kPad),
          child: LoadingText(),
        ),
      ),
      itemBuilder: (context, snap, index) {
        if (snap.hasError) {
          FirebaseCrashlytics.instance.recordFlutterError(
            FlutterErrorDetails(
              exception: snap.error!,
              stack: StackTrace.current,
            ),
          );
        }
        if (!snap.hasData) {
          return const LoadingText();
        }
        return Column(
          children: [
            // Put the no results widget at the top if applicable.
            if (index == 0 &&
                searchModel.searchString.isEmpty &&
                !searchModel.isBookmarkedOnly) ...[
              const CollapsingNoResultsWidget(),
              const Divider(height: 0),
            ],
            _EntryRow(entry: snap.data![index]),
            // Put no results widget at top
            if (index != snap.data!.length)
              const Divider(
                thickness: 1,
                height: 1,
              ),
          ],
        );
      },
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    Key? key,
    required this.entry,
  }) : super(key: key);

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final dictionaryModel = DictionaryModel.instance;
    return ValueListenableBuilder<SelectedEntry?>(
      valueListenable: SearchModel.of(context).currSelectedEntry,
      builder: (context, selectedEntry, _) {
        final bool isSelected = entry.uid == selectedEntry?.headword;
        final bool shouldHighlight =
            isBigEnoughForAdvanced(context) && isSelected;
        return InkWell(
            child: Material(
              color: shouldHighlight
                  ? Theme.of(context).selectedRowColor
                  : Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2 * kPad),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: kPad,
                        ),
                        child: EntryViewPreview(entry: entry),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: kPad,
                      ),
                      child: OpenPage(),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
            ),
            onTap: isSelected
                ? null
                : () {
                    dictionaryModel.onEntrySelected(context, entry);
                  });
      },
    );
  }
}
