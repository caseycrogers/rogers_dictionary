import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/widgets/buttons/close_page.dart';

class PageHeader extends StatelessWidget {
  final Widget header;
  final Widget child;
  final Function onClose;
  final bool scrollable;
  final double padding;

  PageHeader(
      {@required this.header,
      @required this.child,
      @required this.onClose,
      this.scrollable = true,
      this.padding = PAD});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClosePage(onClose: onClose),
              Expanded(child: header),
            ],
          ),
        ),
        Divider(indent: padding, endIndent: padding, height: 0.0),
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
