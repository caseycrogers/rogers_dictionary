import 'package:flutter/material.dart';

class DictionaryChip extends StatelessWidget {
  const DictionaryChip({
    required this.child,
    this.color,
    this.padding,
    this.childPadding,
  });

  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? childPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
            .add(childPadding ?? EdgeInsets.zero),
        child: child,
        decoration: BoxDecoration(
          color: color ?? Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
