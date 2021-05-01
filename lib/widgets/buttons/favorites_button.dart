import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class FavoritesButton extends StatefulWidget {
  final Entry entry;

  FavoritesButton({@required this.entry});

  @override
  _FavoritesButtonState createState() => _FavoritesButtonState();
}

class _FavoritesButtonState extends State<FavoritesButton> {
  TranslationMode _translationMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translationMode ??= SearchPageModel.readFrom(context).translationMode;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _icon,
      onPressed: () async {
        var newFavorite = !MyApp.db
            .isFavorite(_translationMode, widget.entry.urlEncodedHeadword);
        await MyApp.db.setFavorite(
          _translationMode,
          widget.entry.urlEncodedHeadword,
          newFavorite,
        );
        setState(() {});
      },
    );
  }

  Widget get _icon => Icon(
        MyApp.db.isFavorite(_translationMode, widget.entry.urlEncodedHeadword)
            ? Icons.star
            : Icons.star_border,
        color: Theme.of(context).accentIconTheme.color,
        size: Theme.of(context).accentIconTheme.size,
      );
}
