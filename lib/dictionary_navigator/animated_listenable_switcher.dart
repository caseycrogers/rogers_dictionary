import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:rogers_dictionary/widgets/search_page/transitions.dart';

class AnimatedListenableSwitcher<T> extends StatelessWidget {
  const AnimatedListenableSwitcher({
    required this.valueListenable,
    required this.builder,
    this.child,
    this.transitionBuilder,
    this.switchInCurve,
    this.switchOutCurve,
    this.duration,
  });

  final ValueListenable<T> valueListenable;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final Curve? switchInCurve;
  final Curve? switchOutCurve;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: valueListenable,
      child: child,
      builder: (BuildContext context, T value, Widget? child) =>
          AnimatedSwitcher(
        transitionBuilder: (Widget child, Animation<double> animation) =>
            transitionBuilder != null
                ? transitionBuilder!(child, animation)
                : _getTransitionBuilder(child, animation),
        duration: duration ?? const Duration(milliseconds: 200),
        reverseDuration: duration ?? const Duration(milliseconds: 200),
        child: builder(context, value, child),
        switchInCurve: switchInCurve ?? Curves.linear,
        switchOutCurve: switchOutCurve ?? Curves.linear,
      ),
    );
  }

  Widget _getTransitionBuilder(Widget child, Animation<double> animation) {
    return DictionaryPageTransition(child, animation);
  }
}
