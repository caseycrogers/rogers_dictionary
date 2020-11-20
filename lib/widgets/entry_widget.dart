import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/util/default_map.dart';

class EntryWidget extends StatelessWidget {
  final Entry _entry;

  EntryWidget(this._entry);

  @override
  Widget build(BuildContext context) {
    // Schema:
    // {meaningId: {partOfSpeech: [translation]}}
    Map<String, Map<String, List<Translation>>> translationMap = {};
    _entry.translations.forEach((t) =>
        translationMap.getOrElse(t.meaningId, {}).getOrElse(t.partOfSpeech, []).add(t));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            _entry.headword,
            overflow: TextOverflow.ellipsis,
            maxLines: 1
        ),
        Column(
          children: [
            Row(
              children: groupBy(_entry.translations, (t) => t.partOfSpeech).values
                  .map(_buildTranslations).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTranslations(List<Translation> translations) {
    String partOfSpeech = translations.first.partOfSpeech;
    return Row(
      children: [
        Text(partOfSpeech + ':'),
        SizedBox(width: 10),
        Column(
          children: translations.map((t) => Text(t.translation)).toList(),
          crossAxisAlignment: CrossAxisAlignment.start,
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
