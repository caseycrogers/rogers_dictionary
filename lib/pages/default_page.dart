import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefaultPage extends Page<void> {
  const DefaultPage({
    LocalKey? key,
    required this.child,
    this.transitionsBuilder = _dictionaryTransitionBuilder,
  }) : super(key: key);

  final Widget child;
  final RouteTransitionsBuilder transitionsBuilder;

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) {
        return child;
      },
    );
  }
}

Widget _dictionaryTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    child: child,
    opacity: animation,
  );
}
