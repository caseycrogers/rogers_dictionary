import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_top_bar.dart';

class PageHeader extends StatefulWidget {
  final Widget header;
  final Widget child;
  final VoidCallback onClose;
  final bool scrollable;
  final double padding;

  PageHeader({
    required this.header,
    required this.child,
    required this.onClose,
    this.scrollable = true,
    this.padding = 2 * kPad,
  });

  @override
  _PageHeaderState createState() => _PageHeaderState();
}

class _PageHeaderState extends State<PageHeader> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero,
        () => DictionaryTopBar.of(context).onClose = widget.onClose);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: 4.0, left: widget.padding, right: widget.padding),
          child: widget.header,
        ),
        Divider(indent: widget.padding, endIndent: widget.padding, height: 0.0),
        if (widget.scrollable)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.only(
                    left: widget.padding,
                    right: widget.padding,
                    bottom: widget.padding),
                child: widget.child,
              ),
            ),
          ),
        if (!widget.scrollable)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.padding),
              child: widget.child,
            ),
          ),
      ],
    );
  }
}
