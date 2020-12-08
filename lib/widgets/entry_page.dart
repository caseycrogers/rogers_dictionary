import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/util/default_map.dart';
import 'package:rogers_dictionary/util/text_utils.dart';

class EntryPage extends StatelessWidget {
  final Entry _entry;
  final bool _preview;

  EntryPage._instance(this._entry, this._preview);

  static Widget asPage() => Builder(builder: (context) {
        if (!DictionaryPageModel.of(context).hasSelection)
          return Container(color: Theme.of(context).scaffoldBackgroundColor);
        return LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    : Container(width: 20.0),
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
        );
      });

  static Widget asPreview(Entry entry) => EntryPage._instance(entry, true);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headwordLine(context, _entry),
        if (!_preview) Divider(),
        _buildTable(context, _constructTranslationMap(_entry)),
        if (!_preview) _buildRelated(context),
        if (!_preview) _buildEditorialNotes(context),
      ],
    );
  }

  Widget _buildRelated(BuildContext context) {
    if (_entry.runOnParent.isEmpty && _entry.runOns.isEmpty) return Container();
    var relatedList = ([_entry.runOnParent]..addAll(_entry.runOns))
        .where((s) => s.isNotEmpty)
        .map(
          (encodedHeadword) => TextSpan(
              text: Entry.urlDecode(encodedHeadword),
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  DictionaryPage.pushPage(context, urlEncodedHeadword: encodedHeadword);
                }),
        )
        .toList();
    relatedList = relatedList.expand((span) => [
      span,
      if (span != relatedList.last) TextSpan(text: ', '),
    ]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 48.0),
      Text("Related"),
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
          Text("Editorial Notes"),
          Divider(),
        ]..addAll(notes));
  }

  Widget _buildTable(BuildContext context,
      Map<String, Map<String, List<Translation>>> translationMap) {
    return Table(
        columnWidths: {
          0: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: _buildTranslations(context, translationMap));
  }

  Map<String, Map<String, List<Translation>>> _constructTranslationMap(
      Entry entry) {
    // Schema:
    // {meaningId: {partOfSpeech: [translation]}}
    Map<String, Map<String, List<Translation>>> translationMap = {};
    _entry.translations.forEach((t) => translationMap
        .getOrElse(t.meaningId, {}).getOrElse(t.partOfSpeech, []).add(t));
    return translationMap;
  }

  // Return a list of TableRows corresponding to each part of speech.
  List<TableRow> _buildTranslations(BuildContext context,
      Map<String, Map<String, List<Translation>>> meaningMap) {
    List<TableRow> partOfSpeechTableRows = [];
    meaningMap.forEach((meaningId, partOfSpeechMap) {
      partOfSpeechMap.forEach((partOfSpeech, translations) {
        partOfSpeechTableRows.add(
            _buildPartOfSpeechTableRow(context, partOfSpeech, translations));
      });
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
          child: translationText(context,
              translations.map((t) => t.translation).join(', '), _preview),
        ),
      ]);
    return TableRow(
      children: [
        partOfSpeechText(context, partOfSpeech, _preview),
        Padding(
          padding: const EdgeInsets.only(top: 7.0),
          child: Column(
            children: translations
                .map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Flexible(
                            child: translationText(
                                context, t.translation, _preview),
                          ),
                          if ((t.genderAndPlural ?? '') != '')
                            genderAndPluralText(
                                context, ' ' + t.genderAndPlural),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _headwordLine(BuildContext context, Entry entry) {
    if (entry.abbreviation == '')
      return headwordText(context, entry.headword, _preview);
    if (_preview)
      return Row(
        children: [
          headwordText(context, _entry.headword, _preview),
          Text(
            ' abbr ',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
          ),
          headwordAbbreviationText(context, _entry.abbreviation),
        ],
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'abbr ',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
            ),
            headwordAbbreviationText(context, _entry.abbreviation),
          ],
        ),
      ],
    );
  }
}
