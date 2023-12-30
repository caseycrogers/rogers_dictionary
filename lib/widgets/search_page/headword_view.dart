// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/entry_utils.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/overflow_markdown_base.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/buttons/bookmarks_button.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab.dart';
import 'package:rogers_dictionary/widgets/search_page/abbreviation_view.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/search_page/search_page_utils.dart';

class HeadwordView extends StatelessWidget {
  const HeadwordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntryViewModel model = EntryViewModel.of(context);
    return Builder(builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: model.isPreview ? 0 : kPad / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  ...HighlightedText(
                    style: const TextStyle().asBold,
                    text: model.entry.headword.text,
                  ).asSpans(context),
                  ...AbbreviationView(
                    model.entry.headword.abbreviation,
                    isHeadword: true,
                  ).asSpans(context),
                  ...ParentheticalView(
                    text: model.entry.headword.parentheticalQualifier,
                  ).asSpans(context),
                  WidgetSpan(
                    child: BookmarksButton(
                      // If this is in the headword we need to manually up-size
                      // the icon.
                      // Make the icon the same amount larger than the headline
                      // text as the default icon size is larger than the
                      // default text size.
                      size: model.isPreview
                          ? null
                          : Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .fontSize! +
                              (IconTheme.of(context).size! -
                                  Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .fontSize!),
                      entry: model.entry,
                    ),
                  ),
                ],
              ),
            ),
            const _AlternateHeadwordView(),
          ],
        ),
      );
    });
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
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.displaySmall!.asBold,
      child: Builder(
        builder: (context) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'alt. ',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: alternateHeadwords.map((alt) {
                    return Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        HighlightedText(
                          style: DefaultTextStyle.of(context).style,
                          text: alt.text,
                        ),
                        ..._AbbreviationView(text: alt.abbreviation)
                            .asWidgets(),
                        ..._GenderView(text: alt.gender).asWidgets(),
                        NamingStandardView(
                          namingStandard: alt.namingStandard,
                        ),
                        ...ParentheticalView(text: alt.parentheticalQualifier)
                            .asWidgets(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GenderView extends StatelessWidget {
  const _GenderView({required this.text, Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox();
    }
    return Wrap(
      children: asWidgets(),
    );
  }

  List<Widget> asWidgets() {
    if (text.isEmpty) {
      return [];
    }
    return [
      const Text(' '),
      Text(text, style: const TextStyle().asItalic.asNotBold),
    ];
  }
}

class _AbbreviationView extends StatelessWidget {
  const _AbbreviationView({required this.text, Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox();
    }
    return Wrap(
      children: asWidgets(),
    );
  }

  List<Widget> asWidgets() {
    if (text.isEmpty) {
      return [];
    }
    return [
      const Text(' '),
      HighlightedText(text: '($text)'),
    ];
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    required this.text,
    this.style,
    Key? key,
  }) : super(key: key);

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return _markdown(context, style);
  }

  List<InlineSpan> asSpans(BuildContext context) {
    return _markdown(context, style).asSpans(context);
  }

  OverflowMarkdown _markdown(BuildContext context, TextStyle? style) {
    // If this is bookmarks mode don't produce any highlight override rules.
    final Map<OverrideRule, TextStyle> overrides =
        DictionaryModel.instance.currentTab.value == DictionaryTab.bookmarks
            ? <OverrideRule, TextStyle>{}
            : _highlightSearchMatch(
                context,
                text,
                EntryViewModel.of(context).isPreview,
                SearchModel.of(context)
                    .searchString
                    .trimRight()
                    .withoutDiacriticalMarks
                    .toLowerCase(),
              );
    return OverflowMarkdown(
      text,
      defaultStyle: style,
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
    // Prepend `text` and `searchString` with spaces to rule out matches that
    // are in the middle of a word.
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
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(DictionaryModel.instance.isDark.value ? 1 : .25),
            ),
          );
        },
      ),
    );
  }
}
