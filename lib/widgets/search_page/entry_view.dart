// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/pages/page_header.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/util/entry_utils.dart';
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
        if (entry.isNotFound) {
          return _EntryNotFoundView(headword: entry.headword.text);
        }
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
      data: Theme.of(context).copyWith(
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

class _EntryNotFoundView extends StatelessWidget {
  const _EntryNotFoundView({
    Key? key,
    required this.headword,
  }) : super(key: key);

  final String headword;

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      header: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.headline1!,
        child: Text('${i18n.invalidEntry.get(context)}: \'$headword\''),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(kPad),
        child: Padding(
          padding: const EdgeInsets.all(kPad / 2),
          child: Text(
            i18n.reportBug.get(context),
            style: const TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () {
          DictionaryApp.feedback
              .showFeedback(extraText: 'Invalid Headword: $headword');
        },
      ),
    );
  }
}
