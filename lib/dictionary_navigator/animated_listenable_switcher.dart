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
  });

  final ValueListenable<T> valueListenable;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

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
                : DictionaryPageTransition(child, animation),
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 100),
        child: builder(context, value, child),
      ),
    );
  }
}
