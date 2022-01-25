import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/search_model.dart';

import 'package:rogers_dictionary/protobufs/entry_utils.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/overflow_markdown_base.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/buttons/bookmarks_button.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/search_page/search_page_utils.dart';

class HeadwordView extends StatelessWidget {
  const HeadwordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntryViewModel model = EntryViewModel.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: model.isPreview ? 0 : kPad / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                ...HighlightedText(
                  text: model.entry.headword.headwordText,
                ).asSpans(context),
                if (model.entry.headword.abbreviation.isNotEmpty) ...[
                  TextSpan(text: ' ', style: headline1(context)),
                  ...HighlightedText(
                    text: '(${model.entry.headword.abbreviation})',
                  ).asSpans(context),
                ],
                ...parentheticalSpans(
                  context,
                  model.entry.headword.parentheticalQualifier,
                ),
                WidgetSpan(
                  child: BookmarksButton(entry: model.entry),
                ),
              ],
            ),
          ),
          const _AlternateHeadwordView(),
        ],
      ),
    );
  }
}

class _AlternateHeadwordView extends StatelessWidget {
  const _AlternateHeadwordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntryViewModel model = EntryViewModel.of(context);
    final List<Headword> alternateHeadwords = model.entry.alternateHeadwords;

    if (alternateHeadwords.isEmpty) {
      return Container();
    }
    return _AlternateHeadwordTextTheme(
      child: Builder(builder: (context) {
        return Text.rich(
          TextSpan(
              text: 'alt. ',
              style: headline1(context).copyWith(
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.italic,
              ),
              children: [
                WidgetSpan(
                  child: Column(
                    children: alternateHeadwords.map((alt) {
                      return Text.rich(
                        TextSpan(
                          children: [
                            ...HighlightedText(text: alt.headwordText)
                                .asSpans(context),
                            if (alt.abbreviation.isNotEmpty) ...[
                              TextSpan(text: ' ', style: headline3(context)),
                              ...HighlightedText(text: '(${alt.abbreviation})')
                                  .asSpans(context),
                            ],
                            if (alt.gender.isNotEmpty)
                              TextSpan(
                                text: ' ${alt.gender}',
                                style: headline3(context)
                                    .copyWith(fontStyle: FontStyle.italic),
                              ),
                            NamingStandard(
                              namingStandard: alt.namingStandard,
                            ).asSpan(context),
                            ...parentheticalSpans(
                              context,
                              alt.parentheticalQualifier,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'alt. ',
              style: headline1(context).copyWith(
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.italic,
              ),
            ),
            Column(
              children: alternateHeadwords.map((alt) {
                return Text.rich(
                  TextSpan(
                    children: [
                      ...HighlightedText(text: alt.headwordText)
                          .asSpans(context),
                      if (alt.abbreviation.isNotEmpty) ...[
                        TextSpan(text: ' ', style: headline3(context)),
                        ...HighlightedText(text: '(${alt.abbreviation})')
                            .asSpans(context),
                      ],
                      if (alt.gender.isNotEmpty)
                        TextSpan(
                          text: ' ${alt.gender}',
                          style: headline3(context)
                              .copyWith(fontStyle: FontStyle.italic),
                        ),
                        NamingStandard(
                          namingStandard: alt.namingStandard,
                        ).asSpan(context),
                      ...parentheticalSpans(
                        context,
                        alt.parentheticalQualifier,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }),
    );
  }
}

/// Overrides all text with headline3.
class _AlternateHeadwordTextTheme extends StatelessWidget {
  const _AlternateHeadwordTextTheme({required this.child, Key? key})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: Theme.of(context).textTheme.copyWith(
              headline1: headline3(context),
              bodyText1: headline3(context),
              bodyText2: headline3(context),
            ),
      ),
      child: child,
    );
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return _markdown(context);
  }

  List<InlineSpan> asSpans(BuildContext context) {
    return _markdown(context).asSpans(context);
  }

  OverflowMarkdown _markdown(BuildContext context) {
    final overrides = _highlightSearchMatch(
      context,
      text,
      EntryViewModel.of(context).isPreview,
      SearchModel.of(context)
          .searchString
          .withoutDiacriticalMarks
          .toLowerCase(),
    );
    return OverflowMarkdown(
      text,
      defaultStyle: headline1(context),
      overrideRules: overrides.keys.toList(),
      overrideStyles: overrides.values.toList(),
    );
  }

  LinkedHashMap<OverrideRule, TextStyle> _highlightSearchMatch(
    BuildContext context,
    String text,
    bool preview,
    String searchString,
  ) {
    if (!preview || searchString.isEmpty) {
      // ignore: prefer_collection_literals
      return LinkedHashMap();
    }
    // Prepend `text` and `searchString` with spaces to rule out matches that are
    // in the middle of a word.
    Iterable<Match> overrideMatches =
        ' $searchString'.allMatches(' ${text.searchable}');
    bool isOptionalMatch = false;
    if (overrideMatches.isEmpty) {
      overrideMatches =
          ' $searchString'.allMatches(' ${text.withoutOptionals.searchable}');
      isOptionalMatch = true;
    }
    return LinkedHashMap.fromEntries(
      overrideMatches.toList().asMap().entries.map(
        (e) {
          final int start = e.value.start;
          int stop = e.value.end - 1;
          if (isOptionalMatch) {
            // Add the length of the optional back in
            stop += text.searchable.length -
                text.withoutOptionals.searchable.length;
          }
          return MapEntry(
            OverrideRule(styleIndex: e.key, start: start, stop: stop),
            TextStyle(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(.25),
            ),
          );
        },
      ),
    );
  }
}
