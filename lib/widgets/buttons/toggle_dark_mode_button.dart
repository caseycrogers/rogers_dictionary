import 'package:flutter/material.dart';

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/widgets/buttons/help_menu.dart';

class ToggleDarkModeButton extends StatelessWidget {
  const ToggleDarkModeButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isDark = DictionaryModel.instance.isDark.value;
    return HelpMenuButton(
      icon: isDark ? Icons.light_mode : Icons.dark_mode,
      text: isDark ?  i18n.lightMode.get(context) : i18n.darkMode.get(context),
      onTap: () {
        DictionaryApp.analytics.logEvent(
          name: 'light_mode_${DictionaryModel.instance.isDark}',
        );
        onPressed();
        DictionaryModel.instance.onDarkModeToggled();
      },
    );
  }
}
