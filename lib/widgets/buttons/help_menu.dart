// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/widgets/buttons/about_button.dart';
import 'package:rogers_dictionary/widgets/buttons/drop_down_widget.dart';
import 'package:rogers_dictionary/widgets/buttons/feedback_button.dart';

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
            // TODO(caseycrogers): add this back in when paid is launched.
            //HelpMenuButton(
            //  icon: Icons.attach_money,
            //  text: 'remove ads',
            //  onTap: () {},
            //),
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
    this.showLabel = true,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final bool showLabel;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!showLabel) {
      return IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      );
    }
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
