import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/util/default_map.dart';

class EntryPage extends StatelessWidget {
  static const route = '/entries';
  final Entry _entry;
  final bool _preview;

  EntryPage._instance(this._entry, this._preview);

  static Widget asPage() => Builder(
    builder: (context) {
      if (!DictionaryPageModel.of(context).hasSelection) return Container();
      return FutureBuilder(
        future: DictionaryPageModel.of(context).selectedEntry,
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());
          return EntryPage._instance(snap.data, false);
        },
      );
    }
  );

  static Widget asPreview(Entry entry) => EntryPage._instance(entry, true);

  @override
  Widget build(BuildContext context) {
    var map = _constructTranslationMap(_entry);
    Widget entryWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headwordLine(context, _entry),
        _buildTable(context, map),
      ],
    );
    if (_preview) return entryWidget;
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).accentIconTheme.color,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: entryWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context,
      Map<String, Map<String, List<Translation>>> translationMap) {
    return Table(columnWidths: {
      0: IntrinsicColumnWidth(),
    }, children: _buildTranslations(context, translationMap));
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

  // Return a list of TableRows for all the translations of a single part of speech
  List<TableRow> _buildTranslations(BuildContext context,
      Map<String, Map<String, List<Translation>>> meaningMap) {
    List<TableRow> translationRows = [];
    meaningMap.forEach((meaningId, partOfSpeechMap) {
      partOfSpeechMap.forEach((partOfSpeech, translations) {
        translationRows
            .addAll(_buildPartOfSpeech(context, partOfSpeech, translations));
      });
    });
    return translationRows;
  }

  List<TableRow> _buildPartOfSpeech(BuildContext context, String partOfSpeech,
      List<Translation> translations) {
    if (_preview)
      return [
        TableRow(children: [
          _partOfSpeechText(context, partOfSpeech),
          _translationText(
            context,
            translations.map((t) => t.translation).join(", "),
          ),
        ])
      ];
    return translations.map((t) {
      var translationText = _translationText(context, t.translation);
      return TableRow(children: [
        (t == translations.first)
            ? _partOfSpeechText(context, partOfSpeech)
            : Container(),
        translationText,
      ]);
    }).toList();
  }

  Widget _headwordLine(BuildContext context, Entry entry) {
    if (entry.abbreviation == '') return _headwordText(context, entry.headword);
    if (_preview)
      return Row(
        children: [
          _headwordText(context, _entry.headword),
          Text(
            ' abbr ',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
          ),
          _headwordAbbreviationText(context, _entry.abbreviation),
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
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
            ),
            _headwordAbbreviationText(context, _entry.abbreviation),
          ],
        ),
      ],
    );
  }

  Widget _headwordText(BuildContext context, String text) {
    if (_preview)
      return Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
        overflow: TextOverflow.ellipsis,
      );
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .headline1
          .merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _headwordAbbreviationText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyText1
          .merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _partOfSpeechText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyText2
          .merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
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
