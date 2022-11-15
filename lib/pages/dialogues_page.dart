import 'package:flutter/material.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';

import 'package:rogers_dictionary/widgets/dialogues_page/selected_dialogue_switcher.dart';
import 'package:rogers_dictionary/widgets/translation_mode_switcher.dart';

class DialoguesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AdaptiveMaterial(
      adaptiveColor: AdaptiveColor.surface,
      child: ExpansionTileTheme(
        data: ExpansionTileThemeData(
          iconColor: Theme.of(context).iconTheme.color,
          collapsedIconColor: Theme.of(context).iconTheme.color,
        ),
        child: ListTileTheme(
          data: ListTileThemeData(
            tileColor: Theme.of(context).colorScheme.surface,
            visualDensity: VisualDensity.compact,
            iconColor: Theme.of(context).iconTheme.color,
          ),
          child: Theme(
            data: ThemeData(
              textTheme: textTheme.copyWith(
                caption: textTheme.bodyText2!.copyWith(
                  color: textTheme.bodyText2!.color!.withOpacity(.75),
                  fontSize: textTheme.bodyText2!.fontSize! - 2,
                ),
              ),
            ),
            child: TranslationModeSwitcher(
              child: SelectedDialogueSwitcher(),
            ),
          ),
        ),
      ),
    );
  }
}
