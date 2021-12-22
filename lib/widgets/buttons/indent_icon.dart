import 'dart:math';

import 'package:flutter/material.dart';

class IndentIcon extends StatelessWidget {
  const IndentIcon({Key? key, this.size, this.color}) : super(key: key);

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
        child: Icon(
          Icons.keyboard_return,
          color: color,
          size: size,
        ),
      );
}
