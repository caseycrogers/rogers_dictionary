// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'inline_icon_button.dart';

class BookmarksButton extends StatefulWidget {
  const BookmarksButton({required this.entry, this.size});

  final Entry entry;
  final double? size;

  @override
  _BookmarksButtonState createState() => _BookmarksButtonState();
}

class _BookmarksButtonState extends State<BookmarksButton> {
  @override
  Widget build(BuildContext context) {
    final translationMode = TranslationModel.of(context).translationMode;
    return InlineIconButton(
      _icon,
      size: widget.size,
      color: IconTheme.of(context).color,
      onPressed: () async {
        final bool newIsBookmarked =
            !DictionaryApp.db.isBookmarked(translationMode, widget.entry);
        await DictionaryApp.analytics.logEvent(
          name: 'set_bookmark',
          parameters: {
            'entry': widget.entry.headword.text,
            'value': newIsBookmarked.toString(),
          },
        );
        await DictionaryModel.instance
            .onBookmarkSet(context, widget.entry, newIsBookmarked);
        setState(() {});
      },
    );
  }

  IconData get _icon {
    return DictionaryApp.db.isBookmarked(
            TranslationModel.of(context).translationMode, widget.entry)
        ? Icons.bookmark
        : Icons.bookmark_border;
  }
}
