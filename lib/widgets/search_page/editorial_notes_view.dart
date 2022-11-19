// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';

class EditorialNotesView extends StatelessWidget {
  const EditorialNotesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntryViewModel model = EntryViewModel.of(context);
    final Iterable<Widget> notes = model.entry.translations
        .where((t) => t.editorialNote.isNotEmpty)
        .map((t) => OverflowMarkdown(t.editorialNote));
    if (notes.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: kSectionSpacer),
        Text(
          i18n.editorialNotes.get(context),
          style: const TextStyle().asBold,
        ),
        const Divider(),
        ...notes,
      ],
    );
  }
}
