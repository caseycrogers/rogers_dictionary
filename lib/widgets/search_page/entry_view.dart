import 'package:flutter/material.dart';

import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/pages/page_header.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/search_page/editorial_notes_view.dart';
import 'package:rogers_dictionary/widgets/search_page/headword_view.dart';
import 'package:rogers_dictionary/widgets/search_page/related_view.dart';
import 'package:rogers_dictionary/widgets/search_page/translation_table_view.dart';

class EntryViewPage extends StatelessWidget {
  const EntryViewPage({required this.selectedEntry, Key? key})
      : super(key: key);

  final SelectedEntry selectedEntry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: selectedEntry.entry,
      builder: (context, AsyncSnapshot<Entry> snap) {
        if (!snap.hasData || snap.data == null)
          // Only display if loading is slow.
          return Delayed(
            initialChild: Container(),
            child: Container(),
            delay: const Duration(milliseconds: 50),
          );
        final Entry entry = snap.data!;
        return EntryViewModelProvider(
          preview: false,
          entry: entry,
          child: PageHeader(
            header: DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.headline1!,
              child: const HeadwordView(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: kPad),
                TranslationTableView(),
                EditorialNotesView(),
                RelatedView(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EntryViewPreview extends StatelessWidget {
  const EntryViewPreview({required this.entry, Key? key}) : super(key: key);

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
    return Theme(
      data: ThemeData(
        textTheme: Theme.of(context).textTheme.copyWith(
              headline1: baseStyle.asBold,
              headline2: baseStyle.asBold,
              headline3: baseStyle.asBold,
            ),
      ),
      child: EntryViewModelProvider(
        preview: true,
        entry: entry,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HeadwordView(),
            TranslationTableView(),
          ],
        ),
      ),
    );
  }
}

class EntryViewModelProvider extends InheritedWidget {
  EntryViewModelProvider({
    required Entry entry,
    required bool preview,
    required Widget child,
  })  : entryData = EntryViewModel(entry: entry, isPreview: preview),
        super(child: child);

  final EntryViewModel entryData;

  Entry get entry => entryData.entry;

  bool get preview => entryData.isPreview;

  @override
  bool updateShouldNotify(covariant EntryViewModelProvider oldWidget) {
    return oldWidget.entryData.isPreview != entryData.isPreview ||
        oldWidget.entryData.entry != entryData.entry;
  }
}

class EntryViewModel {
  EntryViewModel({required this.entry, required this.isPreview});

  final Entry entry;
  final bool isPreview;

  static EntryViewModel of(BuildContext context) {
    return context
        .findAncestorWidgetOfExactType<EntryViewModelProvider>()!
        .entryData;
  }
}
