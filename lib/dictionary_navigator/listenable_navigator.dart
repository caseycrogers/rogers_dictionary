import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/pages/default_page.dart';

import 'package:rogers_dictionary/widgets/search_page/transitions.dart';

class ListenableNavigator<T> extends StatefulWidget {
  const ListenableNavigator({
    required this.valueListenable,
    required this.builder,
    required this.getDepth,
    this.child,
    this.transitionBuilder,
    this.switchInCurve,
    this.switchOutCurve,
    this.duration,
  });

  final ValueListenable<T> valueListenable;
  final ValueWidgetBuilder<T> builder;
  final int Function(T) getDepth;

  final Widget? child;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final Curve? switchInCurve;
  final Curve? switchOutCurve;
  final Duration? duration;

  @override
  _ListenableNavigatorState<T> createState() =>
      _ListenableNavigatorState<T>();
}

class _ListenableNavigatorState<T>
    extends State<ListenableNavigator<T>> {
  final SplayTreeMap<int, T> stack = SplayTreeMap();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: widget.valueListenable,
      child: widget.child,
      builder: (BuildContext context, T value, Widget? child) {
        final int depth = widget.getDepth(value);
        if (stack.isEmpty) {
          assert(
          depth == 0,
          'Depth of initial value must be 0. Actual: $depth',
          );
        }
        stack.removeWhere((key, _) => key >= depth);
        if (stack[depth] == null) {
          stack[depth] = value;
        }
        if (value is SelectedEntry?) {
          print(stack);
        }
        return Navigator(
          pages: _pages(context),
          onPopPage: (route, dynamic result) {
            if (!route.didPop(result)) {
              return false;
            }
            // Remove the top item in the stack
            stack.remove(stack.values.last);
            return true;
          },
        );
      },
    );
  }

  Widget _getTransitionBuilder(Widget child, Animation<double> animation) {
    return DictionaryPageTransition(child, animation);
  }

  List<DefaultPage> _pages(BuildContext context) {
    return stack.values
        .map((value) => DefaultPage(
              key: ValueKey(value),
              child: widget.builder(context, value, widget.child),
            ))
        .toList();
  }
}
