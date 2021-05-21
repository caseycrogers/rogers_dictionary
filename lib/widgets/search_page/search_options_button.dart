import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:rogers_dictionary/widgets/search_page/search_options_view.dart';

class SearchOptionsButton extends StatefulWidget {
  @override
  _SearchOptionsButtonState createState() => _SearchOptionsButtonState();
}

class _SearchOptionsButtonState extends State<SearchOptionsButton>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 100),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isMounted) {
          return true;
        }
        _toggle();
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isMounted ? Colors.white10 : Colors.transparent,
        ),
        child: IconButton(
          icon: const Icon(Icons.more_vert),
          color: Colors.white,
          onPressed: () => _toggle(),
        ),
      ),
    );
  }

  OverlayEntry _buildOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final Offset upperLeft = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (_) => Positioned(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _curve,
              child: Container(
                color: Colors.black38,
                child: GestureDetector(
                  onTap: _toggle,
                ),
              ),
            ),
            Positioned(
              top: upperLeft.dy + renderBox.size.height + 4.0,
              right: 0,
              width: 275,
              child: ScaleTransition(
                alignment: Alignment.topRight,
                scale: _curve,
                child: SearchOptionsView(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle() {
    if (_isMounted) {
      _controller.reverse().then((_) {
        setState(() {
          _overlayEntry?.remove();
          _overlayEntry = null;
        });
      });
      return;
    }
    setState(() {
      _overlayEntry = _buildOverlayEntry();
      Overlay.of(context)!.insert(_overlayEntry!);
      _controller.forward();
    });
  }

  bool get _isMounted => _overlayEntry != null;

  Animation<double> get _curve => CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      );
}
