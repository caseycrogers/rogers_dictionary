import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ClosePage extends StatelessWidget {
  final VoidCallback onClose;

  ClosePage({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.arrow_back,
        color: Theme.of(context).iconTheme.color,
      ),
      onPressed: onClose,
    );
  }
}
