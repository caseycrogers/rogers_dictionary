import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopShadow extends StatelessWidget {
  final Widget child;

  TopShadow({this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      verticalDirection: VerticalDirection.up,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: child,
        ),
        Material(
          elevation: 4.0,
          child: Container(height: 0.001),
        )
      ],
    );
  }
}
