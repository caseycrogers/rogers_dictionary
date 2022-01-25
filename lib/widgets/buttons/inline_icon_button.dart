import 'package:flutter/material.dart';

import 'package:rogers_dictionary/widgets/adaptive_material.dart';

class InlineIconButton extends StatelessWidget {
  const InlineIconButton(
    this.icon, {
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
      borderRadius: BorderRadius.circular(_size/2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          child: AdaptiveIcon(
            icon,
            size: _size,
            color: color,
          ),
        ),
      ),
      onTap: onPressed,
    );
  }

  double get _size => size ?? 22;
}
