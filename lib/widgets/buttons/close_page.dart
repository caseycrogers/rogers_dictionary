import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ClosePage extends StatelessWidget {
  final Function() onClose;

  ClosePage({@required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: IconButton(
        icon: Icon(
          Icons.close,
          color: Theme.of(context).accentIconTheme.color,
        ),
        onPressed: onClose,
      ),
    );
  }
}
