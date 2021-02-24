import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/util/default_map.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/util/text_utils.dart';

class EntryView extends StatelessWidget {
  final Entry _entry;
  final bool _preview;

  EntryView._instance(this._entry, this._preview);

  static Widget asPage() => Builder(
        builder: (context) {
          var searchPageModel = SearchPageModel.of(context);
          if (!searchPageModel.hasSelection)
            return Container(color: Theme.of(context).backgroundColor);
          return Container(
            color: Theme.of(context).cardColor,
            child: FutureBuilder(
              future: searchPageModel.selectedEntry,
              builder: (context, AsyncSnapshot<Entry> snap) {
                if (!snap.hasData)
                  // Only display if loading is slow.
                  return Delayed(
                    initialChild: Container(),
                    child: Container(),
                    delay: Duration(milliseconds: 50),
                  );
                var entry = snap.data;
                const pad = 24.0;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _iconButton(context),
                          Expanded(
                              child: headwordLine(
                                  context,
                                  entry.headword,
                                  entry.alternateHeadwords,
                                  false,
                                  searchPageModel.searchString)),
                        ],
                      ),
                    ),
                    Divider(indent: pad, endIndent: pad, height: 0.0),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: pad, right: pad, bottom: pad),
                          child: EntryView._instance(entry, false),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );

  static Widget asPreview(Entry entry) => EntryView._instance(entry, true);

  static Widget _iconButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).accentIconTheme.color,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_preview)
          headwordLine(context, _entry.headword, _entry.alternateHeadwords,
              _preview, SearchPageModel.of(context).searchString),
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
                .bodyText1
                .copyWith(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                DictionaryPageModel.of(context)
                    .onHeadwordSelected(context, Entry.urlEncode(headword));
              },
          ),
          if (headword != _entry.related.last) TextSpan(text: ', '),
        ];
      },
    ).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 48.0),
      Text("Related",
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.bold)),
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
        .map((t) => editorialText(context, t.editorialNote));
    if (notes.isEmpty) return Container();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 48.0),
          Text("Editorial Notes",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(fontWeight: FontWeight.bold)),
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
