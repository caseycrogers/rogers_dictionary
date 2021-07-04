import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';

class FavoritesButton extends StatefulWidget {
  const FavoritesButton({required this.entry});

  final Entry entry;

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
        final bool newFavorite = !await MyApp.db.isFavorite(
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

  Widget get _icon {
    final Future<bool> favoriteFuture = MyApp.db.isFavorite(
        TranslationPageModel.of(context).translationMode,
        widget.entry.headword.urlEncodedHeadword);
    return FutureBuilder<bool>(
      future: favoriteFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container(
            height: Theme.of(context).iconTheme.size,
            child: const CircularProgressIndicator(),
          );
        }
        return Icon(
          snap.data! ? Icons.star : Icons.star_border,
          color: Theme.of(context).accentIconTheme.color,
          size: Theme.of(context).accentIconTheme.size,
        );
      },
    );
  }
}
