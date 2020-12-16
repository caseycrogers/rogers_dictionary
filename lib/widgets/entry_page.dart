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

  static Widget asPage() => Builder(builder: (context) {
        if (!DictionaryPageModel.of(context).hasSelection)
          return Container(color: Theme.of(context).scaffoldBackgroundColor);
        return Container(
          color: Theme.of(context).cardColor,
          child: LayoutBuilder(
            builder: (context, constraints) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconButton(context),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: FutureBuilder(
                          future: DictionaryPageModel.of(context).selectedEntry,
                          builder: (context, snap) {
                            if (!snap.hasData)
                              return Center(child: CircularProgressIndicator());
                            return EntryPage._instance(snap.data, false);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });

  static Widget asPreview(Entry entry) => EntryPage._instance(entry, true);

  static Widget _iconButton(BuildContext context) =>
      (MediaQuery.of(context).orientation == Orientation.portrait)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).accentIconTheme.color,
              ),
              onPressed: () {
                if (MediaQuery.of(context).orientation ==
                    Orientation.portrait) {
                  return Navigator.of(context).pop();
                }
                Navigator.of(context).pop();
              },
            )
          : Container(width: 20.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headwordLine(context, _entry),
        if (!_preview) Divider(),
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
              style: Theme.of(context).textTheme.bodyText2)),
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
              context, translations.map((t) => t.translation).join(', ')),
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
          children: translations.expand((t) {
            var parentheticalChanged =
                t.headwordParentheticalQualifier != parenthetical;
            parenthetical = t.headwordParentheticalQualifier;
            return [
              if (parentheticalChanged)
                parentheticalText(context, parenthetical),
              _translationContent(context, t, hasParenthetical),
            ];
          }).toList(),
        ),
      ],
    );
  }

  Widget _translationContent(
      BuildContext context, Translation translation, bool indent) {
    return Indent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 7.0),
          translationLine(context, translation),
          Indent(
            child:
                abbreviationLine(context, translation.translationAbbreviation),
          ),
          _exampleText(context, translation.examplePhrase),
          SizedBox(height: 12.0),
        ],
      ),
      size: indent ? null : 0.0,
    );
  }

  Widget _exampleText(BuildContext context, String exampleText) {
    if (exampleText.isEmpty) return Container();
    return OverflowMarkdown('*Ex:* $exampleText', TextOverflow.visible);
  }

  Widget _headwordLine(BuildContext context, Entry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headwordText(context, entry.headword, _preview),
        abbreviationLine(context, entry.headwordAbbreviation),
        alternateHeadwordLine(context, entry.alternateHeadword,
            entry.alternateHeadwordNamingStandard),
      ],
    );
  }
}
