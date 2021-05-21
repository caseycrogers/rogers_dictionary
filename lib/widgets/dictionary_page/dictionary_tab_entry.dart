import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DictionaryTabEntry extends StatefulWidget {
  const DictionaryTabEntry({
    required this.selected,
    required this.unselected,
    required this.index,
  });

  final Widget selected;
  final Widget unselected;
  final int index;

  @override
  _DictionaryTabEntryState createState() => _DictionaryTabEntryState();
}

class _DictionaryTabEntryState extends State<DictionaryTabEntry> {
  late TabController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = DefaultTabController.of(context)!;
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
    if (mounted) {
      setState(() {});
    }
  }
}
