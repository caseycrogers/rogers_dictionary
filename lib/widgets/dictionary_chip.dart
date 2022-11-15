import 'package:flutter/material.dart';
import 'package:rogers_dictionary/util/constants.dart';

class DictionaryChip extends StatelessWidget {
  const DictionaryChip({
    required this.child,
    this.color,
    this.margin,
    this.childPadding,
    this.borderRadius,
  });

  final Widget child;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? childPadding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.only(
          left: kPad,
          right: kPad + 2,
        ),
        child: DefaultTextStyle(
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: Theme.of(context).chipTheme.labelStyle!.color),
          child: Padding(
            padding: childPadding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).chipTheme.backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 18),
        ),
      ),
    );
  }
}
