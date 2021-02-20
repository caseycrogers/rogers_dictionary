import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DictionaryTab extends StatefulWidget {
  DictionaryTab({
    @required this.selected,
    @required this.unselected,
    @required this.index,
  });

  final Widget selected;
  final Widget unselected;
  final int index;

  @override
  _DictionaryTabState createState() => _DictionaryTabState();
}

class _DictionaryTabState extends State<DictionaryTab> {
  TabController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= DefaultTabController.of(context);
    _controller.addListener(_onTabSelected);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabSelected);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _controller.index == widget.index ? widget.selected : widget.unselected;

  void _onTabSelected() {
    if (mounted) setState(() {});
  }
}
