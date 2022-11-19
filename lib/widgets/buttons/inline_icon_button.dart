// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/util/constants.dart';

class InlineIconButton extends StatelessWidget {
  const InlineIconButton(this.icon, {
    Key? key,
    required this.onPressed,
    this.color,
    this.size,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size ?? IconTheme
          .of(context)
          .size! / 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kPad/2),
        child: Icon(
          icon,
          size: size ?? IconTheme
              .of(context)
              .size!,
          color: color,
        ),
      ),
      onTap: onPressed,
    );
  }
}
