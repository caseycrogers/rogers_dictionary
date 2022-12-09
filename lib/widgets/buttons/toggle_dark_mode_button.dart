// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/widgets/buttons/help_menu.dart';

class ToggleDarkModeButton extends StatelessWidget {
  const ToggleDarkModeButton({
    Key? key,
    this.wide = false,
    this.onTapSideEffect,
  }) : super(key: key);

  final bool wide;
  final VoidCallback? onTapSideEffect;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DictionaryModel.instance.isDark,
      builder: (context, isDark, _) {
        return HelpMenuButton(
          icon: isDark ? Icons.light_mode : Icons.dark_mode,
          text:
              isDark ? i18n.lightMode.get(context) : i18n.darkMode.get(context),
          showLabel: wide,
          onTap: () {
            DictionaryApp.analytics.logEvent(
              name: 'light_mode_${DictionaryModel.instance.isDark}',
            );
            onTapSideEffect?.call();
            DictionaryModel.instance.onDarkModeToggled();
          },
        );
      },
    );
  }
}
