import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ClosePage extends StatelessWidget {
  const ClosePage({required this.onClose});

  final Function(BuildContext) onClose;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.arrow_back,
        color: Theme.of(context).iconTheme.color,
      ),
      onPressed: () => onClose(context),
    );
  }
}
