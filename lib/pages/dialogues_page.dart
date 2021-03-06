import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/widgets/dialogues_page/selected_dialogue_switcher.dart';
import 'package:rogers_dictionary/widgets/translation_mode_switcher.dart';

class DialoguesPage extends StatelessWidget {
  static const String route = 'dialogues';

  static bool matchesUri(Uri uri) => uri.pathSegments.contains(route);

  @override
  Widget build(BuildContext context) {
    return TranslationModeSwitcher(
      child: SelectedDialogueSwitcher(),
    );
  }
}
