import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/util/default_map.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/search_page/page_header.dart';

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
        _buildTable(context, _constructTranslationMap(_entry)),
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
                DictionaryPageModel.readFrom(context)
                    .onHeadwordSelected(context, Entry.urlEncode(headword));
              },
          ),
          if (headword != _entry.related.last) TextSpan(text: ', '),
        ];
      },
    ).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 48.0),
      bold1Text(context, 'Related'),
      Divider(),
      RichText(
          text: TextSpan(
              children: relatedSpans,
              style: Theme.of(context).textTheme.bodyText1)),
    ]);
  }

  Widget _buildEditorialNotes(BuildContext context) {
    var notes = _entry.translations
        .where((t) => t.editorialNote != null && t.editorialNote != '')
        .map((t) => editorialText(context, t.editorialNote!));
    if (notes.isEmpty) return Container();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 48.0),
          bold1Text(context, "Editorial Notes"),
          Divider(),
        ]..addAll(notes));
  }

  Widget _buildTable(
      BuildContext context, Map<String, List<Translation>> translationMap) {
    return Table(
        columnWidths: {
          0: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: _buildTranslations(context, translationMap));
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
      BuildContext context, Map<String, List<Translation>> translationMap) {
    List<TableRow> partOfSpeechTableRows = [];
    translationMap.forEach((partOfSpeech, translations) {
      partOfSpeechTableRows
          .add(_buildPartOfSpeechTableRow(context, partOfSpeech, translations));
    });
    return partOfSpeechTableRows;
  }

  TableRow _buildPartOfSpeechTableRow(BuildContext context, String partOfSpeech,
      List<Translation> translations) {
    String? parenthetical;
    final hasParenthetical = translations
        .any((t) => t.dominantHeadwordParentheticalQualifier != null);
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
                        parentheticalText(context, parenthetical),
                      if (!parentheticalChanged) SizedBox(height: 5.0),
                      _translationContent(context, t, hasParenthetical),
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
      BuildContext context, Translation translation, bool indent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Indent(
              child: translationLine(context, translation),
              size: indent ? null : 0.0),
          Indent(
            child: Indent(
              child: abbreviationLine(
                  context,
                  translation.translationAbbreviation,
                  _preview,
                  SearchPageModel.of(context).searchString),
            ),
          ),
          examplePhraseText(context, translation.examplePhrases),
          SizedBox(height: 0.0),
        ],
      ),
    );
  }
}
