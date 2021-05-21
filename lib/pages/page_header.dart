import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:rogers_dictionary/util/constants.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.header,
    required this.child,
    required this.onClose,
    this.scrollable = true,
    this.padding = 2 * kPad,
  });

  final Widget header;
  final Widget child;
  final VoidCallback onClose;
  final bool scrollable;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: padding, right: padding),
          child: header,
        ),
        Divider(indent: padding, endIndent: padding, height: 0),
        if (scrollable)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.only(
                    left: padding, right: padding, bottom: padding),
                child: child,
              ),
            ),
          ),
        if (!scrollable)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: child,
            ),
          ),
      ],
    );
  }
}
