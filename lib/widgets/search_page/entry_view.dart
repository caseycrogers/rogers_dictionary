import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:collection/collection.dart';

import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/default_map.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/pages/page_header.dart';

class EntryView extends StatelessWidget {
  final Entry _entry;
  final bool _preview;

  EntryView._instance(this._entry, this._preview);

  static Widget asPage(BuildContext context) => Builder(
        key: ValueKey(SearchPageModel.of(context).currSelectedHeadword),
        builder: (context) {
          var searchPageModel = SearchPageModel.of(context);
          if (!searchPageModel.hasSelection)
            return Container(color: Theme.of(context).backgroundColor);
          return FutureBuilder(
            future: searchPageModel.currSelectedEntry.value!.entry,
            builder: (context, AsyncSnapshot<Entry> snap) {
              if (!snap.hasData || snap.data == null)
                // Only display if loading is slow.
                return Delayed(
                  initialChild: Container(),
                  child: Container(),
                  delay: Duration(milliseconds: 50),
                );
              var entry = snap.data!;
              return PageHeader(
                header: headwordLine(
                    context, entry, false, searchPageModel.searchString),
                child: EntryView._instance(entry, false),
                onClose: () => DictionaryPageModel.readFrom(context)
                    .onHeadwordSelected(context, ''),
              );
            },
          );
        },
      );

  static Widget asPreview(Entry entry) => EntryView._instance(entry, true);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_preview)
          headwordLine(context, _entry, _preview,
              SearchPageModel.of(context).searchString),
        _buildTable(context),
        if (!_preview) _buildEditorialNotes(context),
        if (!_preview) _buildRelated(context),
      ],
    );
  }

  Widget _buildRelated(BuildContext context) {
    if (_entry.related.isEmpty) return Container();
    List<TextSpan> relatedSpans =
        _entry.related.where((r) => r.isNotEmpty).expand(
      (headword) {
        return [
          TextSpan(
            text: headword,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                DictionaryPageModel.readFrom(context).onHeadwordSelected(
                    context, EntryUtils.urlEncode(headword));
              },
          ),
          if (headword != _entry.related.last) TextSpan(text: ', '),
        ];
      },
    ).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 48.0),
        bold1Text(context, 'Related'),
        Divider(),
        ..._entry.related.where((r) => r.isNotEmpty).map(
              (headword) => TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  minimumSize: MaterialStateProperty.all(Size.zero),
                  visualDensity: VisualDensity.compact,
                ),
                child: OverflowMarkdown(
                  headword,
                  defaultStyle: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.blue),
                ),
                onPressed: () {
                  DictionaryPageModel.readFrom(context).onHeadwordSelected(
                      context, EntryUtils.urlEncode(headword));
                },
              ),
            ),
      ],
    );
  }

  Widget _buildEditorialNotes(BuildContext context) {
    var notes = _entry.translations
        .where((t) => t.editorialNote.isNotEmpty)
        .map((t) => editorialText(context, t.editorialNote));
    if (notes.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 48.0),
        bold1Text(context, "Editorial Notes"),
        Divider(),
        ...notes,
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    return Table(
        columnWidths: {
          0: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: _buildTranslations(context));
  }

  Map<String, List<Translation>> _constructTranslationMap(Entry entry) {
    // Schema:
    // {partOfSpeech: [translation]}
    Map<String, List<Translation>> translationMap = {};
    _entry.translations
        .forEach((t) => translationMap.getOrElse(t.partOfSpeech, []).add(t));
    return translationMap;
  }

  // Return a list of TableRows corresponding to each part of speech.
  List<TableRow> _buildTranslations(
    BuildContext context,
  ) {
    return _entry.translations
        .groupListsBy((t) => t.partOfSpeech)
        .values
        .map((translations) {
      final partOfSpeech = translations.first.partOfSpeech;
      final inflections = translations.first.irregularInflections;
      return _buildPartOfSpeechTableRow(
          context, partOfSpeech, inflections, translations);
    }).toList();
  }

  TableRow _buildPartOfSpeechTableRow(BuildContext context, String partOfSpeech,
      String inflections, List<Translation> translations) {
    String parenthetical = '';
    final hasParenthetical = translations
        .any((t) => t.dominantHeadwordParentheticalQualifier.isNotEmpty);
    if (_preview)
      return TableRow(children: [
        Container(
          child: partOfSpeechText(context, partOfSpeech, _preview),
          alignment: Alignment.centerRight,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: previewTranslationLine(
              context, translations.first, translations.length != 1),
        ),
      ]);
    return TableRow(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            partOfSpeechText(context, partOfSpeech, _preview),
            irregularInflectionsTable(context, inflections),
            Indent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: translations.map((t) {
                  var parentheticalChanged =
                      t.dominantHeadwordParentheticalQualifier != parenthetical;
                  parenthetical = t.dominantHeadwordParentheticalQualifier;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (parentheticalChanged)
                        ...parentheticalTexts(context, parenthetical, false),
                      if (!parentheticalChanged) SizedBox(height: 5.0),
                      _translationContent(
                          context,
                          t,
                          hasParenthetical && parenthetical != '',
                          translations.indexOf(t) + 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _translationContent(
      BuildContext context, Translation translation, bool indent, int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          normal1Text(context, '${i.toString()}. '),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Indent(
                    child: translationLine(context, translation),
                    size: indent ? null : 0.0),
                examplePhraseText(context, translation.examplePhrases),
                SizedBox(height: 0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
