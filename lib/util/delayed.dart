import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Delayed extends StatefulWidget {
  final Widget initialChild;
  final Widget child;
  final Duration delay;

  Delayed(
      {@required this.initialChild,
      @required this.child,
      @required this.delay});

  @override
  _DelayedState createState() => _DelayedState();
}

class _DelayedState extends State<Delayed> {
  Future<Widget> _delayedChild;

  @override
  void initState() {
    super.initState();
    _delayedChild = Future.delayed(widget.delay, () => widget.child);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: widget.initialChild,
      future: _delayedChild,
      builder: (context, snap) => snap.data,
    );
  }
}
