import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DictionaryProgressIndicator extends StatelessWidget {
  const DictionaryProgressIndicator({
    Key? key,
    required this.child,
    required this.progress,
  }) : super(key: key);

  final Widget child;
  final ValueListenable<double> progress;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, progress, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).selectedRowColor,
                Theme.of(context).cardColor,
              ],
              stops: [
                progress,
                progress,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
}
