import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SlideEntranceExit extends StatelessWidget {
  final Widget child;
  final Animation<double> entranceAnimation;
  final Animation<double> exitAnimation;
  final Offset offset;

  SlideEntranceExit({
    @required this.child,
    @required this.offset,
    this.entranceAnimation,
    this.exitAnimation,
  }) : assert(entranceAnimation != null || exitAnimation != null);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: offset)
          .animate(exitAnimation ?? kAlwaysDismissedAnimation),
      child: SlideTransition(
        position: Tween<Offset>(begin: offset, end: Offset.zero)
            .animate(entranceAnimation ?? kAlwaysCompleteAnimation),
        child: child,
      ),
    );
  }
}
