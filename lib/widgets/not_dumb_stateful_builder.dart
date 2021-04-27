import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotDumbStatefulBuilder extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final void Function(BuildContext) init;
  final void Function(BuildContext) dispose;

  NotDumbStatefulBuilder({this.init, @required this.builder, this.dispose});

  @override
  _NotDumbStatefulBuilderState createState() => _NotDumbStatefulBuilderState();
}

class _NotDumbStatefulBuilderState extends State<NotDumbStatefulBuilder> {
  @override
  void initState() {
    if (widget.init != null) widget.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);

  @override
  void dispose() {
    if (widget.dispose != null) widget.dispose(context);
    super.dispose();
  }
}
