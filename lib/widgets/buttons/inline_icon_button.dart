import 'package:flutter/material.dart';

import 'package:rogers_dictionary/widgets/adaptive_material.dart';

class InlineIconButton extends StatelessWidget {
  const InlineIconButton(
    this.icon, {
    Key? key,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 30,
        child: AdaptiveIcon(
          icon,
          size: 22,
          color: color,
        ),
      ),
      onTap: onPressed,
    );
  }
}
