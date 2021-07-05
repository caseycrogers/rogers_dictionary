import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/widgets/search_page/selected_entry_switcher.dart';
import 'package:rogers_dictionary/widgets/translation_mode_switcher.dart';

class FavoritesPage extends StatelessWidget {
  static const route = 'favorites';

  static bool matchesUri(Uri uri) => uri.pathSegments.contains(route);

  @override
  Widget build(BuildContext context) {
    return const TranslationModeSwitcher(
      child: SelectedEntrySwitcher(),
    );
  }
}
