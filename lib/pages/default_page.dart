import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';

class DefaultPage extends Page<void> {
  DefaultPage({
    LocalKey? key,
    required DictionaryModel dictionaryModel,
    required this.child,
    this.transitionsBuilder,
    this.duration = const Duration(milliseconds: 200),
  }) : super(
    key: key,
    name: dictionaryModel.name,
    arguments: dictionaryModel,
  );

  static final PageStorageBucket _globalBucket = PageStorageBucket();

  final Widget child;
  final RouteTransitionsBuilder? transitionsBuilder;
  final Duration duration;

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder(
      transitionDuration: duration,
      settings: this,
      transitionsBuilder: transitionsBuilder ?? _dictionaryTransitionBuilder,
      pageBuilder: (context, animation, secondaryAnimation) {
        return PageStorage(
          bucket: _globalBucket,
          child: child,
        );
      },
      maintainState: false,
    );
  }
}

Widget _dictionaryTransitionBuilder(BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,) {
  return FadeTransition(
    child: FadeTransition(
      child: child,
      opacity: secondaryAnimation.drive(
        Tween<double>(begin: 1, end: 0),
      ),
    ),
    opacity: animation,
  );
}
