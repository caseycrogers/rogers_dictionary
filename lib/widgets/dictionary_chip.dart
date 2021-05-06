import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DictionaryChip extends StatelessWidget {
  final Widget child;
  final Color? color;

  DictionaryChip({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color ?? Colors.grey.shade300,
      padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
      label: child,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    );
  }
}
