import 'package:flutter/material.dart';

import 'package:rogers_dictionary/widgets/buttons/about_button.dart';
import 'package:rogers_dictionary/widgets/buttons/drop_down_widget.dart';
import 'package:rogers_dictionary/widgets/buttons/feedback_button.dart';
import 'package:rogers_dictionary/widgets/buttons/toggle_dark_mode_button.dart';

class HelpMenu extends StatelessWidget {
  const HelpMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropDownWidget(
      builder: (_, closeMenu) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeedbackButton(onPressed: closeMenu),
            AboutButton(onPressed: closeMenu),
            ToggleDarkModeButton(onPressed: closeMenu),
          ],
        );
      },
      child: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      selectedColor: Colors.black12,
    );
  }
}

class HelpMenuButton extends StatelessWidget {
  const HelpMenuButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 4),
            Text(text),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
