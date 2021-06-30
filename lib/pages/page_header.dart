import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/widgets/buttons/close_page.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.header,
    required this.child,
    required this.onClose,
    this.divider = true,
    this.scrollable = true,
    this.padding = kPad,
  });

  final Widget header;
  final Widget child;
  final VoidCallback onClose;
  final bool divider;
  final bool scrollable;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: EdgeInsets.only(right: padding),
            child: Row(
              children: [
                ClosePage(onClose: onClose),
                Expanded(child: header),
              ],
            ),
          ),
        ),
        if (divider) Divider(indent: padding, endIndent: padding, height: 0),
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


