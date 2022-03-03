import 'package:flutter/material.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';

class RelatedView extends StatelessWidget {
  const RelatedView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntryViewModel model = EntryViewModel.of(context);
    if (model.entry.related.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: kSectionSpacer),
        Text(
          i18n.related.get(context),
          style: const TextStyle().asBold,
        ),
        const Divider(),
        ...model.entry.related.where((r) => r.isNotEmpty).map(
              (uid) => InkWell(
                borderRadius: BorderRadius.circular(kPad),
                child: Padding(
                  padding: const EdgeInsets.all(kPad / 2),
                  child: OverflowMarkdown(
                    uid,
                    defaultStyle: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .asColor(Colors.blue),
                  ),
                ),
                onTap: () {
                  DictionaryModel.instance.onUidSelected(
                    context,
                    model.entry.uid,
                    referrer: SelectedEntryReferrer.relatedHeadword,
                  );
                },
              ),
            ),
      ],
    );
  }
}
