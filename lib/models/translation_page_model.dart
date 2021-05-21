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
  TranslationPageModel._({
    required BuildContext context,
    required this.translationMode,
  })   : searchPageModel = SearchPageModel.empty(
          context: context,
          translationMode: translationMode,
          isFavoritesOnly: false,
        ),
        favoritesPageModel = SearchPageModel.empty(
          context: context,
          translationMode: translationMode,
          isFavoritesOnly: true,
        ) {
    TranslationPageModel._dialoguesPageModel ??=
        DialoguesPageModel.empty(context);
  }

  TranslationPageModel.empty(
      {required BuildContext context, required TranslationMode translationMode})
      : this._(context: context, translationMode: translationMode);

  // Translation mode state.
  final TranslationMode translationMode;

  final SearchPageModel searchPageModel;

  final SearchPageModel favoritesPageModel;

  static DialoguesPageModel? _dialoguesPageModel;

  DialoguesPageModel get dialoguesPageModel => _dialoguesPageModel!;

  bool get isEnglish => translationMode == TranslationMode.English;

  static TranslationPageModel of(BuildContext context) =>
      context.read<TranslationPageModel>();
}
