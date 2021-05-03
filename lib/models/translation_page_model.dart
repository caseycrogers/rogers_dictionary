import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rogers_dictionary/models/search_page_model.dart';

import 'dialogues_page_model.dart';

enum TranslationMode {
  English,
  Spanish,
}

class TranslationPageModel {
  // Translation mode state.
  final TranslationMode translationMode;

  final SearchPageModel searchPageModel;

  final SearchPageModel favoritesPageModel;

  final DialoguesPageModel dialoguesPageModel;

  bool get isEnglish => translationMode == TranslationMode.English;

  factory TranslationPageModel.empty(
          {@required BuildContext context,
          @required TranslationMode translationMode}) =>
      TranslationPageModel._(
          context: context, translationMode: translationMode);

  TranslationPageModel._({
    @required BuildContext context,
    @required this.translationMode,
  })  : searchPageModel = SearchPageModel.empty(
          context: context,
          translationMode: translationMode,
          isFavoritesOnly: false,
        ),
        favoritesPageModel = SearchPageModel.empty(
          context: context,
          translationMode: translationMode,
          isFavoritesOnly: true,
        ),
        dialoguesPageModel = DialoguesPageModel.empty(context);

  static TranslationPageModel of(BuildContext context) =>
      context.select<TranslationPageModel, TranslationPageModel>((mdl) => mdl);
}
