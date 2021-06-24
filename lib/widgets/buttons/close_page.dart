import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ClosePage extends StatelessWidget {
  const ClosePage({Key? key, required this.onClose})
      : super(key: key);

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.close,
        color: Theme.of(context).accentIconTheme.color,
      ),
      onPressed: onClose,
    );
  }
}
