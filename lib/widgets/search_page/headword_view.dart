import 'package:flutter/material.dart';
import 'package:rogers_dictionary/clients/entry_builders.dart';

import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/buttons/bookmarks_button.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/search_page/search_page_utils.dart';



class HeadwordView extends StatelessWidget {
  const HeadwordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntryViewData view = EntryView.of(context);
    final String searchString = SearchModel.of(context).searchString;
    final List<Widget> wraps = [
      ...highlightedText(
        context,
        view.entry.headword.headwordText,
        view.isPreview,
        searchString: searchString,
      ),
      if (view.entry.headword.abbreviation.isNotEmpty)
        headline1Text(context, ' '),
      if (view.entry.headword.abbreviation.isNotEmpty)
        ...highlightedText(
          context,
          '(${view.entry.headword.abbreviation})',
          view.isPreview,
          searchString: searchString,
          forWrap: false,
        ),
      ...parentheticalTexts(
        context,
        view.entry.headword.parentheticalQualifier,
        true,
        size: headline1(context).fontSize,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...wraps.getRange(0, wraps.length - 1),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                wraps[wraps.length - 1],
                BookmarksButton(entry: view.entry),
              ],
            ),
          ],
        ),
        const _AlternateHeadwordView(),
      ],
    );
  }
}

class _AlternateHeadwordView extends StatelessWidget {
  const _AlternateHeadwordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntryViewData view = EntryView.of(context);
    final List<Headword> alternateHeadwords = view.entry.alternateHeadwords;
    final String searchString = SearchModel.of(context).searchString;

    if (alternateHeadwords.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Table(
        columnWidths: const {0: IntrinsicColumnWidth()},
        children: alternateHeadwords.map((alt) {
          return TableRow(
            children: [
              if (alt == alternateHeadwords.first)
                Padding(
                  padding:
                  view.isPreview && alt.parentheticalQualifier.isNotEmpty
                      ? const EdgeInsets.only(top: 2)
                      : EdgeInsets.zero,
                  child: Text('alt. ',
                      style: headline3(context).copyWith(
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                      )),
                )
              else
                Container(),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...highlightedText(
                    context,
                    alt.headwordText,
                    view.isPreview,
                    searchString: searchString,
                    size: headline3(context).fontSize!,
                  ),
                  if (alt.abbreviation.isNotEmpty) ...[
                    Text(' ', style: headline3(context)),
                    ...highlightedText(
                        context, '(${alt.abbreviation})', view.isPreview,
                        searchString: searchString,
                        forWrap: false,
                        size: headline3(context).fontSize!),
                  ],
                  if (alt.gender.isNotEmpty)
                    Text(
                      ' ${alt.gender}',
                      style: headline3(context)
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                  if (alt.namingStandard.isNotEmpty)
                    NamingStandard(
                      isHeadword: true,
                      namingStandard: alt.namingStandard,
                      size: headline3(context).fontSize!,
                    ),
                  ...parentheticalTexts(
                    context,
                    alt.parentheticalQualifier,
                    true,
                    size: headline3(context).fontSize! - 2,
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
