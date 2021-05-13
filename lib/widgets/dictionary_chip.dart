import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DictionaryChip extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? childPadding;

  DictionaryChip(
      {required this.child, this.color, this.padding, this.childPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0)
            .add(childPadding ?? EdgeInsets.zero),
        child: child,
        decoration: BoxDecoration(
          color: color ?? Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
    );
  }
}
