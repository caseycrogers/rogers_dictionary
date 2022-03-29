import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';

import 'package:rogers_dictionary/widgets/dialogues_page/selected_dialogue_switcher.dart';
import 'package:rogers_dictionary/widgets/translation_mode_switcher.dart';

class DialoguesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveMaterial(
      adaptiveColor: AdaptiveColor.surface,
      child: TranslationModeSwitcher(
        child: SelectedDialogueSwitcher(),
      ),
    );
  }
}
