import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/util/default_map.dart';

class EntryPage extends StatelessWidget {
  static const route = '/entries';
  final Entry _entry;
  final bool _preview;
  final bool _panel;

  EntryPage._instance(this._entry, this._preview, this._panel);

  static EntryPage asPage(Entry _entry) => EntryPage._instance(_entry, false, false);
  static EntryPage asPreview(Entry _entry) => EntryPage._instance(_entry, true, false);
  static EntryPage asPanel(Entry _entry) => EntryPage._instance(_entry, false, true);

  @override
  Widget build(BuildContext context) {
    assert(!(this._preview && this._panel), 'An entry page can\'t be both a preview and a panel.');
    var map = _constructTranslationMap(_entry);
    var entryWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headwordLine(context, _entry),
        _buildTable(context, map),
      ],
    );
    if (_preview || _panel) return entryWidget;
    return Scaffold(
        appBar: AppBar(
          title: Text('back'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(20.0),
          child: entryWidget,
        ),
    );
  }

  Widget _buildTable(BuildContext context, Map<String, Map<String, List<Translation>>> translationMap) {
    return Table(
      columnWidths: {
        0: IntrinsicColumnWidth(),
      },
      children: _buildTranslations(context, translationMap)
    );
  }

  Map<String, Map<String, List<Translation>>> _constructTranslationMap(Entry entry) {
    // Schema:
    // {meaningId: {partOfSpeech: [translation]}}
    Map<String, Map<String, List<Translation>>> translationMap = {};
    _entry.translations.forEach((t) =>
        translationMap.getOrElse(t.meaningId, {}).getOrElse(t.partOfSpeech, []).add(t));
    return translationMap;
  }

  // Return a list of TableRows for all the translations of a single part of speech
  List<TableRow> _buildTranslations(BuildContext context, Map<String, Map<String, List<Translation>>> meaningMap) {
    List<TableRow> translationRows = [];
    meaningMap.forEach((meaningId, partOfSpeechMap) {
      partOfSpeechMap.forEach((partOfSpeech, translations) {
        translationRows.addAll(_buildPartOfSpeech(context, partOfSpeech, translations));
      });
    });
    return translationRows;
  }

  List<TableRow> _buildPartOfSpeech(BuildContext context, String partOfSpeech, List<Translation> translations) {
    if (_preview) return [
      TableRow(
        children: [
          _partOfSpeechText(context, partOfSpeech),
          _translationText(context, translations
              .map((t) => t.translation)
              .join(", "),
          ),
        ]
      )
    ];
    return translations.map((t) {
      var translationText = _translationText(context, t.translation);
      return TableRow(
        children: [
          (t == translations.first) ? _partOfSpeechText(context, partOfSpeech) : Container(),
          translationText,
        ]
      );
    }).toList();
  }

  Widget _headwordLine(BuildContext context, Entry entry) {
    if (entry.abbreviation == '') return _headwordText(context, entry.headword);
    if (_preview) return Row(
      children: [
        _headwordAbbreviationText(context, _entry.abbreviation),
        Text(
          ' abbr ',
          style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
        ),
        _headwordText(context, _entry.headword),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headwordText(context, _entry.headword),
        Row(
          children: [
            Text(
              'abbr ',
              style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
            ),
            _headwordAbbreviationText(context, _entry.abbreviation),
          ],
        ),

      ],
    );
  }

  Widget _headwordText(BuildContext context, String text) {
    if (_preview) return Text(
        text,
        style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
        overflow: TextOverflow.ellipsis,
    );
    return Text(
      text,
      style: Theme.of(context).textTheme.headline1.merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _headwordAbbreviationText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _partOfSpeechText(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.only(right: 10.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
      )
    );
  }

  Widget _translationText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyText2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
