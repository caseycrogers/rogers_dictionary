import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/util/default_map.dart';
import 'package:rogers_dictionary/util/text_utils.dart';

class EntryPage extends StatelessWidget {
  final Entry _entry;
  final bool _preview;

  EntryPage._instance(this._entry, this._preview);

  static Widget asPage() => Builder(
        builder: (context) {
          if (!DictionaryPageModel.of(context).hasSelection)
            return Container(color: Theme.of(context).scaffoldBackgroundColor);
          return Container(
            color: Theme.of(context).cardColor,
            child: FutureBuilder(
              future: DictionaryPageModel.of(context).selectedEntry,
              builder: (context, snap) {
                if (!snap.hasData)
                  return Center(child: CircularProgressIndicator());
                var entry = snap.data;
                const pad = 24.0;
                return LayoutBuilder(
                  builder: (context, constraints) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: pad),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _iconButton(context),
                            Expanded(
                                child: headwordLine(context, entry, false)),
                          ],
                        ),
                      ),
                      Divider(indent: pad, endIndent: pad),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.all(pad),
                            child: FutureBuilder(
                              future:
                                  DictionaryPageModel.of(context).selectedEntry,
                              builder: (context, snap) {
                                if (!snap.hasData)
                                  return Center(
                                      child: CircularProgressIndicator());
                                return EntryPage._instance(entry, false);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );

  static Widget asPreview(Entry entry) => EntryPage._instance(entry, true);

  static Widget _iconButton(BuildContext context) => IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).accentIconTheme.color,
        ),
        onPressed: () {
          if (MediaQuery.of(context).orientation == Orientation.portrait) {
            return Navigator.of(context).pop();
          }
          Navigator.of(context).pop();
        },
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_preview) headwordLine(context, _entry, _preview),
        _buildTable(context, _constructTranslationMap(_entry)),
        if (!_preview) _buildEditorialNotes(context),
        if (!_preview) _buildRelated(context),
      ],
    );
  }

  Widget _buildRelated(BuildContext context) {
    if (_entry.runOnParent.isEmpty && _entry.runOns.isEmpty) return Container();
    var relatedList = ([_entry.runOnParent]..addAll(_entry.runOns))
        .where((s) => s.isNotEmpty)
        .map(
          (headword) => TextSpan(
              text: headword,
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  DictionaryPageModel.onHeadwordSelected(
                      context, Entry.urlEncode(headword));
                }),
        )
        .toList();
    relatedList = relatedList
        .expand((span) => [
              span,
              if (span != relatedList.last) TextSpan(text: ', '),
            ])
        .toList();
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
              children: relatedList,
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
    if (_preview)
      return TableRow(children: [
        partOfSpeechText(context, partOfSpeech, _preview),
        Padding(
          padding: const EdgeInsets.only(top: 7.0),
          child: previewTranslationLine(
              context, translations.first, translations.length != 1),
        ),
      ]);
    String parenthetical = '';
    final hasParenthetical =
        translations.any((t) => t.headwordParentheticalQualifier.isNotEmpty);
    return TableRow(
      children: [
        partOfSpeechText(context, partOfSpeech, _preview),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: translations.map((t) {
            var parentheticalChanged =
                t.headwordParentheticalQualifier != parenthetical;
            parenthetical = t.headwordParentheticalQualifier;
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
                  context, translation.translationAbbreviation),
            ),
          ),
          exampleText(context, translation.examplePhrase),
          SizedBox(height: 0.0),
        ],
      ),
    );
  }
}
