import 'package:flutter/material.dart';

import 'package:rogers_dictionary/util/overflow_markdown.dart';

class AbbreviationView extends StatelessWidget {
  const AbbreviationView(
      this._abbreviation, {
        Key? key,
      }) : super(key: key);

  final String _abbreviation;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: asSpans(context)));
  }

  List<InlineSpan> asSpans(BuildContext context) {
    if (_abbreviation.isEmpty) {
      return [];
    }
    String processedAbbreviation = _abbreviation;
    if (_abbreviation.endsWith('\*')) {
      // The asterisk needs to be placed outside of the parens in the special
      // case where there is a footnote. This is because footnotes are placed on
      // the abbreviation to indicate a footnote applying to the entire
      // translation.
      processedAbbreviation =
      '(${_abbreviation.substring(0, _abbreviation.length - 2)})\*';
    } else {
      processedAbbreviation = '($_abbreviation)';
    }
    return [
      const TextSpan(text: ' '),
      ...OverflowMarkdown(processedAbbreviation).asSpans(context),
    ];
  }
}