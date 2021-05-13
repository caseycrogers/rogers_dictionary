import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';

class FavoritesButton extends StatefulWidget {
  final Entry entry;

  FavoritesButton({required this.entry});

  @override
  _FavoritesButtonState createState() => _FavoritesButtonState();
}

class _FavoritesButtonState extends State<FavoritesButton> {
  @override
  Widget build(BuildContext context) {
    final translationMode = TranslationPageModel.of(context).translationMode;
    return IconButton(
      icon: _icon,
      onPressed: () async {
        var newFavorite = !MyApp.db.isFavorite(
            translationMode, widget.entry.headword.urlEncodedHeadword);
        await MyApp.db.setFavorite(
          translationMode,
          widget.entry.headword.urlEncodedHeadword,
          newFavorite,
        );
        setState(() {});
      },
    );
  }

  Widget get _icon => Icon(
        MyApp.db.isFavorite(TranslationPageModel.of(context).translationMode,
                widget.entry.headword.urlEncodedHeadword)
            ? Icons.star
            : Icons.star_border,
        color: Theme.of(context).accentIconTheme.color,
        size: Theme.of(context).accentIconTheme.size,
      );
}
