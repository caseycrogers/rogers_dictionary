import 'package:flutter/material.dart';

import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';

class DropDownWidget extends StatefulWidget {
  const DropDownWidget({
    required this.builder,
    required this.child,
    this.padding,
    this.selectedColor,
  });

  final Widget Function(BuildContext, VoidCallback) builder;
  final Widget child;
  final EdgeInsets? padding;
  final Color? selectedColor;

  @override
  _DropDownWidgetState createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveIconButton(
      splashColor: widget.selectedColor,
      highlightColor: widget.selectedColor,
      icon: widget.child,
      onPressed: () => _show(),
    );
  }

  void _show() {
    final renderBox = context.findRenderObject() as RenderBox;
    final Offset upperLeft = renderBox.localToGlobal(Offset.zero);
    bool onLeft = true;
    final double width = MediaQuery.of(context).size.width;
    if (upperLeft.dx > width / 2) {
      onLeft = false;
    }
    final ThemeData exteriorTheme = Theme.of(context);
    BoxConstraints? prevConstraints;
    showDialog<void>(
      useRootNavigator: false,
      useSafeArea: false,
      context: context,
      builder: (context) {
        return Theme(
          data: exteriorTheme,
          child: LayoutBuilder(builder: (context, constraints) {
            if (prevConstraints != null && constraints != prevConstraints) {
              _show();
            }
            prevConstraints = constraints;
            return Stack(
              children: [
                Positioned(
                  top: upperLeft.dy + renderBox.size.height - kPad / 2,
                  left: onLeft ? upperLeft.dx : null,
                  right: onLeft
                      ? null
                      : width - upperLeft.dx - 2 * renderBox.size.width / 3,
                  child: AdaptiveMaterial(
                    adaptiveColor: AdaptiveColor.surface,
                    child: Padding(
                      padding: widget.padding ?? const EdgeInsets.all(2),
                      child: widget.builder(
                        context,
                        Navigator.of(context).pop,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
