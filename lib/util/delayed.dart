import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Delayed extends StatefulWidget {
  const Delayed({
    required this.initialChild,
    required this.child,
    required this.delay,
  });

  final Widget initialChild;
  final Widget child;
  final Duration delay;

  @override
  _DelayedState createState() => _DelayedState();
}

class _DelayedState extends State<Delayed> {
  late Future<Widget> _delayedChild;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Delayed oldWidget) {
    if (oldWidget.child != widget.child) {
      _initialize();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: widget.initialChild,
      future: _delayedChild,
      builder: (context, AsyncSnapshot<Widget> snap) => snap.data!,
    );
  }

  void _initialize() =>
      _delayedChild = Future.delayed(widget.delay, () => widget.child);
}
